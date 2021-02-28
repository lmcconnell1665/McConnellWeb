---
title: "Installing R and R Studio"
date: 2020-04-20T04:06:22Z
author:
authorLink:
description:
tags:
- R
- Tutorial
categories:
- Tutorial
draft: false
hiddenFromHomePage: true
---

***
## Introduction

R is a free and open-source coding language that is extremely popular for statistical computing, data mining, and machine learning.
This article walks you through the installation of R and R Studio (the most popular GUI for R) as well as the process for updating each.

&nbsp;

Getting R up and running is extremely easy.
I wanted to create an online location with all of these instructions as I find myself looking for the same resources every time I (or a student/colleague) need a new instance of R setup or updated.

***
## Step 1: Installing R

The Comprehensive R Archive Network (CRAN) keeps the latest versions of R stored in a network of mirrors.
[Navigate to the CRAN website](https://cran.r-project.org/mirrors.html) and find one of the mirrors located in the same country as you (so any of the USA locations for me).
[Here is a direct link](https://mirrors.nics.utk.edu/cran/) to the mirror hosted by the National Institute for Computational Sciences in Oak Ridge, Tennessee.

&nbsp;

Next, click the appropriate link to download R for either Mac, Windows, or Linux.
This will take you to a directory where you will want to select to download the most recent base version.
At the time of publishing, that is version 4.0.0.
Download the installation file on to your machine, run it, and walk through the steps.

***
## Step 2: Installing R Studio
Once you have completed step 1, R is on your computer and ready to be used.
R Studio is the most popular graphical user interface for R and makes working with the language and data much easier.
R Studio Desktop can be [downloaded for free with the open-source license here](https://rstudio.com/products/rstudio/download/#download).
Once the installation file is on your machine run it and walk through the steps.
If you are on a Mac like I am, you will want to move the R Studio application to the Applications folder.

***
## Step 3: Open R Studio
At this point, you can launch the R Studio application and begin coding.
If you are new to R, [here is a great “hello world” tutorial](https://www.tutorialspoint.com/r/r_basic_syntax.htm).
I have had a lot of success with the R courses offered by [Data Camp](https://www.datacamp.com/courses/free-introduction-to-r) as well.

{{< image src="/img/install-r/RStudioEnvironment.png" caption="A screenshot of the R Studio environment (customized for my workflow).">}}

***
## Step 4: Updating R & R Studio
With R Studio open, if you run the code below (inside the R Console) it will print to the screen the version of R that you are currently running.
As of May 6th, 2020, the most current version is R version 4.0.0 (2020-04-24).

&nbsp;

```R
R.Version()$version.string
```

&nbsp;

If you are not running the most recent version of R, you can update your version by **repeating step one from above**.
On a Windows machine, you can also use the InstallR package to update your version of R by following the following lines of code.

&nbsp;

```R
install.packages("installr")
library(installr)
updateR()
```

&nbsp;

Next, to verify you are running the latest version of R Studio simply click “Check for Updates” which can be found under the Help menu in R Studio.
If you are not running the most recent version, you will be prompted through the steps to update.