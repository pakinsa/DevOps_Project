### CICD_with GitHub_Actions on Serverless 3-tier Architecture

##### Our CI/CD Workflow Deployment Strategy Matrix

| Component | Orchestrator (The Engine) | Goal | Common Tool | 2026 Modern Standard |
| :--- | :--- | :--- | :--- | :--- |
| **1. Frontend** | **GitHub Actions** | Sync files & clear cache | `aws s3 sync` | **CloudFront + OIDC** |
| **2. Database** | **GitHub Actions** | Update table structures | Prisma / Flyway / Liquibase | **Migration-as-Code Runs *before* backend** |
| **3. Backend (No K8s)** | **GitHub Actions** | Replace app code/images | `ecs-deploy`/ `eb deploy` | **Direct Push to AWS via OIDC** |
| **4. Backend (K8s)** | **ArgoCD** (GitOps) | Sync desired state | `kubectl apply` / `helm` / `kustomize` | **Automated Pull from Git** |

Important Distinction:
For Rows 1, 2, and 3: GitHub Actions is the "Driver." It actively connects to AWS and performs the work.
For Row 4 (K8s): GitHub Actions is the "Messenger." It updates a version number in your Git repo, and then ArgoCD (which lives inside Kubernetes) notices the change and performs the deployment. This is the definition of GitOps.






###  01. Frontend/S3-CloudFront
* **Essence:** To avoid manual upload of our dist folder to S3 whenever our frontend code changes we needed to implement CI workflow 

* **What we need:**

    - OIDC (OpenID Connect): Instead of storing long-lived AWS_ACCESS_KEY_IDs in GitHub which has been a common pratice, use OIDC. This allows GitHub to "assume a role" in AWS temporarily. It is much more secure.

    -  S3 Permissions: Your GitHub role needs s3:PutObject, s3:ListBucket, and s3:DeleteObject (if you want to remove old files).

    -  CloudFront Invalidation: The role needs cloudfront:CreateInvalidation. Without this, your users will keep seeing the old version of your site for 24 hours until the cache expires.

* **Guide Against (Pitfalls):**

    - Manual S3 Uploads: Never manually upload files to S3 once the pipeline is live. It creates "configuration drift."

    - Permissions Leakage: Ensure your S3 bucket is not public. CloudFront should access it via an Origin Access Control (OAC).




***Step 1:**
* Create IAM Identity Provider in AWS IAM:
    - Provider URL: https://token.actions.githubusercontent.com
    - Audience: sts.amazonaws.com

![alt text](img/01a.oidc_github_provider.PNG) 

![alt text](img/01b.oidc_github_provider.PNG)

* IAM Role: Create a role (e.g., GitHubFrontendRole) with a Trust Policy that allows your specific GitHub repository to assume it.
    
    - Click "Create Policy"
    - Specify permissions
    - Search & select: you can also use JSON: Click the JSON tab (next to "Visual").
        - s3:PutObject, s3:ListBucket, s3:DeleteObject for your specific bucket.
        - cloudfront:CreateInvalidation for your specific distribution

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "cloudfront:CreateInvalidation"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*",
                "arn:aws:cloudfront::YOUR_ACCOUNT_ID:distribution/YOUR_DIST_ID"
            ]
        }
    ]
}
``` 

    - Create Role

    - Attach created policy to role


**Step 2**
*  Create a file in your repository: .github/workflows/frontend-deploy.yml. This file uses OIDC to get temporary keys.

```yaml
name: Frontend Deployment
on:
  push:
    branches: [ main ]
    paths:
      - 'frontend/**'
      - '!backend/**'
      - '!.github/**'      # Explicitly ignore workflow changes
      - '!.github/workflows/migration.yml'

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install & Build
        working-directory: ./frontend
        env:
          # This replaces your local .env file during the build
          VITE_API_URL: ${{ secrets.VITE_API_URL }}
        run: |
          npm install
          npm run build

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Sync to S3
        run: |
          aws s3 sync ./frontend/dist s3://${{ secrets.S3_BUCKET_NAME }} --delete

      - name: Invalidate CloudFront Cache
        run: |
          aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths "/*"
