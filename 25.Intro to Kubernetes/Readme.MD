# INTRODUCTION TO Kubernetes

### Intro to Kubernetes 
**Introductory Video on Kubernetes:**  https://youtu.be/TlHvYWVUZyc?si=OpAzR-JPnNmqiFPu 



### **Architectural Comparison**
Building a Kubernetes cluster on EC2 (Self-Managed) versus using Amazon EKS (Managed) is a choice between manual engineering and automated orchestration. The architectural difference lies primarily in who owns the "brain" (Control Plane) of the cluster. 

 

**1a. Self-Managed Cluster (Kubernetes on EC2)**
In this setup, you are the cloud provider. You must manually design and connect every component. 

The Control Plane (Master): You must provision at least 3 EC2 instances to run the API Server, Scheduler, etcd (the database)  & Controller Manager all in each server in 3 azs at once.

*API Server:* The "Front Desk." It handles all communication.
*etcd:* The "File Cabinet." It stores all the cluster data.
*Scheduler:* The "Dispatcher." It decides which worker node should run a new pod.
*Controller Manager:* The "Watchman."

The Controller Manager is the part that constantly checks the cluster's health. For example, if you tell Kubernetes "I want 3 copies of this app," and one crashes, the Controller Manager notices the count is now 2 and tells the Scheduler to start a new one to get back to 3. It "manages" the "controllers" that handle node health, pod counts, and endpoints.

High Availability (HA): You must manually set up a Load Balancer in front of these masters and ensure they are spread across different Availability Zones (AZs).

Networking & Security: You are responsible for installing the Container Network Interface (CNI) for pod communication, managing security patches for the OS, and rotating encryption certificates.

Complexity: High. You must handle "Day 2" operations like manually upgrading the Kubernetes version across all nodes without crashing your apps. 


**1b. How to create and Join Worker nodes in Self-Managed**
There is no "fixed" number like the 3 required for a High Availability Control Plane. Instead, the number of worker nodes depends on your workload. 

Minimum for Reliability: It is highly recommended to have at least 2 worker nodes spread across different Availability Zones. This ensures that if one server (or one AZ) fails, your application keeps running on the other.

Scaling: In a real production environment, you might have dozens or even hundreds of worker nodes. These are often managed by an Auto Scaling Group that adds or removes servers based on how much CPU or memory your apps are using. 

In building this yourself (Self-Managed), you would have to manually install the kubelet, Docker/Containerd, and networking tools on every EC2 instance, then manually "join" them to the master. 



**2a. Managed Cluster (Amazon EKS)**
AWS provides the Control Plane as a black-box service. 

The Control Plane: AWS runs the API Server and etcd in an AWS-managed VPC that you cannot see. It is automatically highly available across multiple AZs.

Worker Nodes: You only manage the "Workers" (the EC2s that actually run your code). You can even use EKS Managed Node Groups where AWS handles the patching and updates for these nodes too.

Integration: EKS comes pre-integrated with AWS IAM for security and VPC for networking.

Complexity: Medium. While Kubernetes itself is complex to learn, the infrastructure setup is reduced to a few API calls or console clicks.

**2b. How to create and Join Worker nodes**
In a managed service like Amazon EKS, you use Managed Node Groups:

- *Automation:* You just tell EKS, "I want 3 worker nodes of type t3.medium," and EKS automatically provisions the EC2 instances, installs all the necessary Kubernetes software, and connects them to the Control Plane for you.

- *Fargate (Serverless):* You can even choose AWS Fargate, where you don't manage servers at all; AWS simply runs your pods on demand without you seeing any EC2 instances in your account. 

In Managed Cluster(EKS): You simply define a Node Group or Fargate Profile in the AWS Console or CLI, and AWS automatically provisions the EC2 instances, installs the kubelet and container runtime, and auto-joins them to the Control Plane for you. Creating and joining worker nodes is much simpler in EKS.



**Key Difference Summary:**
Self-Managed: You provision EC2s - Install K8s software - Manually join cluster.
Managed (EKS): You define a "Node Group" - EKS handles the EC2 setup, software,  - and joining automatically

