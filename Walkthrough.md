---
title: Reproducible computing: An initial walkthrough
layout: page
---
# make a new directory and cd into it
mkdir BBSRC-git-demo
cd BBSRC-git-demo

# create a new git repository
git init
git status
# create a file called somecode.R containing the following lines:
# this will load the data from the Lewandowsky et al. study 
# (http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0075637)


df=read.table('http://data.bris.ac.uk/datasets/swyt56qr4vaj17op9cw3sag7d/LskyetalPLOSONE.csv',
              header=TRUE,sep=',')
head(df)

# run the R script using the "source" button in Rstudio

# This worked, so let's check our file into the repo
git status
git add somecode.R
git status
git commit -m"initial add"
git status

# let's run a linear regression model to see if
# performance is related to age
# - add the following code and source the file:
lm.result=lm(conspiracist_avg~age,data=df)
summary(lm.result)

# this should also complete.  Let's go ahead and check in again
git add somecode.R
git commit -m"adding lm"

# let's put this into a repository on github so that we can
# share it with others

1. log into github.com
2.  create a new repository (+ sign at top right)
- give it the same name as your directory (BBSRC-git-demo)
- just use the defaults (it should be public) and
click "create repository"
3. There will be a set of commands in the section titled
"…or push an existing repository from the command line"
- copy those and paste them into the terminal inside
the directory with your git repository - somethign like:

git remote add origin git@github.com:poldrack/BBSRC-git-demo.git
git push -u origin master

Click on the repository link at the top of the page
to go to the main repo page. you should see "somecode.R"
in the list.


# let's go ahead and set up circleci to automatically
# run a smoke test for us
# create a file called circle.yml and add the following lines:

dependencies:
  pre:
    - sudo apt-get update && sudo apt-get -y install r-base
test:
  override:
    - Rscript somecode.R

# then add to repo and commit and push to github

git add circle.yml
git commit -m"initial add"
git push origin master

# next we have to hook this up to the circleci system

1. go to circleci.com and log in using your github account
2. click on the "Projects" button (with the + sign)
Choose your github account, and then click on the
"build project" button for your repo
It will then take you to a page showing the status
of the build.  for an overview, click on the "builds"
button which will take you to a list of builds.

after a couple of minutes it should show that the build
succeeded


# look at the log to see what we've done so far
git log

# we are a bit surprised that there is no relation
# between age and performance, so let's have a look
# add the following code and source the file

plot(df$age,df$performance)

git add somecode.R
git commit -m"adding plot"

# let's say that we decided that we don't want the
# plot in the file. We can go back to the previous commit:

git revert <commit ID>

the change in the file should show up immediately in
the RStudio editor window

#it's clear from the plot that something is wrong
# there is an outlier in the age distribution
# let's first add a test to check for age outliers
# in this study, subjects were supposed to be between
# 20 and 60
# add the following code above the lm command:

stopifnot(max(df$age)<60)
stopifnot(min(df$age)>20)

# when you source the file, you should see an error.
# let's see what happens when we push this to github
git add somecode.R
git commit -m"adding assertion test"
git push origin master

# a few seconds later, you will see that the automated
# test starts on circleci
# you will see that the test fails due to the error

# let's add some code to clean up the outliers
# above the assertion tests, add:

df=subset(df,age>20&age<60)

# run the code again - this time it succeeds
# and we now see a strong effect of age

# push it back to github and check circleci again
git add somecode.R
git commit -m"adding outlier removal"
git push origin master

# add a fancy badge to your github page to show off
- go to the builds page and click the gear next to your repo
- click on "status badges" and copy the text under "embed code"
[![CircleCI](https://circleci.com/gh/poldrack/BBSRC-git-demo.svg?style=svg)](https://circleci.com/gh/poldrack/BBSRC-git-demo)
- add this into a README file on github