```

##### Creating Secrets on GitHub 
We shall create a secret for each one of the parameters in the yaml code, we should not hardcode IDs or ARNs directly into the YAML file. Hardcoding makes the pipeline rigid and leaks your infrastructure details in the source code.

* AWS_ROLE_ARN → arn:aws:iam::465828358642:role/Github_Frontend_Role
* S3_BUCKET_NAME → paul-3tier-frontend
* CLOUDFRONT_DISTRIBUTION_ID → ER6F3L1LIOLXY
* VITE_API_URL → /api (Since this is a relative path, it’s not "secret," we can put it in the code or in github secrets, however, keeping it 
in the code allows us to change it easily).


##### Where to put these parameter details
* We go to our application's GitHub Repository 
    - Settings 
    - Secrets and variables 
    - Actions 
    - New repository secret


###### Why this is the best practice:
Security: Your AWS Account ID and Role name are hidden from anyone browsing the code.
Reusability: If you ever create a "Staging" bucket, you just change the secret value in GitHub; you don't have to edit the code.
Cleanliness: The YAML remains a "template," and the Secrets provide the "data."


**Git push**
Add, commit and push to github for ci/cd

```Bash
git add frontend/src/App.tsx
git add .github/workflows/frontend-deploy.yml

git reset backend/

git commit -m "deploy"
git push origin main
```


![alt text](img/01d.specify_permissions.PNG) 
    
![alt text](img/01e.specify_permissions.PNG) 
    
![alt text](img/01f.specify_permissions.PNG)

![alt text](img/01g.IAM_role_web_identity.PNG) 
    
![alt text](img/01h.IAM_role_web_identity.PNG) 
    
![alt text](img/01j.IAM_role_web_identity_github.PNG)


![alt text](img/01k.github_settings.PNG) 

![alt text](img/01l.github_secrets.PNG) 

![alt text](img/01m.github_secrets.PNG) 

![alt text](img/01n.succ_workflow.png) 

![alt text](img/01o.succ_workflow.png)




### 02. Database: RDS & Schema Migrations 

**Automated Database Migrations to a Private RDS**

* **Essence:** Database migration in a pipeline is the process of automatically updating your database tables, indexes, and constraints so they stay in sync with your backend code.

* **What you need:**
    - Migration Tool: Use a tool integrated with your backend (like Prisma, TypeORM, Sequelize, or Django Migrations) or a standalone tool like     Flyway or Liquibase.
    
    - Network Connectivity: Your GitHub Runner needs a way to "talk" to your RDS instance. Since RDS is usually in a private subnet, you must use a 
    Self-Hosted GitHub Runner inside your VPC or a WireGuard/VPN tunnel.
    
    - Idempotency: Migration scripts must be written so they can be run multiple times without failing (e.g., "Add column X only if it doesn't exist").
    
    - Secrets Management: Access credentials for the DB should be pulled from AWS Secrets Manager or GitHub Actions Secrets during the run.

* **Guide Against (Pitfalls):**
    - Locking the Production DB: Long-running migrations (like adding an index to a table with millions of rows) can lock your database and take your site offline. Always test the "time to run" in a staging environment.
    
    - Breaking Changes: Never delete a column that the currently running version of your app still needs. Use a "two-step" deployment: 1. Add new columns, 2. Deploy code, 3. (Later) Remove old columns.

    - Manual Changes via Jump Server: Once you start using automated migrations, stop making manual schema changes via your Jump Server. This causes 
    
    - "Out of Sync" errors where the pipeline tries to add a column that you already added manually, causing the deployment to fail.

    - No Rollback Plan: Always have a "down" script or a database snapshot (using Amazon RDS Snapshots) ready before running a major migration in case you need to revert.

###### Important Note:
- If using Node.js/TypeScript: Use Prisma. It is the modern standard because it generates the migration scripts for you based on your data model.
- If using Java/Spring Boot: Flyway is the conventional choice because it is incredibly simple to set up with just basic SQL files.
- If you have complex, multi-database needs: Liquibase is better for large enterprise environments where you need more advanced control over the migration logic.
- The "Ultra-Light" Alternative: If you want something even simpler that is 100% free with no "Pro" upsells, look at golang-migrate, which is a single executable that just runs SQL files




**Preliminaries**

* Ensure new app user has been granted all priviledges

* .env at backend folder now has DB_USER="appuser", DB_PASS="SimplePassword123!" or ensure detials here alligns with what youve created for new admin user

* Our goal here is to add a new column "rating" to the database, to test our github ci/cd data migration


**Step 1**
1. Configure GITHUB Secrets
    Go to your GitHub Repo Settings > Secrets and variables > Actions and add these 4 Secrets:

    * EC2_SSH_KEY: Paste the entire content of your private key .pem file (e.g., new_stella_key).The Private Key is the 'Passport' GitHub uses to enter the AWS network. Without it, the tunnel can't open.
    * EC2_PUBLIC_IP: Our Jump Server IP (3.84.247.110).
    * RDS_ENDPOINT: three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com
    * DATABASE_URL: Use the localhost version: mysql://appuser:SimplePassword123!@127.0.0.1:3307/react_node_app


**Step 2**
2. Go to your VS Code Repo root. Create the GitHub Actions Workflow 
    Create a file at ```.github/workflows/migration.yml`` in your repository and paste the migration code below:

```yaml
name: Database Migration

on:
  push:
    branches: [main]
    # Only trigger if database-related files change
    paths:
      - 'backend/prisma/**'
      - '!frontend/**'
      - '!.github/**'

jobs:
  migrate:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Dependencies
        run: npm ci

      - name: Tunnel and Migrate
        # We combine these into one block so GitHub doesn't kill the tunnel before Prisma runs
        run: |
          # 1. Setup the Private SSH Key
          echo "${{ secrets.EC2_SSH_KEY }}" > private_key.pem
          chmod 600 private_key.pem

          # 2. Start the SSH Tunnel in the background
          # Maps Runner's 127.0.0.1:3307 -> RDS 3306 via the Jump Server
          ssh -i private_key.pem -o StrictHostKeyChecking=no -f -N -L 3307:three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com:3306 ec2-user@${{ secrets.EC2_PUBLIC_IP }}
          
          # 3. Wait for the bridge to stabilize
          sleep 5

          # 4. Verify the connection is alive
          nc -zv 127.0.0.1 3307

          # 5. Execute Prisma Migrations immediately while the tunnel is open
          npx prisma migrate resolve --applied 0_init || true
          npx prisma migrate deploy
        env:
          # This must be the localhost version: mysql://user:pass@127.0.0.1:3307/db
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
```


**Step 3**
3. While on step 3A, a directory and a file: ```prisma/schema.prisma``` would be created, copy and paste this prisma schema db code below into the file before continue into the next command. If this step is jumped, prisma config file wont be added to the backend directory.

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
}

model author {
  id        Int      @id @default(autoincrement())
  name      String   @db.VarChar(255)
  birthday  DateTime @db.Date
  bio       String   @db.Text
  createdAt DateTime @db.Date
  updatedAt DateTime @db.Date
  books     book[]
}

model book {
  id          Int      @id @default(autoincrement())
  title       String   @db.VarChar(255)
  releaseDate DateTime @db.Date
  description String   @db.Text
  pages       Int
  createdAt   DateTime @db.Date
  updatedAt   DateTime @db.Date
  authorId    Int?
  rating      Int?     // <--- ENSURE THIS IS HERE or add price Int? Warning: Only add new this lines of change after DB_Pull
  author      author?  @relation(fields: [authorId], references: [id], map: "FK_author_link")

  @@index([authorId], map: "FK_author_id_idx")
}
```


**Step 4**
Ensure your prisma.config.ts is in this format:
```bash
import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    // This tells Prisma where to find your RDS URL
    url: process.env.DATABASE_URL,   # esp Prisma 7
  },
});
```

**Step 5**
5. Still at VS Code, at terminal, ```cd backend/```and run these Prep and Migration commands to install, initialise prisma, and
since tables already exist in RDS, we must tell Prisma to "pretend" it already created them, 
so it doesn't try to run 'CREATE TABLE' again and add rating column to our database without touching the app code



```bash
# This is migration code
# --- STEP E: INITIALIZE PRISMA 7 & DATABASE CONNECTION ---
# (Run these from your /backend folder)

# 1. Install Prisma 7 and its configuration engine
npm install prisma@latest @prisma/client@latest @prisma/config@latest --save-dev

# 2. Initialize Prisma (This creates the /prisma folder and .env file)
npx prisma init --datasource-provider mysql

