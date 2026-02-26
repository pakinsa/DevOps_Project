
## A 3-Tier Serverless Arch_Docker_Fargate_ECR_ECS_ALB_RDS_CloudFront_no NAT Gateway


![alt text](img/00.fargate_arch.png)


#### 1. Networking (Multi-AZ Foundation) & Security Group
 
* VPC: 
- Create a VPC with 6 subnets: 
- 2 Public (ALB, Jump Server & Fargate)
- 2 Isolated (RDS).

![alt text](img/01a.vpc_more.PNG)

![alt text](img/01b.vpc_more.PNG)

* Security Groups (The Chain of Trust):
- ALB SG(alb-public-sg): Inbound 80/443 from 0.0.0.0/0. Outbound: All traffic to 0.0.0.0
- Fargate SG(fargate-app-sg): Inbound Backend Port (e.g., 3000) only from ALB SG. Outbound: All traffic to 0.0.0.0(which is necessary for Fargate to reach your database and ECR)
- Data SG(data-sg): Inbound TCP MySQL (3306) only from Fargate SG & EC2-SG; No outbound
- Jump Server SG(ec2-admin-sg): Inbound SSH (22) from your specific IP, Outbound: All traffic to 0.0.0.0


![alt text](img/01c.sg.PNG)




#### So can one, and should one, SSH into Fargate, ECR, and ECS?

| Service | Can you SSH? | Recommended Access Method | Why? |
| :--- | :---: | :--- | :--- |
| **Fargate** | No | ECS Exec | No host access; uses secure SSM tunnels. |
| **ECS (EC2)** | Yes | ECS Exec | More secure; no need to manage SSH keys. |
| **ECR** | No | Docker / AWS CLI | It’s a registry, not a compute service. |


#### 2: Create a Robust IAM for this Project ahead and attach to upcoming EC2 Admin(Jump Server)
- Create a Role and Attach

    - AmazonEC2ContainerRegistryFullAccess

    - AmazonECS_FullAccess

    - AmazonS3FullAccess

    - CloudFrontFullAccess

    - AmazonSSMManagedInstanceCore // this is optional, it was attached should in case we need it.

![alt text](img/02.Must_have_IAM_role_updated.PNG)

![alt text](img/02a.IAM_role_updated.PNG)


#### 3: Create EC2 Admin (Jump Server)
-  EC2 Instance:
    - Launch a t3.micro in a Public Subnet.
    - Attach ec2-admin-sg
    - Database Init: Use the Jump Server to log into the RDS and create your tables/schema.
    - Use the below UserData to prep ec2 for tasks ahead

```bash
#!/bin/bash
# This EC2-Admin UserData
# This userdata script installs Docker (to build your backend image), the MySQL Client (to talk to RDS), and the AWS CLI (to push to ECR).

# Redirect output to log for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# 1. Update and Install Essentials
dnf update -y
dnf install -y docker git unzip mariadb105

# 2. Start Docker and set permissions
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# 3. Create workspace
mkdir -p /home/ec2-user/deploy
chown ec2-user:ec2-user /home/ec2-user/deploy

# 4. Final Verification
echo "Installation Check:"
docker --version
mysql --version
unzip -v
```

![alt text](img/03a.Ec2_admin.PNG) 

![alt text](img/03b.Ec2_admin.PNG) 

![alt text](img/03c.Ec2_admin.PNG) 

![alt text](img/03d.Ec2_admin.PNG) 

![alt text](img/03e.Ec2_admin.PNG) 

![alt text](img/03f.Ec2_admin_confirm_docker.PNG)




#### 4. The database takes the longest to "spin up," so start it early.
-  RDS Subnet Group: Create a group containing your 2 Isolated Subnets.
-  RDS MySQL Instance:
    -  Choose Free Tier.
    -  Place it in the Isolated Subnets.
    -  Attach the RDS-SG.
    -  Create the DB
    Note: Keep the "Master Username/Password" and the Endpoint URL (available once it’s "Available").