```markdown
### Setup Summary Table

| Feature | Self-Managed (EC2) | Amazon EKS |
| :--- | :--- | :--- |
| **Control Plane** | You build/run on 3+ EC2s | AWS manages it entirely |
| **Etcd (Database)** | You must backup & scale it | AWS handles it |
| **Patching** | Manual OS & K8s updates | Automated or simplified |
| **Setup Time** | Days (highly error-prone) | ~10–15 minutes |
| **Setup Tool** | kubeadm, kops, or manual | AWS Console, eksctl, or Terraform 
```

The Bottom Line: On EC2, you are managing servers; on EKS, you are managing an API. Most teams choose EKS because the architectural complexity of keeping a manual cluster stable is a full-time job that doesn't add value to the actual application.



**Structure**
You cannot deploy a Kubernetes app until you have a cluster to put it in.
Step 1: Create the Cluster (The "House").
Step 2: Deploy the App (The "Furniture").


**Isolation (The Golden Rule):** A key principle of microservices is that each service should own its own data. If Service A's database goes down, Service B should still be able to function.

**Technology Choice:** For instance Your "Payment Service" might need a strict SQL database (like PostgreSQL), while your "Recommendation Engine" might need a NoSQL database (like MongoDB). The master node's database is fixed and cannot be changed to fit your app's needs.


**Database Approaches:** When you deploy a microservice, you typically do one of two things for its database: 
    - **External Service:** Use a managed cloud service like Amazon RDS or Azure SQL. Your microservice running in the cluster just connects to it over the network.
    - **StatefulSets:** Run the database inside your Kubernetes worker nodes as a "StatefulSet" with its own dedicated storage disk (Persistent Volume). Also known as Application's databases.

    The industry standard—especially for production environments—is using Managed Cloud Databases (outside the cluster).
    While Kubernetes is amazing for stateless apps (like your web servers), it is famously difficult to manage for stateful data (databases) Unless: 

        * Development/Testing: It’s cheaper and faster to spin up a "disposable" database container for a quick test.
        * Edge Computing: If you are running hardware on-site (like a factory floor) and don't have access to a cloud provider.
        * Advanced Scaling: Huge tech companies with dedicated "Platform Teams" might use Kubernetes Operators (like Vitess or PGO) to run massive database fleets, but this is the exception, not the rule.

    - **The Verdict:** Most companies use EKS for the microservices and RDS/DynamoDB for the data.




    In a professional microservices architecture, you follow the "Database-per-Service" pattern. This ensures that each service is completely independent and "owns" its data. 

**Microservices to RDS Architecture**
The diagram below shows how three different microservices in an Amazon EKS cluster connect to their own dedicated Amazon RDS instances.

```markdown
architecture-beta
    group vpc[AWS VPC]
    
    group eks[EKS Cluster] in vpc
    service microA[Microservice A] in eks
    service microB[Microservice B] in eks
    service microC[Microservice C] in eks

    group rds_tier[RDS Database Tier] in vpc
    service rdsA(database)[RDS Instance A] in rds_tier
    service rdsB(database)[RDS Instance B] in rds_tier
    service rdsC(database)[RDS Instance C] in rds_tier

    junction jA in vpc
    junction jB in vpc
    junction jC in vpc

    microA:R -- L:jA
    jA:R -- L:rdsA
    
    microB:R -- L:jB
    jB:R -- L:rdsB
    
    microC:R -- L:jC
    jC:R -- L:rdsC
```

* **How they connect in practice**
*Connection Strings:* Each microservice is configured with a unique Database Endpoint (e.g., db-a.cluster-xyz.us-east-1.rds.amazonaws.com).

*Secrets Management:* Instead of hardcoding passwords, microservices retrieve credentials at runtime from AWS Secrets Manager.

*Network Security:* You configure Security Groups so that only the EKS worker nodes are allowed to talk to the RDS instances on the database port (e.g., 5432 for PostgreSQL). 


**How they are deployed**
The industry standard is to deploy these databases as Code, not manually via the console. 

* *Terraform/IaC:* You write a single script that defines both the EKS cluster and all required RDS instances. This ensures that if you need to replicate your "Production" environment into a "Staging" environment, you can do it perfectly with one command.