# 3. Create the Prisma 7 Config file (Crucial for RDS/CI-CD)
# (Teach the student to paste the export default defineConfig... code here)
touch prisma.config.ts && code prisma.config.ts prisma/schema.prisma

# 4. Pull the current RDS structure into the schema.prisma
# (NOTE: Requires the SSH Tunnel terminal to be open on port 3307!)
npx prisma db pull

# --- STEP F: CLEANUP AND RESET MIGRATIONS FOR RDS BASELINE ---
# (Now we organize the folders so the CI/CD recognizes the existing RDS tables)

# 1. Clear previous local migration history
rm -rf prisma/migrations/

# 2. Create the baseline migration (0_init) folder
mkdir -p prisma/migrations/0_init
cat <<EOF > prisma/migrations/0_init/migration.sql
CREATE TABLE IF NOT EXISTS author (id int NOT NULL AUTO_INCREMENT, name varchar(255) NOT NULL, birthday date NOT NULL, bio text NOT NULL, createdAt date NOT NULL, updatedAt date NOT NULL, PRIMARY KEY (id));
CREATE TABLE IF NOT EXISTS book (id int NOT NULL AUTO_INCREMENT, title varchar(255) NOT NULL, releaseDate date NOT NULL, description text NOT NULL, pages int NOT NULL, createdAt date NOT NULL, updatedAt date NOT NULL, authorId int DEFAULT NULL, PRIMARY KEY (id), CONSTRAINT FK_author_link FOREIGN KEY (authorId) REFERENCES author (id));
EOF

# 3. Create the 'Add Rating' migration with a timestamped folder
MIGRATION_NAME="\$(date +%Y%m%d%H%M%S)_add_rating"
mkdir -p "prisma/migrations/\$MIGRATION_NAME"
echo "ALTER TABLE book ADD COLUMN rating INT;" > "prisma/migrations/\$MIGRATION_NAME/migration.sql"


# --- STEP G: PUSH TO GITHUB FROM THE ROOT DIRECTORY ---
# (This ensures Git can see both frontend and backend for proper path filtering)

# 1. Check your current location. 
# If you are in 'backend/', you MUST move up to the Main Project Root.
pwd
cd ..

# 2. Add ONLY the specific files required for the Database Migration.
# Notice we use the 'backend/' prefix now because we are in the Root.
# Only add the files that the migration.yml is watching
git add .github/workflows/migration.yml
git add backend/prisma/schema.prisma
git add backend/prisma.config.ts
git add backend/prisma/migrations/
git add backend/package.json

# 3. SAFETY CHECK: Verify what is "Staged" (Green).
# If you see any 'frontend/' files here, it means you added too much!
git status

# 4. If 'frontend/' files are accidentally Green, unstage them now:
# (This keeps your Frontend Pipeline from triggering unnecessarily)
git reset frontend/

# 5. Final Commit and Push
# Only the 'Database Migration' workflow should trigger on GitHub.
git commit -m "devops: baseline rds and add rating via isolated migration"
git push origin main
```




Once you have your baseline, you stop Pulling and start Pushing. You update the "Blueprint" (Schema) and then create a "Work Order" (Migration Folder) for the database to follow.

**To add a new table:**
```bash
# Update the prisma/schema.prisma
model review {
  id        Int      @id @default(autoincrement())
  content   String   @db.Text
  rating    Int
  bookId    Int
  book      book     @relation(fields: [bookId], references: [id])
}

# create a new timestamped folder in the script above so we don't mess up the 0_init or add_rating folders.
# --- STEP F (Updated for New Table: Review) ---
# 1. Generate a unique folder name for the new table
MIGRATION_NAME="\$(date +%Y%m%d%H%M%S)_create_review_table"
mkdir -p "prisma/migrations/\$MIGRATION_NAME"

# 2. Write the SQL command to actually build the table in RDS
cat <<EOF > "prisma/migrations/\$MIGRATION_NAME/migration.sql"
CREATE TABLE IF NOT EXISTS review (
    id INT NOT NULL AUTO_INCREMENT,
    content TEXT NOT NULL,
    rating INT NOT NULL,
    bookId INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_book_review FOREIGN KEY (bookId) REFERENCES book (id)
);
EOF
```


**To add a new column e.g price int?**
```bash
Edit the prisma/schema.prisma, by adding a line:

model book {
  // ... existing fields
  rating Int?
  price  Int?     // <--- ADD THIS LINE MANUALLY IN VS CODE
}