- Confirm RDS state via EC2_Admin

    - Confirm RDS connection successful

    - Confirm react_node_app db exist

    - Confirm tables author & book exist in the react_node_app db. else 

        * Find **db.sql** file in your backend repo from the developer. 
          This file contains sql commands to create require tables, seeded data etc that you app will need to run effectively:

            - Use this command to copy and execute the db.sql so that it create db, tables & columns if they don't does not exist: 
            ```scp -i "your-key.pem" db.sql ec2-user@<JUMP_SERVER_IP>:/home/ec2-user/```  if using SSH on EC2_Admin 
            OR
            ```cd back to your linux shell prompt, copy and paste(ctrl + v) the content of db.sql into the terminal using nano db.sql, Press Ctrl+O, then Enter, then Ctrl+X to save and exit``` if using EIC on EC2_Admin
      
        Note: Database processes, migration and management are slightly different from app management, deployment and compute, hence the steps above; moreso once databases are created they remain permanent on RDS despite changes of app servers.


##### Ways we could get the db.sql code into the ec2-admin without userdata or shutting ec2-admin down:

| Method | Requires Restart? | Remote Access Needed? | Best For |
| :--- | :--- | :--- | :--- |
| SSM Run Command | No | IAM Permissions | Scaling, security, and ad-hoc fixes. |
| SSH / SCP | No | Port 22 Open | Quick manual changes. |
| Modify User Data | Yes | Console/API Access | Permanent bootstrap changes. |
| Ansible | No | SSH/SSM Access | Complex configuration management. |


* Interesting commands used here:
```cat /var/log/user-data.log```
```mysql -h three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com -u admin -p```
```mysql -h three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com -u admin -p < db.sql```  Use this if table is specified in the content of db.sql
```mysql -h three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com -u admin -p node_react_app < db.sql``` Use this if table is not specified in the content of db.sql, and ensure to replace yours "node_react_app"

```SELECT user, host FROM mysql.user;``` # Find and view all users;

```SHOW GRANTS FOR CURRENT_USER();```

```mysql -h three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com -u appuser -p``` sign into db using appuser


![alt text](img/04a.db_sub_grp.PNG) 

![alt text](img/04b.db_create_01.PNG) 

![alt text](img/04c.db_create_02.PNG) 

![alt text](img/04d.db_create_03.PNG)


![alt text](img/04e.db_create_04.PNG) 

![alt text](img/04f.db_create_05.PNG) 

![alt text](img/04g.db_create_06.PNG) 

![alt text](img/04h.db_create_07.PNG) 

![alt text](img/04i.db_create_08.PNG)


![alt text](img/04j.db_confirmation_09.PNG) 

![alt text](img/04k.db_upload_seeded_copy.PNG) 

![alt text](img/04l.db_seeded_data_created.PNG)

![alt text](img/04m.db_appuser_confirmd.PNG) 

![alt text](img/04n.db_appuser_login.PNG)



#### 5: Create the ECR Repository
- Service: Amazon ECR.
    - Action: Create Repository.
    - Name: your-backend-repo-name (Match your script exactly).
    - Why: Your script needs a destination for the docker push.
    - Copy and paste your ECR name into the push_to_ecr.sh script below


![alt text](img/05a.ecr.PNG) 

![alt text](img/05b.ecr.PNG)




#### 8: Create the Target Group (TG)
- Create Target Groups.
    - Target Type: IP Addresses (Required for Fargate).
    - Protocol/Port: HTTP / 3000.
    - VPC: Select your VPC.
    - Health Check Path: Usually /api/books or wherever your backend responds with a 200 OK.

![alt text](img/6a.tg_01.PNG) 

![alt text](img/6b.tg_02.PNG) 

![alt text](img/6c.tg_03.PNG) 

![alt text](img/6d.tg_04_dont_touch.PNG) 

![alt text](img/6e.tg_create.PNG)



#### 9: Create the Application Load Balancer (ALB)
- Create Load Balancers.
    - Scheme: Internet-facing.
    - Subnets: Select your 2 Public Subnets.
    - Security Group: Use your ALB-SG (Allow Port 80).
    - Listeners: Port 80 -> Forward to the Target Group you just created.


 * The Traffic Flow
    Even though the ALB is "Internet-facing," your users will still go through CloudFront. The flow looks like this:
    - User 
    - CloudFront (HTTPS) 
    - ALB (HTTP Port 80) 
    - Fargate (Port 3000)
    - RDS
 * Why is the ALB "Internet-facing"?
    CloudFront exists outside of your VPC. For CloudFront to "talk" to your ALB, the ALB must have a public DNS name that CloudFront can reach over the public internet. AWS CloudFront Origins.


    ![alt text](img/7a.alb.PNG) 
    
    ![alt text](img/7b.alb.PNG) 
    
    ![alt text](img/7d.alb.PNG) 
    
    ![alt text](img/7c.alb.PNG) 
    
    ![alt text](img/7e.alb.PNG)




