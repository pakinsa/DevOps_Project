# My DevOps_Project 

## Project 5: Shell/Bash Scripting Practice Project

### Darey.io DevOps Bootcamp


![alt_text](./img/00.shell-scripting.png)


### General Commands
```touch mylearningscripts.sh```  creates a script called "mylearningscript.sh"

```ls```                          list containing files

![Alt_text](img/1a.touch&create.png)




```which bash```                 command to display the type of shell script: bash
![Alt text](img/2a.myfirstscript.png)



```Shell```                      command to display the type of shell script: bash
![Alt text](img/2b.myshell.png)




```chmod  +x mylearningscripts.sh```  command changes the mode of this script for to executable
![Alt text](img/2c.if_user_activation.png)




A bash script that receives user input and chats
userinput.sh code can be ran from the mylearningscripts.sh
![Alt text](img/3a.Userinput.png)

response.txt contains responses saved from the chat available in this repository
![Alt text](img/3b.Userinputresponse.png)


### Variables
Using Variables in Bash Scripting
![Alt text](img/4a.Variables.png)


Positional Variables

positionalvariables.sh can be ran from mylearningscripts.sh
![Alt text](img/4b.Variableswithposition.png)



### Basic Operations Commands
Verify scripts code for Errors

```bash -n mylearningscripts.sh```   Verifying if mylearningscripts.sh has errors
![Alt text](img/5a.syntaxverify.png)


Write text directly on Command line

```cat << EOF```
![Alt text](img/5b.EOF.png)


Count the number of words in a Script
wc -w greatercalc.sh         Counts the number of words in greatercalc.sh 
![Alt text](img/5c.wc.png)    


### Basic Arithmetic Operations

calculations.sh can be ran from mylearningscripts.sh

![Alt text](img/5d.calculations.png)


Conditional Statements and Structures

simpleif.sh can be ran from mylearningscripts.sh
![Alt text](img/6a.ifstructure.png)


casestudy.sh can be ran from mylearningscripts.sh
![Alt text](img/6b.casestructure.png)


forloops.sh can be ran from mylearningscripts.sh
![Alt text](img/6c.simpleforloop.png)

![Alt text](img/6d.renamingforloopa.png)

![Alt text](img/6e.renamingforloopb.png)



### Storage and Backup Operations
backup.sh can be ran from mylearningscripts.sh
![Alt text](img/7a.beforeBackup.png)

![Alt text](img/7b.afterbackup.png)



### AWS CLI Installation and Configuration
Install or confirm Python Installation local PC

```python --version```  shows the version of the installed python.
![Alt text](img/8a.installpython.png)

Download and install AWS CLI Version 2
[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

![Alt text](img/8b.awscli.png)

![Alt text](img/8c.installawscli.png)



Create new user and get access key
![Alt text](img/8d.users.png)

![Alt text](img/8e.userconfig.png)

![Alt text](img/8f.getaccesskeys.png)


AWS CLI Configure

```aws configure```    command to configure installed aws on local machine
![Alt_text](img/8g.awsconfigure.png)

```aws ec2 describe-instances```       Command describe the properties of all servers initiated on EC2 on AWS to the IAM User

```aws ec2 describe-instance-types```  This command describe the physical and digital properties of available servers in AWS

![Alt text](img/8h.brickwall1x.png)    
But unfortunately, IAM user couldn't gain access. I tried using AWS CloudShell as well but same error.

![Alt text](img/8i.brickwall2x.png)    
Unfortunately, IAM user couldn't gain access. I couldnt gain access to AWS EC2 via AWS CLI for 3days.


### Solving the brickwall
Couldnt gain access to ec2 on AWS for days.

I have learnt to use documentation more often than following threads solutions

Secondly, not all apps installed from Windows store are in perfect usable state on your PC, Some configurations will still be needed.

![Alt text](img/9a.brickwallkeymoment.png) 

![Alt text](img/9b.brickwallkeymoment.png)  


AWS Boto is an app needed to be installed but PATH needs be configured first in the environement variables for python and scripts from apps such as AWS CLI to work.

![Alt text](img/9c.brickwallprocess.png)    

![Alt text](img/9d.brickwallprocess.png)


 Finally... IAM User connected successfully to EC2 via AWS CLI without siginin via AWS Management console
![Alt text](img/9e.brickwallsolved.png)   

![Alt text](img/9f.brickwallsolved.png)   



```aws ec2 run instances help```  Help commands that helps in running and configuring EC2 Instances
![Alt text](img/10a.ec2help.png)

```aws ec2 start-instances --instance-ids i-0622cc6811fa267d4 i-08ae2c6f96ebd639c i-0971628cf81c988c0``` AWS CLI command to start 3 instances with their respective id's
![Alt text](img/10b.b4clicommand.png)

![Alt text](img/10c.startinstances.png)

![Alt text](img/10d.afterclicommand.png)

```aws ec2 stop-instances --instance-ids i-0622cc6811fa267d4 i-08ae2c6f96ebd639c i-0971628cf81c988c0``` AWS CLI command to stop 3 instances with their respective id's
![Alt text](img/10e.stopinstances.png)




#### Learning scripts

```./mylearningscripts.sh```  
Contains appendix. Appendix contains all implemneted learning scripts
Some code in the appendix were corrected and edited with the use of BING AI





#### Appendix
1. positionalvariables.sh

2. userinput.sh

3. response.txt

4. calulations.sh

5. simpleif.sh

6. greatercalc.sh

7. casestudy.sh

8. forloops.sh

9. backup.sh






#### REFERENCES:

[FreeCodeCamp.org: Bash Scripting Tutorial for Beginners](https://www.youtube.com/watch?v=tK9Oc6AEnR4)

[BeaBetterDev: How to install and configure the AWS CLI on Windows 10](https://www.youtube.com/watch?v=jCHOsMPbcV0)

[GeekforGeeks.org: Launching EC2 Instance on AWS CLI](https://www.geeksforgeeks.org/launching-an-ec2-instance-using-aws-cli/)