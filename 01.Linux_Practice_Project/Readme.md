# My DevOps_Project 
## Project 1: Linux Pratice Project
## Darey.io DevOps Bootcamp


![alt text](img/Linux-Symbole.png "Linux")

Linux Commands are the primary commands needed to communicate with the cloud devices

Requirements:
* 1. Download and install VirtualBox from <https://www.virtualbox.org/wiki/Downloads>
* 2. Download and install Linux Ubuntu Deskstop OS as a virtual Machine in VirtualBox from [Ubuntu](https://ubuntu.com/download/desktop)
* 3. Configure settings ofVirtual Machine with 2 processors and 4GB RAM
* 4. Install WSL Windows Subsystem for smooth dispaly and apprearance
* 5. Find and Open App, Terminal


Operations:
* ```sudo apt update``` : To update the dependencies
![alt text](img/Sudo_apt_update.png "update") 

* ```sudo apt upgrade``` : To upgrade necessary packages
![alt text](img/Sudo_apt_upgrade.png "upgrade") 

* ```pwd``` : To know your Present Working Directory
* ```ls```  : To list content of your presnt working directory
* ```cd```  : Change from directory from present working directory to another.
![alt text](img/cdpwdls.png "cd") 

* ```mkdir Music```  : Creates a new directory called Music
![alt text](img/mkdir.png "make") 

* ```touch Achievement.txt``` : Creates a new file called Achievement
* ```cat Achievement.txt```: To view content of the file Achievement.txt
![alt text](img/cat.png "cat")

* ``` mv Achievement.txt Excellence```: Move the file Achievement.txt to a directory named Excellence
![alt text](img/mv_achievement.png "achieve")

* ```echo “I like DevOps” >> Achievement.txt```  : Append with double operator to the last line of the file the text "I like DevOps"
![alt text](img/echo.png "echo")

* ```ls -a```: Displays all directories and files including .(dot) files i.e hidden files.
![alt text](img/Ls-a.png "lsa")

* ```rmdir -p Songs```: Removes the directory/folder called Songs and -p represent Parent, specifying removing all subdirectory ofthe parent directory.
![alt text](img/rmdir.png "remove")

* ```grep "filename" GreatCommands.txt```: Find "filename" in the file called GreatCommands.txt
![alt text](img/grep.png "grep")

* ```head greatCommands.txt```  : It displays the first 10 lines of the greatCommands.txt
![alt text](img/head.png "head")

* ```tail greatCommands.txt```:  It displays the last 10 lines of the greatCommands.txt
![alt text](img/tail.png "tail")


* ```diff 12GreatCommands.txt Achievement.txt``` : Displays the difference between content of 12GreatCommands.txt and Achievement.txt
![alt text](img/diffa.png "diffa")
![alt text](img/diffb.png "diffb")


* ```df -h```  : Displays human readable detials of file systems of Linux
![alt text](img/df-h.png "dfh")

* ```mkdir -p second_folder/third_folder/fourth_folder```: Creates a nested folder up to fourth level with -p flag u to parent directory
![alt text](nested_folder.png "nested")

* ```sudo apt-get install tree```   : Installs directory tree in linux
* ```tree first_folder/```   : Displays the hiercahy of nested folder
![alt text](img/tree_nest_folder.png "tnf")


*```tree / -L 1```   : Displays level one directory of linus filesystem root 
![alt text](img/tree_linux_root.png "tlr")


*```sudo ls -l /root```   : listing the root file of the linux OS you need superuser
![alt text](img/sudo_root.png "sudo")


*```wget raw.githubusercontent.com/pakinsa/Model-Training-..../master/predict.py``` : Downloads a specified file from github to your linux PC,e.g predict.py a python file
![alt text](img/wget_to_github.png "wget")


*```sudo groupadd jun_engrs```  : Creates a new group called jun_engrs
*```sudo useradd -G jun_engrs tolu``` : Adds tolu as a user to the group jun_engrs
![alt text](img/user_groups.png "user")


*```sudo chown tolu:brostle error.txt```   :change ownership of error.txt from brostle to tolu
![alt text](img/chown.png "own")


*```ls -l``` : to list files and directories with thier various formats
![alt text](img/ls-l.png "ls-l")

-rwrx. : When a display starts with hyphne(-), then that is a file, r is read, w is write and x is execute

dwrx: When a line of display starts with a (d), then that is a directory, r is read, w is write, x is execute

Example: "-rwx r-x r- -": User(u) group(g) others(o) : Means users can read, write and execute, while group can only read and execute but can't write, and others can only read.

*```chmod -c g+w filename```  :grants permissions to group to now write

*```chmod -c o+x filename```  :grants the permissions to others to execute

*```chmod -c u-r filename```  :removes the permissions from users to read.

*```chmod -c u+x error.txt```  :grants permission for users to execute.
![alt text](img/chmod.png "chm")


* Read = 4,
* Write = 2,
* Execute = 1,
* No permission = 0.


* Read + Write + Execute = 7,
* Read + Write = 6,
* Read + Execute = 5,
* Write + Execute = 3.

*```chmod 735 predict.py```   : changes the mode of the file predict.py into a read, write, exeutable for users(u), only write and execute for groups(g) and read and execute for others(o)  
 ![alt text](img/chmod735.png "chm")


*```sudo systemctl status apache2``` : know the status of apache in the server if it is running
![alt text](img/statusapache.png)


*```sudo mysql``` : enter into the mysql service, or use
*```sudo mysql -p```  : flag -p is a prompt for password
![alt text](img/entermysqlproper.png)



*```sudo mysql_secure_installation``` : Install securely with the use of passwords for rootuser in mysql
![alt text](img/mysqlsecureinstallation.png)


*```sudo /etc/init.d/mysql restart```  :  stop and restart mysql service 
![alt text](img/restartmysql.png)

*```ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Success1'```
![alt text](img/changerootpasswrdmysql.png)

*```sudo mv test.php /var/www/html```   : moves the test.php file into a directory /var/www/html
*```find / -type f -name "test.php"```   : finds from the root directory filename test.php and the path to the file
if you change test to * wildcard, *.php, will find out all php file from linux system from the root 
![alt text](img/mvtestfile.png)