#### 10: Create the ECS Cluster
-   Service: Amazon ECS.
    - Action: Create Cluster.
    - Name: your-ecs-cluster-name.
    - Infrastructure: Select Fargate.
    - Copy and paste your ECS Cluster short name into the push_to_ecr.sh script below

    ![alt text](img/8a.cluster.PNG) 

    ![alt text](img/8b.cluster_cloudformation.PNG)

    ![alt text](img/8c.cluster_no_tasks.PNG) 
    
    ![alt text](img/8d.cluster_no_service.PNG)


-   Create the ECS Task Definition
    - Action: Create new Task Definition.
    - Compute: Fargate.
    - Image URI: <ACCOUNT_ID>://.
    - Port Mapping: Container Port 3000 / Protocol TCP.
    - Environment Variables: Add your DB_HOST, DB_USER, DB_PASS, DB_NAME, and PORT.


    ![alt text](img/9a.task_def_01.PNG) 

    ![alt text](img/9b.task_def_02.PNG) 

    ![alt text](img/9c.task_def_03.PNG) 

    ![alt text](img/9d.task_def_04.PNG) 

    ![alt text](img/9e.task_def_05.PNG) 

    ![alt text](img/9f.task_def_06.PNG)



    * Tasks vs. Services: The Real Difference

    | Feature | Task | Service (The Manager) |
    | :--- | :--- | :--- |
    | **What it is** | A single running copy of your code. | The "controller" that monitors your tasks. |
    | **Autoscaling** | **No.** If a task dies, it stays dead. | **Yes.** If a task crashes, the Service restarts it. |
    | **Availability** | Just one unit of work. | **Yes.** The Service ensures tasks are spread across Multiple AZs. |
    | **Scaling** | **Manual** (Run 1 task). | **Automatic** (Scale from 2 to 10 tasks based on CPU). |

    Think of a Task as a single "running instance" of your Docker container. Think of a Service as the "Manager" that keeps them running.
    You define the Task, but you run the Service to make sure those tasks stay alive and scale across AZs.
    Tasks are the "workers" your GitHub Action creates.
    Services are the "bosses" that make sure the workers are actually doing their job after the git push.

    Note: Environment variables provided in the ECS Task Definition override evironmental variables in the .env file that was built and 
    containerised by docker. Just as evironmental variables specified in the userdata method overides enviromental 
    variable zipped in code build sent to S3.


-   Create the ECS Service
    - Cluster: Your cluster.
    - Name: your-ecs-service-name.
    - Desired Tasks: 2 (for High Availability).
    - Networking: Select your 2 Public Subnets and enable Auto-assign Public IP.
    - Load Balancing: Select your ALB and the Target Group.

    ![alt text](img/10a.service_cr_01.PNG) 

    ![alt text](img/10b.service_cr_02.PNG) 

    ![alt text](img/10c.service_cr_03.PNG) 

    ![alt text](img/10d.service_cr_04.PNG) 

    ![alt text](img/10e.service_cr_05.PNG)


But our service is currently in a "loop." It is trying to start, but because there is no image in ECR yet, the tasks will fail, and ECS will keep trying over and over.

![alt text](img/10g.service_waiting_01.PNG) 

![alt text](img/10g.service_waiting_02.PNG)

To break the loop and get our app live, we must run your script(push to ecr.sh) now or in the mean time you can pause it by setting back desired state from 2 to 0. To pause it.

The "Pause" (Set Desired Tasks to 0)
This stops the loop immediately without deleting your configuration.
    - Go to your 3tier_cluster -> Services tab.
    - Select your service: Serverless_task_def-service-rq42pfwa.
    - Click Update.
    - Change Desired tasks from 2 to 0.
    - Click Skip to review and then Update service

![alt text](img/10g.service_waiting_03.PNG) 

