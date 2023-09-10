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

```head greatCommands.txt```  : It displays the first 10 lines of the greatCommands.txt
![alt text](img/head.png "head")

```tail greatCommands.txt```:  It displays the last 10 lines of the greatCommands.txt
![alt text](img/tail.png "tail")


```diff 12GreatCommands.txt Achievement.txt``` : Displays the difference between content of 12GreatCommands.txt and Achievement.txt
![alt text](img/diffa.png "diffa")
![alt text](img/diffb.png "diffb")


```df -h```  : Displays human readable detials of file systems of Linux
