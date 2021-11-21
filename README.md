


# Overview
 The repository contains the code to build the application (http_server) as a Docker container and deploy it in a Kubernetes cluster as a load balanced service.
The application is presented as a http service that exposes a health check and endpoint. This simple Ruby web server serves on port 80. /healthcheck path returns "OK" and all other paths return "Well, hello there!"


The IP to reach the website is the IP of Ingress server. Under the ingress, service has been configured using the labels to reach the corresponding pods on port 80 which was deployed using deployment.

Description of files:

dockerfile: This is the Docker configuration that can be used to build the container image for the application. This docker runs service on port 80. Since port 80 is default port, non-root users cannot use port 80. Hence `$ setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/ruby ` command is being used in dockerfile to make use of port 80.

httpserver-deployment.yaml : This YAML configuration is to create Kubernetes deployment using the container image created by the dockerfile. The deployment defines a replica set of 2 pods and exposes port 80 to access the application.

httpserver-service.yaml : This YAML configuration is to create Kubernetes service to load balance the requests to the pods created by the deployment.

ingress.yaml: This YAML configuration is to create Kubernetes ingress service, to get the request on port 80 of the worker node IP and pass on to the service.


# Assumptions
•	Using a Linux system as the host for running the minikube cluster.

# Strategy/Architecture:
                        Request --> Ingress (http://workernodeIP:80) --> K8S service --> K8S pods
In this application deployment process, Kubernetes components such as Deployment, Service, Ingress, and probes are being used. Ansible is being used to orchestrate the pipeline from cloning the code from the repository and deploy in the Kubernetes.,
High availability is available by default in k8s deployment with replica set more than 2 and configured under k8s services using labels given in the deployment.
Before a pod is being put in service to serve the request, readiness probe has been put in place to check whether the pod is ready to serve the request by hitting the /healthcheck endpoint.

Liveliness probe has also been configured to check whether the pod is serving perfectly. If not, k8s will recreate the pod.

# Prerequisites
Install minikube 
Install Ansible 
Install git

# Steps to deploy the application on k8s:
1)	Download the source code from repo using below command 
         `$ git clone https://github.com/shadrachdoc/httpserver.git`
2)	Trigger ansible playbook using below command
          `$ ansible-playbook httpserver/ansible/httpserver.yaml`
The above playbook, perform these below activities.
•	Creating directory /opt/build 
•	Download source code from git repo 
•	Build docker image using dockerfile 
•	Enabling ingress in minikube
•	Create pods using k8s deployment 
•	Create k8s service
•	Create ingress 


# Verify your minikube installation
From the terminal run:
`$ kubectl cluster-info`

`$ kubectl get nodes`

 
Below command gives IP address or use localhost to test the website. As we are using minikube, ingress would be running on only one node. However, In production environment, multiple ingress would be running and those needs to be configured under Load Balancer(eg: F5) and LB url should be used to test the application.
kubectl get ingress 
 

to check the connectivity status

`$ curl http://<ip-address> `

Note: If you get any error as shown below

curl: (1) Received HTTP/0.9 when not allowed

please use your curl command with –http0.9 as mentioned below

`$ curl http://<ip address> --http0.9`

