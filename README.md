
## Reproducible workflow walkthrough for BBSRC Meeting

This walkthrough assumes that you have [git](https://git-scm.com/downloads) and [RStudio Desktop](https://www.rstudio.com/products/rstudio/download/) installed on your computer and that you can access a terminal window (using Terminal on the Mac, or Git Bash on Windows).  It also assumes that you have created an account for yourself on [GitHub](http://github.com).

### 1. make a new directory and cd into it
```
mkdir BBSRC-git-demo
cd BBSRC-git-demo
```

### 2. create a new (local) git repository
```
git init
```
You can now check the status of your local repository (it should be empty)
```
git status
```

### 3. Create a sample source code file.
Start up RStudio. Create a new R script called somecode.R containing the following lines (which  will load the data from the [Lewandowsky et al. study](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0075637):
```
# R code
df=read.table('http://data.bris.ac.uk/datasets/swyt56qr4vaj17op9cw3sag7d/LskyetalPLOSONE.csv',
              header=TRUE,sep=',')
head(df)
```
Note: code to be added to the R script is marked with "# R code".  Any cells not marked this way are meant to be typed into the terminal window.

### 4. After you save the file, run the R script using the "source" button in Rstudio
Remember to save the file inside the `BBSRC-git-demo` directory you created in step 1.

### 5. (Hopefully!) this worked, so let's check our file into the repo
```git status
git add somecode.R
git status
git commit -m"initial add"
git status
```

You may experience an error when you type the command to commit the change.  In this case, you need to enter the following commands to set your identity with git:

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
replacing the placeholders with your actual email address and name.

### Now let's run a linear regression model to see if conspiracist thinking is related to age

### 6. add the following code to the end of somecode.R and source the file using the Source button in RStudio:
```
# R code
lm.result=lm(conspiracist_avg~age,data=df)
summary(lm.result)
```

### 7. This should also complete successfully.  Let's go ahead and check in again
```
git add somecode.R
git commit -m"adding lm"
```

### 8. Now let's put this into a repository on github so that we can share it with others and have a persistent backup.

1. log into [github](http://github.com/)
2. create a new repository (+ sign at top right)
   * give it the same name as your directory (BBSRC-git-demo)
   * just use the defaults (it should be public) and click "create repository"
3. There will be a set of commands in the section titled "…or push an existing repository from the command line" - copy those and paste them into the terminal inside the directory with your git repository. You may need to enter your github username and password.

The commands willl look something like:
```
git remote add origin https://github.com/<your username>/BBSRC-git-demo.git
git push -u origin master
```

Click on the repository link at the top of the page to go to the main github repo page. you should see "somecode.R" in the list.


### Now let's set up CircleCI to automatically run a smoke test for us every time we check in a new revision of our code to github.

### 9. create a file in your github repository called circle.yml and add the following lines.  An easy way to do this is to use the "Create new file" button on the github page, which will take you to an editor where you can create the file and then save and commit it with one click.

```
dependencies:
  pre:
    - sudo apt-get update && sudo apt-get -y install r-base
test:
  override:
    - Rscript somecode.R
```

### 10. if you created it using the editor on github, then you should pull that change so that your local repository is in sync with github.
```
git pull origin master
```

### if you instead created the circle.yml on your own computer using a text editor, then add to repo and commit and push to github

```
git add circle.yml
git commit -m"initial add"
git push origin master
```


### 11. next we have to hook this up to the CircleCI continuous integration system

1. go to [CircleCI](http:circleci.com) and log in using your github account
2. click on the "Projects" button (with the + sign)
3. Choose your github account, and then click on the "build project" button for your repo
4. It will then take you to a page showing the status of the build.  for an overview, click on the "builds" button which will take you to a list of builds.

After a couple of minutes it should show that the build succeeded

### 12. Have a look at the git log to see what we've done so far, by typing this into the terminal window:

```
git log
```

### We were a bit surprised that there is no relation between age and conspiracist thinking, so let's have a closer look at the data

### 13. add the following code to the end of somecode.R and source the file in RStudio

```
# R code
plot(df$age,df$conspiracist_avg)
```

### 14. Then commit the changes to the git repo.

```
git add somecode.R
git commit -m"adding plot"
```

### 15. let's say that we decided that we don't want the plot in the file. We can go back to the previous commit:

First, use ```git log``` to show the log of previous commits, which will give you the commit ID (a long alphanumeric hash) for the commit with the message "adding plot".

Then, revert that particular commit:

```
git revert <commit ID>
```

The change in the file should show up immediately in the RStudio editor window

### It was clear from the plot that something is wrong: there is an outlier in the age distribution
### let's first add a test to check for age outliers
### in this study, subjects were supposed to be adults - let's say the reasonable range of adult ages is 18 to 120

### 16. add the following code immediately above the lm command in somecode.R:

```
# R code
max_age=120
min_age=18

stopifnot(max(df$age)<max_age)
stopifnot(min(df$age)>min_age)
```

### 17. When you source the file, you should see an error. Let's see what happens when we push this to github

```
git add somecode.R
git commit -m"adding assertion test"
git push origin master
```

a few seconds later, you will see that the automated test starts on CircleCI. a bit later you will see that the test fails due to the error

### 18. let's add some code to clean up the outliers
### Just after the definition of min_age but before the assertion tests, add the following:

```
# R code
df=subset(df,age>min_age&age<max_age)
```

### 19. run the code again - this time it succeeds and we now see a strong effect of age (as noted in [the correction to the original paper](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0134773)): 

### 20. push it back to github and check circleci again
```
git add somecode.R
git commit -m"adding outlier removal"
git push origin master
```

### 21. add a fancy badge to your github page to show off your new CI skills
1. go to the builds page and click the gear next to your repo
2. click on "status badges" and copy the text under "embed code"
  * it will look something like ```[![CircleCI](https://circleci.com/gh/poldrack/BBSRC-git-demo.svg?style=svg)](https://circleci.com/gh/poldrack/BBSRC-git-demo)```
3. In your github repository, create a new file called README.md, and paste this badge code at the top of the file.