* *Logical vs. Physical Separation:*
   
   - *High Isolation (Common):* Each service gets its own physical RDS Instance, or a Serverless option like Aurora Serverless. This way, each service scales independently, stays secure, and doesn't "leak" problems into other services. If Service A's database has a massive traffic spike, it won't slow down Service B. 

   - *Cost Optimized (Small Scale):* Multiple services share one physical RDS Instance but have separate Logical Databases inside it (e.g., db_orders and db_users on the same server). But this is a "technical debt" trap. While it saves money in the short term, most experienced architects advise against it.
        
        - *When is it actually used?*
            * Early-stage Startups: When you have $0 revenue and don't want to pay $50/month for five different RDS instances.
            * Development/QA Environments: Where performance doesn't matter and you just want to keep the AWS bill low.




### 4 Main Ways to Deploy Database in Kubernetes

When deploying a database in the Kubernetes ecosystem, you generally choose between four main patterns. Each balances "control" versus "ease of use" differently. 

**1. Managed Database Service** (e.g., AWS RDS, Google Cloud SQL)
Technically, this is not inside Kubernetes. You create the database via your cloud provider and your Kubernetes apps connect to it over the network.

*How it works:* The cloud provider manages the underlying VMs, backups, patching, and high availability.

*Unique Difference:* It is the lowest complexity option. You don't have to worry about disks failing or database replication logic; the cloud provider handles it. The downside is higher cost and potential "vendor lock-in."


2. **Kubernetes Stateless Deployment** (The "Wrong" Way for DBs)
A standard Deployment is designed for stateless apps like web servers or APIs. 

*How it works:* Pods are treated as interchangeable and have random names (e.g., web-78f9). If a pod dies, a new one is created with a completely different name.

*Unique Difference:* If you try to run a database here, all replicas typically try to share the same disk, which leads to "Multi-Attach" errors or data corruption because standard databases aren't built to share a single physical disk across multiple instances. It is generally not recommended for databases. 


**3. Kubernetes StatefulSet** (The "Right" K8s Way)
This is the standard Kubernetes object designed specifically for databases. 

*How it works:* Unlike regular pods, StatefulSet pods have a sticky identity (e.g., mysql-0, mysql-1) that remains the same even if the pod restarts. Each pod gets its own dedicated Persistent Volume (disk) that stays attached to that specific identity.

*Unique Difference:* It provides the stable network ID and unique storage required by databases to prevent data corruption. However, you are still responsible for configuring the actual database replication and backups yourself. 



**4. Kubernetes Operators (The "Pro" K8s Way)**
An Operator is a software extension that acts like a "human administrator" inside your cluster.

*How it works:* You install an operator (like CloudNativePG for Postgres) and tell it "I want a 3-node cluster." The operator then automatically creates the StatefulSets directly inside your Kubernetes cluster, manages the replication, performs backups to S3, and even handles automatic failover if the primary node dies.

*Unique Difference:* It combines the control of running in Kubernetes with the automation of a managed service like RDS. It uses StatefulSets under the hood but automates the "complexity".

The Operator is the "Kubernetes-Native" version of RDS. It brings RDS-like automation (backups, failover, scaling) inside your cluster so you aren't tied to a specific cloud provider's proprietary database service.




**Database Deployment Patterns in Kubernetes Table**

| Feature | Managed Service (e.g., RDS) | StatefulSet (Standard K8s DB) | Stateless Deployment (Standard) | Kubernetes Operator (Pro) |
| :--- | :--- | :--- | :--- | :--- |
| **Industry Term** | **Managed / DBaaS** | **Stateful Workload** | **Stateless Workload** | **Automated Operations** |
| **Location** | **Outside K8s** (Cloud) | **Inside K8s** | **Inside K8s** | **Inside K8s** |
| **Storage** | Managed by Provider | 1 Unique Disk per Pod | Shared/Ephemeral Disk (Bad) | Automated by Operator |
| **Pod Names** | N/A | Predictable (`db-0`) | Random (`db-xy12`) | Predictable (Managed) |
| **Complexity** | **Low** (Hands-off) | **High** (Manual config) | **Low** (But high risk) | **Medium** (Automated logic) |
| **Best For** | Production (AWS/GCP/Azure) | Learning / Single-node DBs | **Web APIs / Microservices** | Production (Self-hosted/Cloud) |






