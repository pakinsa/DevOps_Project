### Introduction to Platform Engineering

### Open-source, multi-cloud continuous delivery (CD) platform

The most prominent open-source, multi-cloud continuous delivery (CD) platform is Spinnaker. Originally created by Netflix and now maintained by the Continuous Delivery Foundation (CDF), it is designed specifically to handle high-velocity, reliable software releases across diverse infrastructure.

It is frequently categorized as a cornerstone of platform engineering. It supports automated canary analysis, blue/green deployments, and integrates with major cloud providers such as AWS, Google Cloud, Azure, and Kubernetes. 

The CLI Component (spin): As part of the Spinnaker ecosystem, there is a command-line tool named spin (or spin-cli), which is used to manage Spinnaker applications, pipelines, and configuration as code. Netflix developed Spinnaker to handle complex deployments, moving away from their earlier tool, Asgard.


**Key Features of Spinnaker**
Multi-Cloud Support: Deploy applications to AWS, Google Cloud Platform (GCP), Microsoft Azure, Oracle Cloud, and Kubernetes from a single control plane.
Advanced Deployment Strategies: Built-in support for sophisticated release patterns like Canary analysis, Blue/Green (Red/Black) deployments, and rolling updates.
Pipeline Management: Create complex, automated workflows that can include manual approvals, automated testing, and infrastructure triggers (e.g., Git events or Docker image pushes).
Automated Canary Analysis (Kayenta): Integrates with monitoring tools like Prometheus, Datadog, or Stackdriver to automatically judge the health of a new release and trigger rollbacks if metrics degrade. 


**Other Open-Source CD Alternatives** 
While Spinnaker is the dedicated multi-cloud platform, other open-source tools are frequently used for CD in specific environments: 

* *Argo CD / Flux CD:* Highly popular for Kubernetes-native environments using a GitOps approach, where Git serves as the single source of truth for your cluster state.

* *Jenkins:* The "classic" automation server. While not multi-cloud by default, its massive plugin ecosystem allows it to be customized to deploy to almost any cloud provider.

* *GoCD:* Focuses on visualizing complex "Value Stream Maps" and modeling intricate pipeline dependencies.

* *Harness (Community Edition):* Offers a source-available version of its pipeline-centric platform, known for built-in environment and service abstractions.



| Platform | Best For | Core Philosophy |
| :--- | :--- | :--- |
| **Spinnaker** | Large-scale, multi-cloud deployments | Pipeline-centric, heavy cloud abstraction |
| **Argo CD** | Kubernetes-heavy teams | GitOps, declarative state synchronization |
| **Jenkins** | Teams needing extreme customization | Plugin-driven, general-purpose automation |
| **GoCD** | Visualizing complex delivery flows | Modeling value streams and dependencies |



| Tool/Platform | Golden Path Role | Key Focus |
| :--- | :--- | :--- |
| Argo/Flux CD | High | GitOps, Kubernetes-native, standardized Git-driven deployment |
| Harness | High | Unified platform, ease of use, compliance, governance |
| Jenkins/GoCD | Moderate | Flexible pipelines, standardizing the build/test phase |
| Spinnaker | High | Enterprise-grade, multi-cloud, complex pipelines |




While some YouTubers and industry experts use the provocative phrase "DevOps is dead" to highlight a major shift in the industry, most practitioners view it as an evolution rather than a replacement. The core principles of DevOps (collaboration and automation) remain vital, but the way they are implemented is changing through Platform Engineering. 



 
Creating "Golden Paths": Platform engineering aims to create "paved roads" or "golden paths"—standardized, automated workflows that allow developers to deploy code without worrying about underlying infrastructure. Spinnaker was built specifically to provide this at scale.
*Self-Service:* It allows developers to manage their own deployments through a centralized interface, a key goal of an Internal Developer Platform (IDP).
*Abstraction:* It hides the complexity of multi-cloud deployments (AWS, GCP, Kubernetes) so developers don't have to be experts in every cloud provider's API. 

Why the "DevOps is Dead" narrative?
The claim that "DevOps is dead" typically refers to the failure of the "you build it, you run it" model at a large scale. 