# Create a NEW timestamped migration folder for the price column. You don't need to touch the 0_init baseline anymore because that’s already done.
 MIGRATION_NAME="\$(date +%Y%m%d%H%M%S)_add_price"
 mkdir -p "prisma/migrations/\$MIGRATION_NAME"

# 2. Write the SQL for the new change
 echo "ALTER TABLE book ADD COLUMN price INT;" > "prisma/migrations/\$MIGRATION_NAME/migration.sql"


# Once a migration folder (like 0_init or add_rating) has been pushed to GitHub and applied to RDS, never change the files inside those folders. If you want a new change, always create a brand new folder with a new timestamp.
# Pro-Tip: If you add a whole new Table, your SQL would be CREATE TABLE ... instead of ALTER TABLE ....
```

By making the column nullable (Int?), you have successfully updated the infrastructure (DevOps) without requiring the developer to change a single line of their Node.js code (App). That's why we used this ```npx prisma db pull``` first and not this command ```npx prisma migrate dev --name init```


**What happens next:**
* Prisma Sync: Prisma connects to your RDS to ensure it matches your VS Code model via db pull.
* Baselining: We manually create the prisma/migrations/0_init/ folder and use migrate resolve to tell Prisma the existing tables are already there so it doesn't try to recreate them.
* Change Detection: When you add the rating column and run migrate dev, Prisma creates a second folder (e.g., ..._add_rating/) containing a migration.sql file that only adds the new column.
* Trigger: Both schema.prisma and the migrations/ folder are committed to GitHub. The paths setting in the workflow ensures the pipeline triggers only when these specific database files change, preventing unnecessary runs when you only update frontend code.



**Verification**

Once your GitHub Action finishes, you can verify the change by logging into your Jump Server and running:

```sql
DESCRIBE react_node_app.book;
```



You should see the rating column at the bottom of the list.

![alt text](img/2a.backend_env_before_01.PNG) 

![alt text](img/2b.backend_env_after_02.PNG)

![alt text](img/2c.github_db_url_secret_01.PNG) 

![alt text](img/2c.github_db_url_secret_02.PNG)

![alt text](img/2d.migration_yaml_workflow.PNG)

![alt text](img/2e.prisma_schema.PNG)


![alt text](img/2e.prisma_schema.PNG) 

![alt text](img/2f.prisma_config_ts.PNG) 

![alt text](img/2g.prisma_created_2models.PNG) 

![alt text](img/2h.github_workflow_push.PNG) 

![alt text](img/2i.migration_success.PNG) 

[alt text](img/2j.migration_successPNG)










### 03. Backend/ECS-Fargate
The Workflow: Git Push → GitHub Action builds Docker Image → Push to ECR → GitHub Action tells ECS to update.

03. Backend: ECS, ECR & Fargate
* Essence: This is a "build once, run anywhere" workflow.

* What you need:
    - ECR Repository: A place to store your Docker images.
    - Task Definition Template: A JSON file in your GitHub repo that describes how your container should run (CPU, Memory, Environment Variables).
    - The "Magic" Action: GitHub has an official action called aws-actions/amazon-ecs-deploy-task-definition which handles the heavy lifting of updating the service.

* Guide Against (Pitfalls):
    - Hardcoding Secrets: Never put DB passwords or API keys in your Dockerfile or Task Definition. Use AWS Secrets Manager and reference them in the Task Definition.
    - Large Image Sizes: Use "Multi-stage builds" in your Dockerfile to keep images small. Smaller images mean faster deployments and lower costs.
    - Tagging Strategy: Don't use the "latest" tag for deployments. Tag images with the GitHub Commit SHA. This allows you to roll back to a specific version if something breaks.





To implement a professional Backend CI/CD that uses Docker, ECR, and Fargate with the SHA Tagging Strategy, follow these 4 Steps.


**Step 1:** **Create the Dockerfile (In /backend):**
GitHub needs this "recipe" to build your container. Create a file named ```Dockerfile``` in your backend/ folder:

```dockerfile
FROM node:20-slim
WORKDIR /app
COPY package*.json ./
# 'npm ci' is faster and more reliable in CI/CD than 'npm install'
RUN npm ci --only=production
COPY prisma ./prisma/
RUN npx prisma generate
COPY . .
# CHANGE THIS TO 3000 to match your Task Definition
EXPOSE 3000
CMD ["npm", "start"]
```


**Step 2**: **Save your Task Definition (In Root)**
For GitHub to update Fargate with a specific SHA tag, it needs your "Task Definition" file.

Run this command on your PC (or Jump Server) to get your current config:
```bash
aws ecs describe-task-definition --task-definition Serverless_task_def --query taskDefinition > backend-task-def.json
```
Place this backend-task-def.json file in your Main Root Directory. But we reformatted the original task definition, so 
new version has placeholders, and Github can take their respective values from Secrets. see it below.

```json
{
    "containerDefinitions": [
        {
            "name": "my-backend-container",
            "image": "PLACEHOLDER",
            "cpu": 0,
            "portMappings": [
                {
                    "containerPort": 3000,
                    "hostPort": 3000,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                { "name": "DB_NAME", "value": "DB_NAME_PLACEHOLDER" },
                { "name": "PORT", "value": "3000" },
                { "name": "DB_HOST", "value": "DB_HOST_PLACEHOLDER" },
                { "name": "DB_USER", "value": "DB_USER_PLACEHOLDER" },
                { "name": "DB_PASSWORD", "value": "DB_PASSWORD_PLACEHOLDER" }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/Serverless_task_def",
                    "awslogs-create-group": "true",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ],
    "family": "Serverless_task_def",
    "executionRoleArn": "arn:aws:iam::465828358642:role/ecsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::465828358642:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [ "FARGATE" ],
    "cpu": "512",
    "memory": "1024",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    }
}
```





**Step 3:** **Enable AWS Handshake and GitHub Secrets**

**Step 3a:** **Enable AWS Handshake**
We have created OIDC handshake btw github and AWS earlier at the frontend ci/cd task.
Our AWS_ROLE_TO_ASSUME=arn:aws:iam::465828358642:role/Github_Frontend_Role
Which we have already added as secrets in github actions.
But we must add more policy to enable Github capacity to deploy into Fargate:
  * Attach policies to Github_Frontend_Policy inside Github_Frontend_Role.
    - ```AmazonEC2ContainerRegistryFullAccess```: This gives GitHub the "Write" (Push) and "Read" (Pull) permissions or "all" it needs for your Docker images.
    - ```AmazonECS_FullAccess```: This allows GitHub to "List" your clusters, "Read" your task definitions, and "Write" (Update) your services or "all".
    - ```IAM:PassRole```: It explicitly allows passing the ecsTaskExecutionRole so the Fargate task can actually start.

  * To avoid deployment bugs: we needed to delete Github_Frontend_Policy, create a new policy called: "Github_deploy_policy" and pasted the code
    that allows github run frontend and backend workflows by pasting a complete json policy code below in the policy document, and attach this policy to Github_Frontend_Role.
    
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "FrontendPermissions",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "cloudfront:CreateInvalidation"
            ],
            "Resource": [
                "arn:aws:s3:::paul-3tier-frontend",
                "arn:aws:s3:::paul-3tier-frontend/*",
                "arn:aws:cloudfront::465828358642:distribution/ER6F3L1LIOLXY"
            ]
        },
        {
            "Sid": "BackendDeploymentPermissions",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecs:RegisterTaskDefinition",
                "ecs:DescribeTaskDefinition",
                "ecs:ListTasks"
            ],
            "Resource": "*"
        },
        {
            "Sid": "PassRoleRequirement",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::465828358642:role/ecsTaskExecutionRole"
        }
    ]
}    
```    



**Step 3b:** **Add GitHub Secrets**
Add these to your GitHub Repo as Secrets if they aren't yet there: (Settings > Secrets > Actions):

```bash
DB_HOST=three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com # The RDS endpoint string.
DB_PASSWORD=SimplePassword123!
DB_USER=appuser
DB_NAME=react_node_app
AWS_ROLE_TO_ASSUME=arn:aws:iam::465828358642:role/Github_Frontend_Role  # Your IAM Role ARN
```


**Step 4:** **Create the Workflow in Root (.github/workflows/backend-deploy.yml)**
This replaces your ```push_to_ecr.sh``` script with an automated cloud version. This enables Github to 
carry out the task of Jump server we did in previous project.

**What are the risks of this method? Is this modern?**
The Risks: If your GitHub account is hacked, the hacker can deploy code to your AWS Account. 
Professionalism: 90% of modern tech companies use GitHub Actions or GitLab CI to deploy directly to Fargate/Kubernetes. It is much safer than manually SCP-ing files to a Jump Server. This is the industry standard.

Copy and paste the backend deployment code into .github/workflows/backend-deploy.yml but ensure to put in your actual container name first.

**Tip:** You can copy and paste your task definition above into LLM to generate the your backend deployment based on your infrasturture details
posibly with placeholders.



```yaml
name: Backend Deployment

on:
  workflow_run:
    workflows: ["Database Migration"]
    types: [completed]

# Required for OIDC authentication
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    # Only run if the Database Migration was SUCCESSFUL
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          # Replace with your actual IAM Role ARN (e.g., github_frontend_role or similar)
          role-to-assume: arn:aws:iam::123456789012:role/github_frontend_role 
          aws-region: us-east-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build, Tag, and Push to ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: 3tier-serverless
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./backend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

      - name: Render New Task Definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: backend-task-def.json
          container-name: my-backend-container                          # Ensure container name correct just as with the console
          image: ${{ steps.build-image.outputs.image }}
          environment-variables: |
            DB_HOST=${{ secrets.DB_HOST }}
            DB_PASSWORD=${{ secrets.DB_PASSWORD }}
            DB_USER=${{ secrets.DB_USER }}
            DB_NAME=${{ secrets.DB_NAME }}

      - name: Deploy to Amazon ECS (Fargate)
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: Serverless_task_def-service-rq42pfwa                     # Ensure service name is correct just as with the console
          cluster: 3tier_cluster                                            # Ensure cluster name is correct just as with the console    
          wait-for-service-stability: true
```






**Step 5:** **Prevent Collision at Push**

To prevent a "collision" where your Database Migration and Backend Deployment fight over the same commit, we use Workflow Dependencies.
In professionally in DevOps, we make the Backend wait for the Migration to finish. This ensures the database is ready before the new code tries to talk to it. Even with these filters, always be clean with your staging from the Root Directory:

```bash
# --- THE ULTIMATE DEPLOYMENT PUSH ---
cd /path/to/3-Tier_App

# 1. Add everything for a Full Backend Update
git add .github/workflows/
git add backend/
git add backend-task-def.json

# 2. Kill the Frontend noise
git reset frontend/

# 3. Commit and Push
git commit -m "feat: updated schema and triggered automated backend deployment"
git push origin main
```


![alt text](img/3a.docker_file.PNG) 

![alt text](img/3b.task_definition_file.PNG) 

![alt text](img/3c.backend_deploy_yml.PNG) 

![alt text](img/3d.IAM_passrole_ecs.PNG) 

![alt text](img/3d.new_github_policy_cod.PNG) 

![alt text](img/3d.new_github_policy.PNG) 

![alt text](img/3e.DB_host_secret.PNG) 

![alt text](img/3e.DB_Name_secret.PNG) 

![alt text](img/3e.DB_password_secret.PNG) 

![alt text](img/3e.DB_User_secret.PNG) 

![alt text](img/3f.backend_deploy_workflow_01.PNG) 

![alt text](img/3f.backend_deploy_workflow_02.PNG) 

![alt text](img/3f.ecr_image_tag_SHA_commit.PNG) 

![alt text](img/3g.service_health_03.PNG) 

![alt text](img/3g.service_task_def_03.PNG) 

![alt text](img/3g.task_def_03.PNG) 

![alt text](img/3g.wb_app_01.PNG)






#### Let test our CI/CD on Frontend

![alt text](img/3h.wb_app_02.png)

![alt text](img/3i.deploy_success.PNG) 

![alt text](img/3i.frontend_git_push.PNG) 

![alt text](img/3i.result.PNG)




#### Let test our CI/CD on Backend

Note: That database migration deployment triggered the backend deployment.

![alt text](img/3j.added_comments.PNG)

![alt text](img/3j.database_migration_triggered.png) 

![alt text](img/3k.backend_triggered.png) 

![alt text](img/3k.deployment_progress_02.png) 

![alt text](img/3k.deployment_progress.png) 

![alt text](img/3k.deployment_success_02.png) 

![alt text](img/3k.deployment_success.png)