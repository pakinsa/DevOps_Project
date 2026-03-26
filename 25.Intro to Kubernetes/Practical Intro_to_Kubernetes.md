
#### Install docker, Minikube and Kubectl on WSL(Linux Env) on Windows

```bash
#To install minikube on WSL2 (Windows Subsystem for Linux), you will install the Linux version of minikube directly inside your Ubuntu (or other Linux) terminal. This setup is highly recommended for developers as it is fast and efficient. 

#1. *Enable systemd (Required)*
#Minikube needs systemd to manage services. Recent versions of WSL2 support this natively, but it must be enabled. 

# Open your WSL terminal.
# Create or edit the config file: 
sudo nano /etc/wsl.conf.

# Add these lines to the file:
ini
[boot]
systemd=true
Save and exit (Ctrl+O, Enter, Ctrl+X).
Restart WSL: In a Windows PowerShell window, run wsl --shutdown, then reopen your WSL terminal. 

# 2. *Install a Container Runtime*
# You still need a "driver" inside Linux. The easiest way is to install Docker Engine (the background service) directly in WSL, which avoids needing the full "Docker Desktop" Windows app. 

# cd back to root directory
cd.. 
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker $USER && newgrp docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# 3. *Install minikube & kubectl*
# Run these commands in your WSL terminal to download the Linux binaries: 

# Download & Install minikube:
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Download & Install kubectl:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Start the cluster using the docker driver
minikube start --driver=docker

# To check if it's healthy.
minikube status
minikube dashboard
minikube stop / minikube delete
kubectl get nodes 

#6. Run Test Application
# Run a sample deployment and expose it
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
minikube service hello-minikube

# Show all nodes (Verification)
# 'get nodes' shows if the machine is Ready
kubectl get nodes
```




#### Installing Minikube and kubectl directly on Windows.

Use PowerShell (Run as Administrator).
```bash
# ==============================================================================
# 1. Before you start, ensure you have a "driver" installed, such as Docker Desktop or Hyper-V enabled. 
# You can use these PowerShell (Admin) commands to verify if your drivers are ready: 
# Check Docker Desktop or Hyper-V, this commands below runs with hyper-V:
# ==============================================================================

# Check Hyper-V, run 
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Look for State : Enabled. If it says Disabled, you must enable it and restart.
# Check BIOS Virtualization: Open Task Manager (Ctrl+Shift+Esc) > Performance tab > CPU. 
# Look for "Virtualization: Enabled" in the bottom right.

# To enable Hyper-V on your PC.
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All


# ==============================================================================
# 2. CREATE DIRECTORY, DOWNLOAD TOOLS, & ADD PATH CONFIGURATION
# ==============================================================================
# Create folder
New-Item -Path 'C:\minikube' -ItemType Directory -Force

# This downloads minikube & puts the file on the disk.
Invoke-WebRequest -OutFile 'C:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing


#  Add to System PATH (Corrected logic) & makes the command work globally.
$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
if ($oldPath -notlike "*C:\minikube*") {
    [Environment]::SetEnvironmentVariable('Path', "$oldPath;C:\minikube", 'Machine')
    $env:Path += ";C:\minikube" # This updates your CURRENT session so you don't have to restart!
}


# Install kubectl (FIXED URL)
# The URL in your version was missing the actual file path. The command below works perfectly
Invoke-WebRequest -OutFile 'C:\minikube\kubectl.exe' -Uri "https://dl.k8s.io/release/v1.32.0/bin/windows/amd64/kubectl.exe" -UseBasicParsing



# ==============================================================================
# 3. HYPER-V NETWORKING (EXTERNAL SWITCH)
# ==============================================================================

#. List Network Adapter in PC
Get-NetAdapter


# Identify your WIFI adapter name 
# Once you have the name from Step 1, insert in the Name, replace the *WiFi*
$netAdapter = Get-NetAdapter -Name "WiFi"


# Finds your active Wi-Fi adapter so the VM can share your internet connection
$netAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -like "*WiFi*" } | Select-Object -First 1

# See you current adapters
type $netAdapter on a new line and hit Enter

# Creates the "MinikubeSwitch" in Hyper-V linked to your Wi-Fi
# Note you can change the name MinikubeSwitch to any other name of your choice
# Visit the Virtual Switch Manager in Hyper-V manager to confirm the switch created for you after this command.
if (!(Get-VMSwitch -Name "MinikubeSwitch" -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name "MinikubeSwitch" -NetAdapterName $netAdapter.Name -AllowManagementOS $true
}



# ==============================================================================
# 4. START THE CLUSTER 
# ==============================================================================
# Start your local cluster; Minikube automatically detects your driver.
# At this point you can close and reopen vscode so you use BASH terminal or you stay with Powershell
# Note if Minikube does see docker it uses hyper-v. Hyper-V by default allocates 20GB to itself
# While this is going... open HyperV manager on start button on windows and watch it provision the VM.
# View Hyper-V manager while running this command  and see how the VM is being provisioned
# Click on the Networking tab in Hyper-V manager to see the ip address provision after this command

# Use this with default allocation 20GB
minikube start 

# Use this if not starting with default allocation 20GB
minikube start --driver=hyperv

# Instruct Hyper-V to use only 2GB Space rather than default 20GB for VM
minikube start --driver=hyperv --disk-size=2000mb --memory=2048mb

# Launches the VM/cluster with 2GB RAM and 4GB Disk (4000MB)
minikube start --driver=hyperv `
               --hyperv-virtual-switch="MinikubeSwitch" `
               --memory=2048mb `
               --disk-size=4000mb `
               --dns-domain=8.8.8.8
```