*Cognitive Load:* In the original DevOps model, developers were often overwhelmed by having to master Kubernetes, Terraform, security, and monitoring on top of writing features.

*The Shift:* Platform Engineering is the response to this burnout. Instead of every developer doing "ops" work, a dedicated Platform Team builds the "platform" (using tools like Spinnaker) so other developers can move faster with less friction.

*Gartner's Prediction:* Research firms like Gartner have fueled this conversation, predicting that by 2026, 80% of large software engineering organizations will have dedicated platform engineering teams. 

**Comparison: DevOps vs. Platform Engineering**
Feature 	DevOps (Traditional)	Platform Engineering (Modern)
Focus	Culture and collaboration between Dev and Ops.	Building internal products for developers.
Developer Role	Responsible for the whole stack ("You run it").	Focuses on code; uses a self-service platform for Ops.
Goal	Break down silos.	Reduce "cognitive load" and friction.
In summary, DevOps isn't dead—its goals have simply become so complex that we now need Platform Engineering to make those goals achievable at scale. 


**Platform Engineering vs. Serverless**
While both aim to hide infrastructure from developers, they operate at different levels:
Serverless is a cloud architecture model provided by vendors (like AWS Lambda or Google Cloud Functions). It abstracts away the server management entirely for specific types of code.

Platform Engineering is a disciplinary practice within a company. A platform engineer might actually use Serverless as one of the tools in the platform they build, but they also manage other things Serverless doesn't cover, like security policies, complex networking, and custom deployment pipelines (like Spinnaker).

The Difference: Serverless is a product you buy or use from a cloud provider; a Platform is something your company builds (often using cloud tools) to give your developers a tailored "Golden Path". 



### **How Platform as a Service:**

It’s easier to visualize if you think of these tools as three distinct layers of a factory assembly line:

*Backstage (The Front Desk):* This is the user interface where the developer "orders" a new service. Instead of writing code for a database or a pipeline, they fill out a form. Backstage then triggers the other tools to do the heavy lifting.

*Crossplane (The Infrastructure Builder):* This lives inside Kubernetes and manages your cloud resources (AWS, GCP, Azure). When Backstage says, "I need a SQL database," Crossplane is the tool that actually talks to the cloud provider to build it using Kubernetes-style manifests.

*Spinnaker (The Delivery Truck):* Once the app and infrastructure are ready, Spinnaker handles the complex deployment. It excels at sophisticated rollout strategies like Blue/Green or Canary deployments, ensuring the code gets to the users safely.


**Why use them together?**
You use them together to create a complete automation loop:
 - Backstage reduces cognitive load (the "Why").
 - Crossplane standardizes how you manage cloud hardware (the "Where").
 - Spinnaker ensures the software deployment is rock-solid and safe (the "How").


**The Workflow in Action:**
Developer goes to Backstage, selects "Create New Microservice," and hits submit.
 - Backstage creates a Git repo and tells Crossplane to provision a database.
 - Crossplane spins up the RDS instance in AWS.
 - Spinnaker detects the new code and begins a Canary deployment to your Kubernetes cluster.



### The Workflow Comparison

**The Crossplane-Based IDP Stack**
Backstage: The UI / Service Catalog.
Crossplane: Provisioning the AWS infrastructure (RDS/S3).
Spinnaker: Deploying the application code (Canary/Blue-Green).
Argo CD (Optional): Often used alongside Crossplane to sync the infrastructure manifests from Git.



**The Terraform-Based IDP Stack:**
Backstage: The UI / Service Catalog (The Front Door).
Terraform: Provisioning the AWS infrastructure (The "One-Time" Builder).
Spinnaker: Deploying the application code (The Safe Delivery Engine).
GitHub Actions / Jenkins: The Runner (Crucial here—Terraform needs a "home" to run its commands, whereas Crossplane runs itself inside Kubernetes).





