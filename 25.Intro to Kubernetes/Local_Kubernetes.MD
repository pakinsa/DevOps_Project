# Local Kubernetes with MiniKube


### Intro to Kubernetes 

1. Setting up minkube
    * install minikube -windows/linux/macOs
    * install docker on minikube
    * Check Status: minikube status.

2. Working with Kubernetes node
    * minikube start
    * minikube dashboard (launches a web UI)
    * minikube stop
    * minikube delete
    * kubectl get nodes
    * kubectl describe nodes <node-name>

Note: Which ever platform you use Kubernetes, kubectl is
the native command line tool used to deploy applications in Kubernetes

3. Working with Kubernetes pods
    * Get pods command: ```kubectl get pod A```
    * Inspect a pod: ```kubectl describe pod <pod-name>
    * Delete a Pod: ```kubectl delete pod <pod-name>

Note: Pods are the smallest deployable units in kubernetes.
Pods can run several containers at the same time.

The power of Kubernetes is the ability to manage several containers in a Pod,
several pods in a node, & several nodes in a cluster. That is why Kubernetes is
called Orchestrator tool.



##### Let's Quickly talk about YAML

A YAML file is neither declarative nor imperative on its own—it is just a data format. Whether it "becomes" declarative depends entirely on the tool that reads it. 


Why YAML itself isn't declarative
It’s just a container: YAML is a data serialization language, similar to JSON or XML, designed to store and transmit structured data.
No "verbs" or "logic": YAML does not have built-in executable commands, loops, or logic. It is a passive list of keys and values. 

 
*When it is Declarative*
It is declarative when used by a system that interprets the data as a "desired state." 

Example: In Kubernetes, you provide a YAML file saying replicas: 3. You don't tell Kubernetes how to start the servers; you just "declare" that 3 must exist. Kubernetes handles the rest. 

 +2
*When it is Imperative (or Procedural)*                                                                                                                               
It can be used to list a series of steps to be followed in order, which is effectively imperative. 
Example: In GitHub Actions or certain Ansible Playbooks, the YAML file might list a sequence of shell commands to run one after another. In this case, the YAML is acting more like a script, focusing on the "how" (the steps) rather than just the final "what".



4. Working with Kubernetes Resources

In Kubernetes there are 2 Main Types of YAML in Kubernetes, especially in a standard "deploy and access" workflow, you typically need:

*Deployment YAML:* To run and manage the Pods (the application).

*Service YAML:* To provide a stable Network IP/DNS so users can reach those Pods. 


**Deployment YAML File**
A Cluster must already exist before you can use a Deployment file. You create the cluster using tools like ```kubeadm```, ```Minikube```, or cloud services like AWS EKS, ```eksctl``` or GCP ```gcloud```

A Deployment manages Pods (your application instances) inside that existing cluster. 
Think of a Deployment as the Manager of your application's lifecycle. Here is the breakdown:

*Desired State (The Blueprint):*
It states how you want your app to look. You define the "Desired State"—for example, "I want exactly 3 copies of my Nginx web server running at all times".

*Self-Healing:*
The Deployment Controller constantly monitors your pods. If a pod crashes or a node fails, the Deployment automatically starts a new one to match your "Desired State".

*Scaling:*
You can change one number in the YAML (e.g., replicas: 10), and the Deployment will instantly spin up more copies of your app to handle traffic.

*Rolling Updates & Rollbacks:*
When you have a new version of your app, the Deployment replaces the old pods with new ones one-by-one so there is zero downtime. If the new version is buggy, you can "undo" the change and roll back to the previous version instantly.

*ReplicaSets (The Engine):*
Technically, a Deployment creates and manages a ReplicaSet behind the scenes. The ReplicaSet is the component that actually ensures the correct number of pods are running. 

Example of deployment file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: 3-tier-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: 3-tier-app
  template:
    metadata:
      labels:
        app: 3-tier-app
    spec:
      containers:
      - name: 3-tier-app
        image: YOUR-IMAGE-NAME-HERE
        ports:
        - containerPort: 8080
