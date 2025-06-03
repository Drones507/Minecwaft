Christopher Harvey
CS312 System Administration 
Sisavath Virasak
Course Project 2

# Minecwaft
uWu



------------------------------
REMOVE THIS MESSAGE IN FINAL COMMIT BEFORE SUBMISSION

RUBRIC CHECKLIST

25 points
X  README is present in the repository and contains all required information
X  3 pts for proper user of markdown syntax |
X  10 pts if structure is clear and easy to follow |
X  10 pts if steps are all explained and don't leave the reader wondering what they're doing |
X  2 pts if no typos or other mistakes

50 points
X  All the scripts required to complete this project are in the repository
X  The scripts will be compared with the recording and might eventually be run if we have doubts:
X  25 pts for the infrastructure provisioning | 25 pts for the configuration

25 points
X  The recording shows you running your pipeline without ever going to the AWS Management Console, then connect (or telnet) to the Minecraft server once everything is setup.
X  The pipeline should output the IP address of the server that you then use to connect to.

Extra Credit Checklist 
X  Extra-credit: Use ECS or EKS instead of EC2
X  Extra-credit: If using ECS or EKS, have the Minecraft server data stored outside the container
X  Extra-credit: Configure GitHub Actions to run the whole pipeline on push

------------------------------
Background: What will we do? How will we do it? 
Requirements:
What will the user need to configure to run the pipeline?
What tools should be installed?
Are there any credentials or CLI required?
Should the user set environment variables or configure anything?
Diagram of the major steps in the pipeline. 
List of commands to run, with explanations.
How to connect to the Minecraft server once it's running?

**Background**
In this repo are infrastructure provisioning scripts in Terraform to setup AWS resources. 
* Provision compute resources: ECS
* Setup networking
* Specify and configure the Docker image to deploy
* GitHub Actions to configure resources on push
  