| Step | **The Crossplane Way** (Control Plane) | **The Terraform Way** (Infrastructure as Code) |
| :--- | :--- | :--- |
| **Trigger** | Backstage creates a YAML file in Git. | Backstage creates .tf files in Git. |
| **Execution** | **Crossplane** (inside K8s) sees the file and starts building in AWS immediately. | **GitHub Actions** sees the commit, runs `terraform apply`, and builds in AWS. |
| **Drift** | If someone deletes the DB in AWS, Crossplane **automatically recreates it**. | If someone deletes the DB, nothing happens until the **next manual CI run**. |
| **State** | State is stored as "Objects" inside your Kubernetes cluster. | State is stored in an **S3 Bucket** (statefile) that you must manage. |
| **Complexity** | Higher initial setup (requires K8s expertise). | Lower barrier to entry (everyone knows Terraform). |




**Which one should you choose?**

- *Choose Crossplane*: if you want a "true" platform where your infrastructure and your app (Spinnaker) live in the same Kubernetes ecosystem. It feels more like a "product."

- *Choose Terraform*: if your team already has 100+ Terraform modules and you don't want to rewrite them. It is the safer, industry-standard choice for most companies starting their IDP journey.











The following projects are designed to demonstrate this transition by focusing on abstraction, self-service, and the creation of "Golden Paths". 
Platform Engineering
Platform Engineering
 +2
1. The "Golden Path" Service Template
Instead of manually creating pipelines for every new app, build a reusable template that automates everything. 
YouTube
YouTube
 +1
The Project: Create a "Service Scaffolder" (using Backstage Software Templates) that allows a developer to fill out a form and automatically:
Creates a new GitHub repository with boilerplate code (e.g., a Go or Python microservice).
Provisions a pre-configured CI/CD pipeline (GitHub Actions or ArgoCD).
Registers the service in a central software catalog.
Why it's Platform Engineering: It reduces the developer's "cognitive load" by providing a pre-approved, secure starting point. 

2. Self-Service Infrastructure "Vending Machine"
Move away from ticket-based infrastructure requests. 
Port.io
Port.io
The Project: Build a self-service portal (or a CLI tool) where developers can provision common resources—like an S3 bucket or a Postgres database—without admin intervention.
Tech Stack: Use Terraform modules or Crossplane to define these resources as standardized "claims".
Why it's Platform Engineering: You are creating a "vending machine" for infrastructure, ensuring that whatever a developer spins up is already compliant with company security standards. 
Platform Engineering
Platform Engineering
 +4
3. Automated Ephemeral Environments
Help developers test their code in production-like environments before merging. 
Octopus Deploy
Octopus Deploy
The Project: Set up a system that automatically spins up a temporary, isolated environment (using Kubernetes namespaces) every time a developer opens a Pull Request.
Tech Stack: Use ArgoCD ApplicationSets or vcluster to manage these dynamic environments.
Why it's Platform Engineering: It solves a common "DevOps" bottleneck where developers have to wait for a shared staging environment to be free. 
Northflank
Northflank
 +2
4. Centralized Developer Portal (IDP)
Pull all your disparate tools into a single "pane of glass". 
YouTube
YouTube
 +1
The Project: Deploy and configure Backstage as an Internal Developer Portal (IDP).
Key Features to Include:
Software Catalog: A searchable list of all running microservices and who owns them.
TechDocs: Centralized, "docs-as-code" documentation that lives with the source code.
Kubernetes Plugin: Allow developers to see their pod status and logs directly in the portal without using kubectl.
Why it's Platform Engineering: It provides a single interface for developers to discover and manage their own services. 
platformengineering.com
platformengineering.com
 +5
5. Automated "Guardrails" and Policy-as-Code
Instead of manually reviewing every change, automate your compliance. 
Octopus Deploy
Octopus Deploy
 +1
The Project: Integrate Open Policy Agent (OPA) or Kyverno into your Kubernetes cluster to automatically reject any deployment that doesn't meet security standards (e.g., running as root).
Why it's Platform Engineering: You are building security into the "platform" itself, so developers can't accidentally make mistakes. 
Eficode.com
Eficode.com
 +1
Would you like to focus on the Backstage setup or the Infrastructure as Code automation first?