```


**Service YAML File**
Once your application is deployed by deployment file, it needs a way to be accessed by outhers parts of kuberntes and the public. That is why we use the keyword *Service*.  

3 commonly used Service types in Kubernetes are:

    - ClusterIP: 
    - NodePort: 
    - LoadBlancer: 


There are more types of service: https://kubernetes.io/docs/concepts/services-networking/service/


There are four official Service types defined in the Kubernetes Service specification, plus a fifth special configuration called a Headless Service. 
While your initial definitions were accurate for the three most common types, here is the complete set with refined explanations and technical details:


* **1. ClusterIP (Default)**
*Purpose:* Exposes the Service on a cluster-internal IP address.
*Accessibility:* Only reachable from within the cluster. This is the standard for internal microservices, such as a backend API talking to a database.
*Key Detail:* If you do not specify a type in your YAML, Kubernetes defaults to ClusterIP. 


```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-internal
spec:
  type: ClusterIP
  selector:
    app: backend-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```



**2. NodePort**
*Purpose:* Exposes the Service on each Node's IP at a static port (typically in the 30000–32767 range).
*Accessibility:* Reachable from outside the cluster by requesting <NodeIP>:<NodePort>.
*Key Detail:* A NodePort Service automatically creates a ClusterIP behind the scenes to route traffic internally once it hits the node. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-nodeport
spec:
  type: NodePort
  selector:
    app: backend-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30007 # Must be between 30000-32767
```


**3. LoadBalancer**
*Purpose:* Exposes the Service externally using a cloud provider's load balancer (like AWS ELB, Azure ALB, or GCP LB).
*Accessibility:* Reachable externally through a dedicated External IP provided by the cloud platform.
*Key Detail:* This is the most common way to expose production applications. It automatically sets up both a NodePort and a ClusterIP to facilitate the full routing path. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-lb
spec:
  type: LoadBalancer
  selector:
    app: backend-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```



**4. ExternalName**
*Purpose:* Maps a Service to a DNS name (e.g., my.database.example.com) rather than using selectors to find pods.
*Accessibility:* Used by internal pods to reach external resources.
*Key Detail:* It does not proxy traffic. Instead, it returns a CNAME record so your application can talk to an external database as if it were a local service. 


```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: prod.database.example.com
```


**5. Headless Service (Special Case)**
*Purpose:* Created by setting clusterIP: None in a ClusterIP service.
*Accessibility:* Reachable via DNS, but instead of returning one "Service IP," it returns the direct IPs of all underlying pods.
*Key Detail:* Essential for StatefulSets (like Kafka, MongoDB, or Postgres clusters) where you need to communicate with a specific pod rather than a random one in a pool. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: stateful-db-headless
spec:
  clusterIP: None # Required for Headless
  selector:
    app: database-pods
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```



```markdown
| Service Type | Accessibility | Implementation | Common Use Case |
| :--- | :--- | :--- | :--- |
| **ClusterIP** | Internal Only | Internal Virtual IP | Backend-to-Backend communication |
| **NodePort** | External | Static port on all nodes | Simple demos or non-cloud clusters |
| **LoadBalancer**| External | Cloud provider LB | Production-grade web traffic |
| **ExternalName**| Outbound | CNAME DNS record | Connecting to external APIs or RDS|
| **Headless** | Internal | Direct Pod IPs | Databases and Stateful clusters |
```


##### How to Choose the Right Service Type
Think of it as "reachability" ladder:

* ClusterIP: Use this for 90% of your internal apps. If your Frontend needs to talk to your Backend, or your Backend needs to talk to a Cache, use this. It keeps traffic safe inside the cluster.

* NodePort: Use this for testing or if you are running Kubernetes on your own "bare metal" servers (no cloud provider). It’s rarely used for high-traffic production because it’s less secure and harder to manage.

* LoadBalancer: Use this for public-facing apps in the cloud (AWS, Azure, Google). If you want a website reachable by the whole world (e.g., www.myapp.com), this is the gold standard.

* ExternalName: Use this when your app is inside Kubernetes, but your Database is outside (like an RDS instance on AWS). It lets your pods talk to the external DB using a simple internal nickname.

