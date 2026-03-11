# Understanding Application Architectural Patterns and Deployment Strategies


### **Understanding Application Architectural Patterns(i.e Pattern of Design):**
* **Monolith Application:** This describes a software application designed as a single, indivisible unit where all functions 
   are contained in a single environment. It's a traditional approach that is easy to develop initially but can be hard to scale.
      
    - Contains: A single codebase/folder containing the UI, backend logic, and data access code (e.g., a desktop game or a simple WordPress site).
    - Examples: 
        - Simple Node.js Monolith — https://github.com/trotrindonesia/basic-project-express-monolith  
        - https://github.com/VinodVerma7584/monolithapp-nodejs 
        - https://github.com/rat9615/simple-nodejs-app 
            
            
    
* **3-tier Application:** A well-established pattern that organizes applications into three distinct logical tiers: 
    the presentation (user interface), application (business logic), and data (database) tiers.
    
    - Contains: Frontend, Backend, & DB folders
    - Examples:
       - https://github.com/garden-io/web-app-example  
       - https://github.com/aws-samples/aws-three-tier-web-architecture-workshop 


* **Microservices Application:** An architectural style that structures an application as a collection of small, independent, 
    loosely coupled services, each performing a single business function. They communicate via APIs.
    
    - Contains: User Service folder, Payment service, Shipping service & Frontend
    - Examples: 
        - https://github.com/VictoriousVipin/nodejs-microservices-kubernetes
        - https://github.com/ewolff/microservice-kubernetes 
    
    
* **Function Application (Serverless):** This model allows developers to focus on write small snippets of code as functions (for AWS Lambda) that 
    trigger based on specific events, without managing the underlying server infrastructure.
    
    - Contains: Individual code files for specific tasks (e.g., processImage.js, sendEmail.py), a serverless.yml or SAM template for deployment, or Functions folder and trigger configurations HTTP, S3, or Database events.
    - Examples:
        - https://github.com/kemanedonfack/aws-serverless-web-application 
        - https://github.com/serverless/examples: Serverless Framework Examples — Dozens of small function-based projects for AWS, Azure, and Google Cloud.




### **Understanding different method of deployments:**

- **A Monolithic Application can be deployed on:**
    * **A Single Server:** As a monolithic deployment where the code and database live together.
        - Using User Data method: Scripted installation on a single EC2 instance.
        - Using Containerization method: Running the entire app in one Docker container on a single host behind an ALB (e.g., AWS ECS on EC2 or Fargate) 

    * **On Multiple Servers:** Distributed horizontally for high availability (no code refactoring usually required).
        - Using User Data method: Multiple EC2 instances behind an External Application Load Balancer (ALB).
        - Using Containerization method: Multiple containers (e.g., AWS ECS with EC2) behind an ALB.


- **3-tier Application can be deployed on:**
    
    * **A Single Server:** As a monolithic deployment using Port Separation (e.g., Frontend on port 80, Backend on 3000, DB on 5432).
    
    * **Servers (EC2):** Using User Data method to install separate tiers on different instances. Typically uses an External ALB for the web tier and an Internal ALB for the app tier.
    
    * **Serverless (Fargate):** Using Containerization method where AWS manages the underlying server. Each tier runs in its own Fargate service behind respective load balancers (External ALB for web, internal ALB for app). However, new approaches will route web tier to s3-cloudfront.


- **Microservices Application can be deployed on:**
    
    * **A Single Server:** Using Docker Compose to run all services on one host (mostly for development/testing — defeats independent scaling benefits).
    
    * **Servers (EC2):** As a containerized deployment managed manually or via scripts, using an API Gateway as the entry point.
    
    * **Serverless (Fargate):** As a containerized deployment where each service is a separate Fargate Task. Use External ALB for routing or AWS Cloud Map for service discovery.
    
    * **Kubernetes (EKS):** As a containerized and orchestrated deployment. Uses an Ingress Controller (often ALB Ingress) to route traffic to hundreds of independent services.
    
    * **Serverless Functions:** As function deployment without containers or orchestration (e.g., AWS Lambda functions per microservice, triggered by API Gateway). Each microservice becomes one or more Lambda functions.


**Quick tip on Load Balancers (ALB/NLB):**
- Single-server setups → Optional (direct access via security groups/Route 53).
- Multi-instance / production / scaling → Strongly recommended / usually required for traffic distribution, health checks, high availability across AZs, and zero-downtime deployments.




| Pattern | Deployment Method | Scaling Type | Load Balancer (LB) Type | Role of Load Balancer |
| :--- | :--- | :--- | :--- | :--- |
| **Monolith** | Virtual Machine (EC2) or Container | Vertical or Horizontal | External Application Load Balancer (ALB) | Sits in front of a pool of identical monolith servers. Every request goes to the same pool. |
| **3-Tier** | Separate VMs/Containers for each Tier | Tier-based (Scale Web and App tiers independently) | External ALB + Internal ALB | External: Routes users to Web tier. Internal: Routes Web tier to App tier (Logic), hiding the App tier from the public internet. |
| **Microservices**| Kubernetes (EKS) or ECS Fargate | Service-based (Scale only specific services) | API Gateway + Internal Service Mesh | Gateway: Routes by URL path (e.g., /pay → Payment Service). Service Mesh: Manages complex traffic between internal services. |
| **Function** | AWS Lambda / Azure Functions | Event-based (Scale per execution) | API Gateway or Lambda Function URL | Triggers the specific function based on an HTTP request or event (like an image upload). |





#### References:

- Shopify (Original version) — Before migrating parts to microservices, Shopify famously ran as a massive Ruby on Rails monolith

- https://dev.to/jonl/build-a-simple-monolith-backend-with-nodejs-and-typescript-46ld#:~:text=Setup%20in%205%20Steps.%20git%20clone%20https://github.com/jonilabss/boelpart%2Dnodejs%2Dmonolith%2Dts.git%20cd%20boelpart%2Dnodejs%2Dmonolith%2Dts%20yarn%20install%20yarn%20dev.