![alt text](img/10g.service_waiting_04.PNG)



#### 11: The magic upload of Backend-build.zip

* Generate backend-build.zip:
    -  Visit your cloned repo on VSCODE
    -  cd backend/
    -  npm install dotenv mysql2  // Install packages to handle .env file loading and RDS connection; task definition will handle production environment variables as task definition env variables superseeds
       // DO NOT run 'npm run build' here (Standard Node.js backends don't need a build step)
    -  rm -rf node_modules       # Remove this to make the ZIP small (User Data installs it for you)
    -  zip -r ../backend-build.zip ./*

* Locate SSH .pem file:
    Since we aren't using S3 for the backend transfer anymore, we have a professional and "clean" ways to get that     backend-build.zip from your computer to the Jump Server: The "Command Line" Way (SCP) using this command: ```scp -i "your-key.pem" backend-build.zip ec2-user@<YOUR_JUMP_SERVER_PUBLIC_IP>:/home/ec2-user/deploy/```

    - Open the PowerShell with Administrator terminal on your local computer (PowerShell on Windows or Terminal on Mac).
    
    ```powershell
    # 1. Go to the folder where you SSH pem file is, in my case it is Downloads folder
    cd $HOME\Downloads

    # 2. Reset permissions to a clean state
    icacls.exe .\stella_keys.pem /reset

    # 3. Disable inheritance (crucial for SSH)
    icacls.exe .\stella_keys.pem /inheritance:r

    # 4. Grant ONLY your user read access
    icacls.exe .\stella_keys.pem /grant:r "$($env:USERNAME):(R)"

    # 5. Connect  to ec2-admin on AWS using the forced identity flag
    ssh -v -o "IdentitiesOnly=yes" -i .\stella_keys.pem ec2-user@54.165.254.202

    # 6. Haven estabilished connection, exit it and cd back into the repo where backend.build.zip is.
    cd "C:\Users\user\Documents\Paul\3-Tier_React.js_Node.js_Mysql_App"

    # 7. Then run this command to Copy backend-build.zip into ec2-admin/deploy
    scp -o "StrictHostKeyChecking=no" -i "C:\Users\user\Downloads\stella_keys.pem" backend-build.zip ec2-user@54.165.254.202:/home/ec2-user/deploy/
    ```

*  Create the push_to_ecr.sh file using nano on Linux ec2 Jump server terminal          
    
    - Create this file push_to_ecr using this command: ```nano push_to_ecr.sh```

    - Copy(Ctrl + C), the push_to_ecr code below into push_to_ecr.sh on ec2-Admin terminal and paste(Ctrl + O), save(Press Enter) and Exit Nano Screen(Ctrl + x) 

    - Make it executable: ```chmod +x push_to_ecr.sh```
            
    - Run it: ```./push_to_ecr.sh``` 

```bash
#!/bin/bash
# This is push_to_ecr.sh - Final Version

# --- SET YOUR VARIABLES HERE ---
REGION="us-east-1"                  # Replace with yours 
ACCOUNT_ID="465828358642"           # Replace with yours
REPO_NAME="3tier-serverless"        # Replace with yours    
ZIP_FILE="backend-build.zip"        # Replace with yours
CLUSTER_NAME="3tier_cluster"        # Replace with yours
SERVICE_NAME="Serverless_task_def-service-rq42pfwa" # Replace with your actual ECS Service name
# ------------------------------

# 1. Go to workspace and clean old extractions
cd /home/ec2-user/deploy
rm -rf extracted
mkdir -p extracted

# 2. Unzip the file you uploaded via SCP
if [ -f "$ZIP_FILE" ]; then
    unzip -o $ZIP_FILE -d extracted/
    cd extracted
else
    echo "Error: $ZIP_FILE not found in /home/ec2-user/deploy. Did you SCP it?"
    exit 1
fi

# 3. Create the Dockerfile automatically
cat <<EOF > Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install --only=production
EXPOSE 3000
CMD ["node", "server.js"]
EOF

# 4. Login to ECR
# This tells Docker how to talk to your AWS ECR Registry
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# 5. Build, Tag, and Push
# FULL_URI="$ACCOUNT_ID.dkr.ecr.$region.amazonaws.com/$REPO_NAME" new
FULL_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME"


echo "Building Docker Image..."
docker build -t $REPO_NAME .

echo "Tagging Image as $FULL_URI..."
docker tag $REPO_NAME:latest $FULL_URI

echo "Pushing Image to ECR..."
docker push $FULL_URI

# 6. TRIGGER FARGATE DEPLOYMENT
# This tells ECS to pull the 'latest' image we just pushed
echo "Updating ECS Service: $SERVICE_NAME..."
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment --region $REGION

echo "DONE! Successfully pushed to ECR and triggered Fargate redeploy."
```


##### Interesting commands used here
```bash
# Check your docker images
docker images

# Remove push_to_ecr.sh
rm push_to_ecr.sh

# Run push_to_ecr script
./push_to_ecr.sh

# Check running containers & if a container is using an image
docker ps -a```  # If container(s) are not using an image so we can delete the image 
docker system prune -a --volumes -f``` # deletes images and image caches on pc/laptop/ec2 locally

# Deletes an image tag latest from repo called 3tier-serverless in ecr
aws ecr batch-delete-image --repository-name 3tier-serverless --image-ids imageTag=latest --region us-east-1``` 

# Docker tags, push a build latest for 3tier-serverless repo in ecr
docker tag 3tier-serverless:latest 465828358642.dkr.ecr.us-east-1.amazonaws.com/3tier-serverless```
docker push 465828358642.dkr.ecr.us-east-1.amazonaws.com/3tier-serverless```

# Update service in a cluster to use latest deployment
aws ecs update-service --cluster 3tier_cluster --service Serverless_task_def-service-rq42pfwa --force-new-deployment --region us-east-1```

# --- RIGHT SIDE TEST: Local Database Connection Check ---
# Goal: Verify the Docker container can talk to RDS using a custom port (8080).
# Test this by visiting: http://<EC2-Public-IP>:8080
docker run -d -p 8080:3000 --name test-backend-direct -e DB_HOST="three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com" -e DB_USER="appuser" -e DB_PASSWORD="SimplePassword123!" -e DB_NAME="react_node_app" 465828358642.dkr.ecr.us-east-1.amazonaws.com/3tier-serverless


# LEFT SIDE TEST (API Readiness): Test if the API responds on the standard port (80) so the Frontend (S3) can fetch data.
# Goal: Ensure your ALB/CloudFront will be able to reach this endpoint.
# Test this by visiting: http://<EC2-Public-IP>/api/books  or curl http://localhost/api/books
docker run -d -p 80:3000 --name test-api-ready -e DB_HOST="three-tier-db-books.c4j4kiq2ck9b.us-east-1.rds.amazonaws.com" -e DB_USER="appuser" -e DB_PASSWORD="SimplePassword123!" -e DB_NAME="react_node_app" 465828358642.dkr.ecr.us-east-1.amazonaws.com/3tier-serverless

curl http://localhost:8080                         # Test API if exposed
docker logs test-backend-direct                           # View output/logs
docker exec -it test-backend bash                  # Shell inside (debug/fix)
```


![alt text](img/11a.scp_keyboard_issue.PNG) 

![alt text](img/11b.scp_successful_copy.PNG) 

![alt text](img/11c.scp_successful_copy.PNG) 

![alt text](img/11d.nano_push_to_ecr.PNG) 

![alt text](img/11e.run_push_to_ecr.PNG) 


#### 12. Load Balancer & Fargate Result 
![alt text](img/12.error_01.PNG)

![alt text](img/12.error_02.PNG) 

![alt text](img/12c.error_correction.PNG) 

![alt text](img/12d.error_correction.png) 

![alt text](img/12e.fargate_success.PNG) 

![alt text](img/12f.fargate_success_02.PNG) 

![alt text](img/12f.fargate_success.PNG) 

![alt text](img/12g.loadbalancer_success_authors.PNG) 

![alt text](img/12g.loadbalancer_success_books.PNG)

![alt text](img/12j.just_docker_test.PNG)




#### 13. S3 + CloudFront

* Update Frontend (in S3)
    - Visit your cloned repo on VsCode
    - Set API base URL to ALB DNS name in .env in frontend directory (e.g., https://my-alb-....elb.amazonaws.com).
    - Generate backend-build.zip:
        * cd frontend/ on bash terminal
        * npm install              # Ensure all React dependencies are there
        * npm run build            # This creates the 'dist' folder (The Actual Website)
        * cd dist/
        * upload ALL to S3 bucket via console or aws s3 copy command: aws s3 sync . s3://paul-3tier-frontend --delete
     

    - Configure CloudFront to to see files in S3
        * Create distribution
        * Add first origin: s3
        * Create and merge second origin & behaviour for alb.

        ![alt text](img/13d.create_distribution_cloudfront_01.PNG) 
        
        ![alt text](img/13d.create_distribution_cloudfront_02.PNG) 
        
        ![alt text](img/13d.create_distribution_cloudfront_03a.PNG) 
        
        ![alt text](img/13d.create_distribution_cloudfront_03b.PNG) 
        
        ![alt text](img/13d.create_distribution_cloudfront_04.PNG) 
        
        ![alt text](img/13d.create_distribution_cloudfront_05.PNG)


        ![alt text](img/14a.merge_by_create_origin.PNG) 
        
        ![alt text](img/14b.merge_by_create_origin.PNG) 
        
        ![alt text](img/14c.merge_by_create_origin.PNG) 
        
        ![alt text](img/14d.merge_by_create_behaviour.PNG) 
        
        ![alt text](img/14e.merge_by_create_behaviour_a.PNG) 
        
        ![alt text](img/14e.merge_by_create_behaviour_b.PNG) 
        
        ![alt text](img/14f.merge_by_create_behaviour_success.PNG)

        One URL: You now have only one CloudFront link to share.
        No CORS Errors: Because the Frontend and Backend share the same "home" (the CloudFront domain), they trust each other perfectly. Security: Your S3 bucket remains private via the Origin Access Control (OAC).

        * Create Error pages

        ![alt text](img/15a.custom_error_pages.PNG) 

        ![alt text](img/15b.403_error_page.PNG) 

        ![alt text](img/15c.404_error_page.PNG) 

        ![alt text](img/15d.error_pages.PNG)


Note: Since your app.js has app.use(cors()); (with no arguments), it is currently set to "Allow All Origins."
Is this okay? Yes, it’s perfect for testing. It means your React app will be allowed to talk to your ALB regardless of what your CloudFront URL is.
Security Tip: Once you go to production, you should change it to app.use(cors({ origin: 'https://your-domain.com' })); to prevent other people from using your API.



#### For a specific CloudFront Origin Access Control (OAC) setup like yours:
Use StringEquals if you want to ensure the request comes from that one specific distribution and nothing else.
Use ArnLike if you might want to allow access from multiple distributions in the future using a wildcard (e.g., arn:aws:cloudfront::465828358642:distribution/*). 

Pro Tip: AWS official documentation for restricting S3 access to CloudFront typically uses StringEquals for AWS:SourceArn when targeting a single distribution to follow the principle of least privilege.

![alt text](img/16a.allows_from_1_distr.PNG) 

![alt text](img/16b.allows_from_more_distr.PNG) 

![alt text](img/16c.copy_policy.png)


And you must create a new invalidation for /* every single time you change your code and sync to S3, this is in case you took 
the change in policy step above or any other changes

![alt text](img/17a.invalidate_01.png) 

![alt text](img/17b.invalidate_02.png) 

![alt text](img/17c.invalidate_03.png)



#### Result

![alt text](img/18a.dashboard_fargat.PNG) 

![alt text](img/18b.book_deleted.PNG) 

![alt text](img/18c.dashboard_aft_delete.PNG) 

![alt text](img/18d.json_cloudfront.PNG)














#### CI/CD Workflow:

Frontend/S3
The Action: Use jakejarvis/s3-sync-action to push your build folder.
The "Boom" Moment: You must trigger a CloudFront Invalidation after the sync, or users will keep seeing the old version cached at the edge.


Backend/Fargate
The Workflow: Git Push → GitHub Action builds Docker Image → Push to ECR → GitHub Action tells ECS to update.
Why? It’s safer. If a build fails, your old Fargate container stays running. With the S3 "sync" method, you risk a "half-synced" state if the network blips.












References:

[Projects World](https://projectworlds.com/a-simple-caterpillar-game-built-in-python-mini-project-with-source-code/)  