* Headless: Use this for Databases/Stateful apps where the pods need to talk to each other specifically (like a Leader and a Follower) rather than just any random pod.


Below is an example both Deployment yaml and Service yaml connected together.

```YAML
# 1. THE DEPLOYMENT (The "Manager")
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web-app
  labels:
    app: web-app  # The label for the Deployment itself
spec:
  replicas: 3     # Run 3 copies of my app
  selector:
    matchLabels:
      app: web-app # Deployment looks for pods with this label
  template:
    metadata:
      labels:
        app: web-app # These labels are applied to the Pods
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest # The image from Docker Hub or ECR
        ports:
        - containerPort: 80

---
# 2. THE SERVICE (The "Entrance")
apiVersion: v1
kind: Service
metadata:
  name: my-web-service
spec:
  type: LoadBalancer # Gives us an External IP (if on EKS/GCP/Azure)
  selector:
    app: web-app     # This MUST match the labels in the Deployment above!
  ports:
    - protocol: TCP
      port: 80       # The port the user types into the browser
      targetPort: 80 # The port the app is actually listening on inside the container
```



5. Networking in Kubernetes

Networking In Kubernetes

Networking refers to the mechanisms and configurations that allow communication between different components (pods, services, and other resources) within a Kubernetes cluster. Kubernetes provides a flexible and powerful networking model to enable seamless interaction between containers and services, whether they are running on the same node or across different nodes in a cluster.

Some key aspects of networking in Kubernetes

Pod Networking: Containers within a pod share the same network namespace, allowing them to communicate with each other using localhost. This enables tight coupling between containers within the same pod.

Service Networking: Kubernetes Services provide a way to expose a group of pods as a single, stable network endpoint. Services have an associated 
Cluster IP that allows other pods to communicate with the service. Services can be exposed internally within the cluster or externally to the outside world.

Pod-to-Pod Communication: Pods communicate with each other using their individual IP addresses. Kubernetes ensures that pods can reach each other directly, regardless of the node they are running on, by using an overlay network. Ingress: Ingress is a Kubernetes resource that allows external access to services within the cluster. It defines rules for routing external HTTP and HTTPS traffic to different services based on the host or path. Ingress controllers manage the actua routing and traffic flow.

Network Policies: Kubernetes Network Policies define rules for controlling the communication between pods. These policies allow administrators to specify how pods can communicate with each other, enhancing security within the cluster. 

Container Network Interface (CNI): Kubernetes relies on 
Container Network Interfaces to implement networking solutions. CNIS provide a standardized interface for networking plugins to integrate with Kubernetes, allowing for flexibility and choice in networking implementations.


Let's get our hands on pod networking in Kubernetes by deploying a pod with multiple containers, showcasing how they share the same network namespace and can communicate with each other using 'localhost". Here's a step-by-step guide using Kubernetes and "kubect1":




1. Create a Multi-Container Pod YAML file (e.g., `multi-container-pod.yaml`); and paste the snippet below

```yaml
apiVersion: v1
kind: Pod
metadata:
name: multi-container-pod
spec:
containers:
- name: container-1
image: nginx: alpine
- name: container-2
image: busybox command:
'/bin/sh' - '-c'
-'mkdir -p /usr/share/nginx/html && while true; do echo "Hello from Container 2" >> /usr/share/nginx/html/index.html; sleep 10; done'
```

Explanation of the yaml snippet above

*apiVersion: v1:* Specifies the Kubernetes API version for the object being created, in this case, a Pod.
*kind: Pod:* Defines the type of Kubernetes resource being created, which is a Pod. Pods are the smallest deployable units in Kubernetes and can host 
one or more containers. 
*metadata:* Contains metadata for the Pod, including the name of the Pod, which is set to "multi-container-pod."
*spec:* Describes the desired state of the Pod.
*containers:* Specifies the containers configuration for the Pod.
   - *name: container-1:* Defines the first container in the Pod with the name "container-1" and uses the "nginx: alpine" image.
   - *name: container-2:* Defines the second container in the Pod with the name "container-2" and uses the "busybox" image. Additionally, it specifies a command to create an HTML file in the Nginx directory and continously appends "Hello from every container2" to it every 10s.



