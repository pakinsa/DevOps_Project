# My DevOps_Project 

## Project 2: LAMP Stack Implementation Project

### Darey.io DevOps Bootcamp

![alt text](img/00.lamp.png)

### Required Steps:
1. #### Create and/or signin into your AWS account

![alt_text](01.signin_to_aws.png)


2. #### Launch an EC2 instance Server with Ubuntu OS pre-installed

![alt_text](02a.launchEC2.png)

   Create a Key Pair
   
![alt_text](02b.key_pair.png)

   A running Instance

![alt_text](02c.instance.png)


3. #### Open GitBash or Powershell or Visual Studio code to coonect to a running instance

   Ensure you  the SSH client cursor is in the current directory where your key .pem file is 
   saved.  
   Copy and paste the SSH command to your SSH Client.

   ![alt_text](03a.SSHclient.png)


   Successful Connection status to a running Ubuntu Cloud Server from local SSH Client: Git Bash

   ![alt_text](03b.connect.png)




4. #### Install Apache version 2.0

   ```sudo apt update``` : update the linux OS with latest dependencies.
   ![alt_text](04a.sudo_apt.png)
   

   ```sudo apt install apache2```   :  This command installs apache version 2 on the Linux Server
   ![alt_text](04b.installapachev2.png)


   ```sudo systemctl status apache2```  : This command checks the status of the apache if active
    ![alt_text](04c.statusapache.png)




5. #### Make an early visit to our public web server 
   At: 3.88.45.220  This gives you an error below,
   because we have not added a http protocol on our inbound rule to the server

   ![alt_text](05a.earlyvisiterror.png) 


   Add a http protocol at port 80 as a new inbound rule

   ![alt_text](05b.createHTTP.png)


   New inbound rule now successfully added

   ![alt_text](05c.httpinboundrule.png)


   Apache now loads up from: Bash and Public IP at 3.88.45.220:80

   ![alt_text](05d.localhost1.png)
   ![alt_text](05e.apacheworks.png)


6. #### Install MySQL

    ```sudo apt install mysql``` : This command installs mysql relational DBMS 

    ```sudo systemctl status mysql``` : Confirm mysql successfull installation and active

    ![alt_text](06a.mysqlrunning) 

   
    ```sudo mysql```  : Initialises the mysql database system

    ![alt_text](06b.enterintomysqlproper) 


    ```ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Password.1'```

    ![alt_text](06c.rootmysqluserpasswrd)
    
    You can as well change the root user password with this command.

    ![alt_text](6d.changerootpasswrdmysql)

    Perform secure installation of mysql

    ![alt_text](6e.mysqlsecureinstallation)



