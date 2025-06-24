# My DevOps_Project 

## Project 13: Ansible Dynamic Assignments (Include) and Community Roles

### Darey.io DevOps Bootcamp

### Purpose: Automate using Ansible with Include Module 

![Alt text](img/00.ansiblerefactoring.png)

When the import module is used, all statements are pre-processed at the time playbooks are parsed. Meaning, when you execute site.yml playbook, Ansible will process all the playbooks referenced during the time it is parsing the statements. This also means that, during actual execution, if any statement changes, such statements will not be considered. Hence, it is static.

On the other hand, when include module is used, all statements are processed only during execution of the playbook. Meaning, after the statements are parsed, any changes to the statements encountered during execution will be used.

Take note that in most cases it is recommended to use static assignments for playbooks, because it is more reliable. With dynamic ones, it is hard to debug playbook problems due to its dynamic nature. However, you can use dynamic assignments for environment specific variables as we will be introducing in this project.

import = Static
include = Dynamic



### Update Github with Jenkins Ansible server ansible-config-mgt repo

Push ansible_config_mgt repo in the jenkins-asnible server to my github repo 

![Alt text](img/01a.pusherror.png)


Use Personal Access Token to authenticate, since github stopped use of password in 2021

    git remote set-url origin https://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@github.com/pakinsa/ansible-config-mgt

    git rebase --continue  to resolve conflicts manually if there is then

    git push origin main  to push from local repo to github

    git pull https://github.com/pakinsa/ansible-config-mgt.git  to pull from github repo when needed

![Alt text](img/01b.generatetoken.png) 

![Alt text](img/01c.gitpushorigin.png)






### 1. Create a new branch: Dynamic_Assignments

`git checkout -b dynamic-assignments`

![Alt text](img/01d.dynabranch.png)

![Alt text](img/01e.dynamicmerge.png)




### 2. Update the site.yml file for each iteration

To form a dynamic assignment scenario, we have to update our site.yml per time with the service we want to use and their relevant variables


![Alt text](img/02a.siteyml.png) 

For Mysql

![Alt text](img/02b.siteymlformysql.png)

For Nginx

![Alt text](img/02c.siteymlfornginx.png)




### 3. Download and Install Ansible Galaxy Roles and Rename directory according to Purpose

To install and Configure MySQl, Nginx and Apache using GeerLingGuy Ansible Roles

![Alt text](img/03a.galaxyroles.png) 

![Alt text](img/03b.rolescommand.png)


    cd ansible-config-mgt/

    cd roles/



    ansible-galaxy role install geerlingguy.mysql    : To install ansible role that installs mysql from geerlingguy

    sudo mv geerlingguy.mysql/ mysql         : move all content to new directory called  mysql. It creates the folder by itself



    ansible-galaxy role install geerlingguy.nginx     

    sudo mv geerlingguy.nginx/ nginx           : move all content to new directory called  nginx_lb. It creates the folder by itself

    
    ansible-galaxy role install geerlingguy.apache

    sudo mv geerlingguy.apache/ apache    : move all content to new directory called  apache. It creates the folder by itself 


    
    rm -r nginx_lb : to remove a directory with all it content with -r flag

    mv mysql nginx  : rename a directory from mysql to nginx


We created those those new role directories above to mysql, nginx, apache respectively for the following reasons:

1. To organize your roles into subfolders based on their functionality or purpose.
2. To customize the role configuration or behavior without modifying the original source code.  
3. To use the role in different environments or scenarios that require different settings or options. For example, you might have a production environment that needs more security features, and a development environment that needs more flexibility. By moving the role into a new folder, you can create different copies of the role for each environment and switch between them as needed.




### 4. Create the static_assignments files for each service

mysql_db.yml

![Alt text](img/4a.mysqlstaticfile.png)

nginx_lb.yml

![Alt text](img/4b.nginxlbstaticfile.png)




### 5. Configure their main.yml file in their Defaults Folder


![Alt text](img/5a.mysqleditconfig.png)

![Alt text](img/5b.replaceansiblebuiltmodule.png)

![Alt text](img/5c.apachemainconfig.png)

![Alt text](img/5d.nginxmainconfig.png)


The main difference between import_tasks and include_tasks is that import_tasks is processed at the time of parsing, while include_tasks is processed at the time of execution. This means that import_tasks can use variables defined in the playbook scope, but not in the task or block scope, while include_tasks can use variables from any source.

leadnginx.yml

- name: use nginx loadbalancer
  hosts: all
  become: true
  tasks:
    - name: import tasks from another file
      import_tasks: nginx_lb.yml
      when: load_balancer_is_required

To use include_tasks, you just need to replace the import_tasks keyword with include_tasks in your playbook. For example:

leadnginx.yml

- name: use nginx loadbalancer
  hosts: all
  become: true
  tasks:
    - name: include tasks from another file
      include_tasks: nginx_lb.yml
      when: load_balancer_is_required


### 6. Ensure the Dev.yml in Dynamnic Assignment specifies either Nginx or Apache

We want to be able to choose which Load Balancer to use, Nginx or Apache, so we need to have two roles respectively:

Nginx
Apache

Since you cannot use both Nginx and Apache load balancer, you need to add a condition to enable either one - this is where you can make use of variables.


Declare a variable in defaults/main.yml file inside the Nginx and Apache roles. Name each variables enable_nginx_lb and enable_apache_lb respectively.


Set both values to false like this enable_nginx_lb: false and enable_apache_lb: false.


Declare another variable in both roles load_balancer_is_required and set its value to false as well



Now you can make use of env-vars\uat.yml file to define which loadbalancer to use in UAT environment by setting respective environmental variable to true.
You will activate load balancer, and enable nginx by setting these in the respective environment's env-vars file.

enable_nginx_lb: true
load_balancer_is_required: true

or


enable_apache_lb: true
load_balancer_is_required: true


![Alt text](img/6a.dynauatyml.png)


The same must work with apache LB, so you can switch it by setting respective environmental variable to true and other to false.
To test this, you can update inventory for each environment and run Ansible against each environment.


For every iteration, we need declare which software to installed to show dynamic assignment that is why these declarations needs be done, to enable apache if apache is loaded from our static assigmnment or nginx, if loaded from static assignment.


Taking note that in general, Ansible uses the last defined value for a given variable, but some sources have higher precedence than others. For example, variables defined in a playbook will override variables defined in an inventory, and variables passed at the command line will override variables defined in a playbook.

Using hosts and roles inside a role task file, is not allowed. You can only use hosts and roles at the top level of a playbook, not inside a role

### Configure Hosts, with respective Private Ip address of the servers

![Alt text](img/6b.devhosts.png)






### 7. comfirm its task to be upto date

![Alt text](img/7a.apache.png) 

![Alt text](img/7b.db.yml.png) 

![Alt text](img/7c.msql.png) 

![Alt text](img/7d.mysql2.png) 

![Alt text](img/7e.leadnginx1.png) 

![Alt text](img/7e.leadnginx2.png)

![Alt text](img/7e.mainngnixdyna.png) 

![Alt text](img/7f.nginxdynamic.png) 

![Alt text](img/7f.nginxdynamic2.png)




### References:

1. [ProgrammingKnowledge2: How To Generate A Personal Access Token In GitHub And Use It To Push Using Git](https://www.youtube.com/watch?v=iLrywUfs7yU)

2. [Galaxy Ansible](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/mysql/)


3. [DEVOPS-TECHSTACK: Ansible - Zero to Hero](https://www.youtube.com/@devops-techstack/playlists)