#### Installing Minikube and kubectl directly on AWS Cloud Ubuntu.
Managing Hyper-V Networking and Disk Pressure on a local laptop is exactly why many DevOps engineers move their learning to the cloud.

* *Do it on AWS:*
    - *Launch an EC2 Instance:* Use a t3.medium (2 vCPUs, 4GB RAM) with Ubuntu. (The Free Tier t2.micro is too small for Minikube).
    - *Install Docker:* Run sudo apt install docker.io -y.
    - *Install Minikube:* Since AWS is already a virtual machine, you run minikube with the Docker driver (minikube start --driver=docker).
    - *Result:* It starts in 30 seconds, has a fast internet connection, and "just works."

```bash
# 1. Update and install Docker (The Driver)
sudo apt update && sudo apt install docker.io -y
sudo usermod -aG docker $USER && newgrp docker

# 2. Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64


#3. Download and install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

#4  Start Minikube
minikube start --driver=docker


#5 Verify installation
minikube status
kubectl get nodes
```




Other Commands

```bash
# Check the health of the internal components (API Server, Kubelet)
minikube status


# Check Space used & available
minikube ssh "df -h"


# Shows the health status of the "Master" components
kubectl get componentstatuses

# Get the internal Cluster IP (The 'Private IP' of your node)
minikube ip


#Test if kubectl now works 
kubectl version --client

# Checks if your standalone kubectl can "see" the cluster 
kubectl cluster-info






# ==============================================================================
# 6. KUBERNETES PRACTICE COMMANDS (THE "REAL WORK")
# ==============================================================================

# DEPLOYMENT: Create a web server app 
kubectl create deployment my-web --image=nginx
# or sample hello app
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0

# SCALING: Make 3 copies of your app for "high availability"
kubectl scale deployment my-web --replicas=3
kubectl scale deployment hello-minikube --replicas=2


# Confirm the deployment wants 3 replica
kubectl get deployment my-web


# Shows individual copy of each pod application
kubectl get pods -l app=my-web


# INSPECTING: See your 3 copies running
kubectl get pods -o wide


# NETWORKING: Open your app to the outside world (creates a Service)
kubectl expose deployment my-web --port=80 --type=NodePort
kubectl expose deployment hello-minikube --type=NodePort --port=8080


# Inspect a pod
# Use this to debug WHY a pod isn't starting (check 'Events' at the bottom)
kubectl describe pod my-nginx

# Delete a Pod
# This removes the specific instance of the application
kubectl delete pod my-nginx

# ACCESS: Get the URL to open in your browser
minikube service my-web --url
minikube service hello-minikube

# LOGS: See what is happening inside a specific pod
# Replace [POD_NAME] with a name from 'kubectl get pods'
kubectl logs [POD_NAME]


kubectl port-forward --address 0.0.0.0 service/my-web 8080:80




# View the status of your replicas and where they are running
kubectl get deployment web-server
kubectl get pods -l app=web-server -o wide

# Perform a Rolling Update (Update the app to a newer version)
kubectl set image deployment/web-server nginx=nginx:latest

# Check the rollout history (Who changed what?)
kubectl rollout history deployment/web-server

# Rollback the update if the new version fails
kubectl rollout undo deployment/web-server

kubectl get nodes



# ==============================================================================
# Cloud Networking & Extensions, Simulating real-world cloud features like Ingress and Metrics.
# ==============================================================================

# Enable Ingress (Standard for routing traffic like AWS/Azure)
minikube addons enable ingress

# Enable Metrics Server (Required for the 'top' command to see CPU/RAM usage)
minikube addons enable metrics-server

# Check if the Ingress Controller pods are ready in their specific namespace
kubectl get pods -n ingress-nginx



# ========================================================================================
# Deployment & High Availability: Moving from a single 'Pod' to a managed 'Deployment' that can scale.
# ========================================================================================

# Create a 'Deployment' (The professional way to run apps)
kubectl create deployment web-server --image=nginx

# Scale the application to 3 replicas (High Availability)
kubectl scale deployment web-server --replicas=3

# View the status of your replicas and where they are running
kubectl get deployment web-server
kubectl get pods -l app=web-server -o wide

# Perform a Rolling Update (Update the app to a newer version)
kubectl set image deployment/web-server nginx=nginx:latest

# Check the rollout history (Who changed what?)
kubectl rollout history deployment/web-server

# Rollback the update if the new version fails
kubectl rollout undo deployment/web-server




 ==============================================================================
Deep Dive & Troubleshooting
# ==============================================================================

# Describe Node: Check CPU/RAM usage and "Health Events" of the hardware
kubectl describe node minikube

# Describe Pod: Check 'Events' for image pull errors or scheduling issues
# Replace [POD_NAME] with a name from 'kubectl get pods'
kubectl describe pod [POD_NAME]

# Logs: See the real-time error messages inside your application code
kubectl logs [POD_NAME] --tail=20

# Exec: Log into the container's terminal to check internal files
kubectl exec -it [POD_NAME] -- /bin/bash

# Top: Check which pod is eating up your 2GB of RAM
kubectl top pods



# ==============================================================================
# 7. CLEAN-UP & RESET (RUN ONLY TO WIPE EVERYTHING)
# ==============================================================================

# Delete the deployment
kubectl delete deployment web-server

# Stop the node (Saves RAM, keeps your settings for tomorrow)
minikube stop

# Delete the node 
minikube delete 

# To completely reset, and uninstall minikube get back your space
minikube delete --all --purge
Remove-VMSwitch -Name "MinikubeSwitch" -Force
```



