## Some very basic GitHub GIT commands

### Create a new repository using the command line
```
	echo "### Create BBB_Workshop_Examples.git" >> README.md
	git init
	git add README.md
	git commit -m "first commit"
	git remote add origin https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples.git
	git push -u origin master
```
### Push an existing repository from the command line
```
	git remote add origin https://github.com/ZoranStojsavljevic/BBB_Workshop_Examples.git
	git push -u origin master
```
![](../Images/git-transport.png)

	$ git status
	$ git add <file>
	$ git rm <file>
	$ git commit -a -m "commit message: short and very descriptive"
	$ git log
	$ git diff
	$ git push

### [Oliver Steele | Blog] My Git Workflow
https://blog.osteele.com/2008/05/my-git-workflow/