The pod has two containers - one running the Nginx web server and another running BusyBox with a simple command to continuously append "Hello from Container 2" to the Nginx default HTML file. 

2. Apply the Pod Configuration:
```kubectl apply -f multi-container-pod.yaml```

3. Check Pod Status and Logs:

```yaml
kubectl get pods
kubectl logs multi-container-pod -c container-1
kubectl logs multi-container-pod -c container-2
```
You'll observe that both containers are running within the same pod, and they share the same network namespace. The Nginx container serves its default page, and the BusyBox container continuously updates the HTML file.

```bash
PS C:\Users\ridwan\Documents\ayo\my-nginx-yaml> kubectl apply -f multi-container-pod.yaml pod/multi-container-pod created
PS C:\Users\ridwan\Documents\ayo\my-nginx-yaml> kubectl get pods NAME
READY STATUS
RESTARTS
multi-container-pod 0/2 ContainerCreating 0
AGE 45
PS C:\Users\ridwan\Documents\ayo\my-nginx-yaml> kubectl get pods NAME
READY STATUS
RESTARTS AGE
11s
multi-container-pod 2/2 Running Ө
PS C:\Users\ridwan\Documents\ayo\my-nginx-yaml> kubectl logs multi-container-pod -c container-1 /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/18-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf /docker-entrypoint.sh: Sourcing/docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching/docker-entrypoint.d/28-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/38-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```





4. Access Nginx from BusyBox Container:

```kubectl exec -it multi-container-pod -c container-2 /bin/sh```

```bash
PS C:\Users\ridwan\Documents\ayo\my-nginx-yaml> kubectl exec -it multi-container-pod -c container-2 /bin/sh
/ #
/ # cd /usr/share/nginx/html
/usr/share/nginx/html # cat index.html
Hello from Container 2
Hello from Container 2
Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 Hello from Container 2 /usr/share/nginx/html # /usr/share/nginx/html # /usr/share/nginx/html #
```

Now, within the BusyBox container, you can use tools like curl or wget to access http://localhost and see the Nginx page.
This demonstrates how containers within the same pod can communicate with each other using "localhost".



Note: Minikube is typically a single-node cluster, meaning
you have one worker node. It is often used for local development
and testing, not in production. In production you use Amazon EKS(eksctl)  OR 
Google Kubernetes Engine GKE (gcloud) OR Azure AKS (az).



This is particularly useful for debugging, experimenting, and developing
applications in a controlled environment.






Capstone project
4. Kubernetes on local , fd capstone project.

Phase 1: Basic Frontend Application with Docker and Kubernetes

1. Hypothetical Use Case
You are developing a simple static website (HTML and CSS) for a company's landing page. The goal is to containerize this application using Docker, deploy it to a Kubernetes cluster, and access it through Nginx.

2. Tasks

Task 1: Set up your project
• Create a new project directory.
⚫Inside the directory, create an HTML file ("index.html") and a CSS file (*styles.css").

Task 2: Initialize Git
• Initialize a Git repository in your project directory.

Task 3: Git Commit
Add and commit your initial code to the Git repository.

Task 4: Dockerize the application
• Create a `Dockerfile" specifying Nginx as the base image.
Copy your HTML and CSS files into the Nginx HTML directory. (Use ChatGPT to generate a basic HTML and CSS code for a simple web application)

Task 5: Push to Docker Hub
Log in to Docker Hub.
• Push your Docker image to Docker Hub.

Task 6: Set up a Kind Kubernetes Cluster
• Install Kind (Kubernetes in Docker).
• Create a Kind cluster.

Task 7: Deploy to Kubernetes
• Create a Kubernetes Deployment YAML file specifying the image and desired replicas.
⚫ Apply the deployment to your cluster.

Task 8: Create a Service (ClusterIP)
• Create a Kubernetes Service YAML file specifying the type as ClusterIP.
⚫ Apply the service to your cluster.

Task 9: Access the Application
• Port-forward to the service to access the application locally.
Open your browser and visit the specified port to view your simple frontend application.