How to Use This Effectively
Deployment vs. Pod: In the cloud, we rarely use kubectl run. We use kubectl create deployment. This ensures that if a node fails, Kubernetes self-heals by restarting the pod elsewhere.
Rolling Updates: The rollout commands are the "bread and butter" of a DevOps engineer. They allow you to update apps in production without users noticing.
Addons: Minikube is modular. Use minikube addons list to see other cloud-like features you can turn on, such as Helm or GPU support.















``` bash
Phase 1: Deployment & Scaling
First, we created the application and made it "High Availability" by running 3 copies.

# 1. Create the Nginx deployment (The "App")
kubectl create deployment my-web --image=nginx

# 2. Scale it to 3 replicas (The "Copies")
kubectl scale deployment my-web --replicas=3

# 3. Verify they are running (Look for 3/3 READY)
kubectl get pods


Phase 2: Networking (The Service)
We created a Service to group those 3 pods together under one internal IP.

# 4. Expose the deployment as a NodePort service
kubectl expose deployment my-web --type=NodePort --port=80

# 5. Check the Service details (Find your NodePort, e.g., 32161)
kubectl get service my-web


Phase 3: The "Self-Healing" Test
We proved that Kubernetes automatically fixes itself if a pod fails.

# 6. Delete one specific pod to test self-healing
# (Replace the name below with one from your 'kubectl get pods' list)
kubectl delete pod <POD_NAME>

# 7. Watch it instantly create a brand new replacement
kubectl get pods


Phase 4: Accessing via Browser (The Bridge)
Because we are using the Docker driver on AWS, we had to "bridge" the internal cluster network to the public AWS IP.

# 8. Start the port-forwarding tunnel (Running in the BACKGROUND)
# This maps AWS Port 8080 to the internal Service Port 80
kubectl port-forward --address 0.0.0.0 service/my-web 8080:80 &
kubectl port-forward --address 0.0.0.0 service/my-web 8080:80

# 9. Verify internally that the tunnel is alive
curl http://localhost:8080

```


Declarative Configuration (YAML):
Instead of typing kubectl create..., you write a text file (deployment.yaml) that describes your whole app. You then run kubectl apply -f deployment.yaml. This is "Infrastructure as Code."
Resource Limits:
Currently, Nginx can take all the CPU/RAM of your AWS instance. You should learn how to tell Kubernetes: "This app can only use 128MB of RAM." This prevents one app from crashing the whole server.
ConfigMaps & Secrets:
How do you change the "Welcome to Nginx" text without rebuilding the whole image? You use a ConfigMap to "inject" a custom index.html file into the pod while it's running.
