# My DevOps_Project 
## Project 2: GIT Pratice Project
### Darey.io DevOps Bootcamp
![alt text](img/01.git.png)


Git Commands helps to collaborate on projects amongst technical teams 

Required Steps:
* 1. Download and install Git  from <https://git-scm.com/downloads>
     ![alt text](img/02.git_download_site.png "Gitd")
     ![alt text](img/03.git_exe.png "Gitexe")

* 2. Configure username and password on Git Bash

     ![alt text](img/04.git_versionconfig.png "Gitv")

* 3. Create a repository by first creating a folder with necessary  files you might need

     ![alt text](img/05.create_folder.png)


* 4. `git init` : to initialise the repository. This can be done on Git Bash with this command 
      and can also done on Visual Studio code GUI
      
      ![alt text](img/06.git_init.png)
      ![alt text](img/07.git_init_folder.png)


* 5. `git commit` : my firstcommit was to rename a python file and was commited with this command

      ![alt text](img/08.firstCommit.png)

     
* 6. `git log --oneline` : view previous commits in one log with this command.

     ![alt text](img/09.onelinelog.png)


* 7. `git rm filename.txt`  : delete by removing this filename

      ![alt text](img/10.delete_file.png)


* 8. `git diff`  : shows the difference in changes made to a file.

      ![alt text](img/11.git_diff.png)


      `git ls-files`  : displays all files in your repository

      ![alt text](img/11a.git_ls.png)


* 9. `git branch branch_name`  : create a new branch
     `git branch`              : confirm branches available in your repository
     `git switch branch_name`  : switch to a specified branch_name  

      ![alt text](img/12.branchswitchcommit.png)

* 10. `git merge -m "tag_comments_here" branchtobemerged` : merge commits of branch to main with flag -m with tag comments.

      ![alt text](img/12a.merge_branches.png)

* 11. `git merge branch_name`  :    e.g git merge FixText created a merge conflict

      ![alt text](img/13.mergeconflict.png)

      ![alt text](img/14.sign_of_conflict.png)

* 12. `git commit -a -m "tag_comments"` : e.g git commit -a -m "resolves conflict"  commits all changes with -a flag
to main branch with -m flag and tag with comment in quotation marks. Conflict resolved.

      ![alt text](img/15.conflict_resolution.png)


* 13. `git branch -d FixImageText` : deletes a the branchname FixImagetext with flag -d

      ![alt text](img/16.delete_branch.png)


* 14. `git restore --unstaged "imagetotxt.py"`   : unstaged the file "imagetotxt.py" which was previously be staged for commit.

      ![alt text](img/17.git_restore.png)
      

* 15. `git-h`  : get help with commands on git
      ![alt text](img/18.git-h.png)



* 16. Create a github account at [Git](https://github.com/) 
      ![alt text](img/19.github.png "Github")

* 17. Create the repository on Github without adding a readme file and gitignore file. 
      This allows seamless git remote repo addition without errors of "remote repository has an existing file"
      ![alt text](img/20.remoterepo.png)  


* 18. Copy the https of your remote repo

      `git remote add origin https://github.com/pakinsa/Brostleprojects.git`  // attempts to add your github repo to your local repo.
      `git branch -m main`          //takes the Head, i.e the main branch of your github repo
      `git push -u origin main`     // connects it to the main branch of your local repo with -u flag for upstream

      ![alt text](img/21.git_remote.png)  

* 19. git push --all  // push all branches to remotely
      ![alt text](img/22.pushbranchremote.png)  
      ![alt text](img/23.remote_branches.png)



* 20. You can contribute to a project on GitHub by identifying and opening issues
      ![alt text](img/24.issues.png)  


* 21. You can solve issues in a project with pull request seeking a reviewer to merge into main if successful.
      ![alt text](img/25.pullrequest.png)  


* 22. Once pull request is approved, a merging take place by the assigned reviewer.
      ![alt text](img/26.mergeremotepullrequest.png)  


* 23. Take a look at number of issues, pull requests, commits made in a repository at insights
      ![alt text](img/27.insights.png)  


* 24. Finally sync your local repo with your remote repo.
      `git pull` : With git pull from Bash, you update all changes made on your remote repo with your local repo.
      ![alt text](img/28.pull_remotely.png)  
 