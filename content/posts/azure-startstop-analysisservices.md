---
title: "Automatically Pausing/Resuming an Azure Analysis Services model"
date: 2021-02-21T04:06:22Z
author:
authorLink:
description:
tags:
- Azure
- Analysis Services
- Automation
categories:
- Tutorial
draft: false
hiddenFromHomePage: true
---

***
[Here is a great walk thru on YouTube](https://www.youtube.com/watch?v=PZ7io8ck2b4)

[Access the GitHub repo here](https://github.com/lmcconnell1665/AzureAnalysisServices-StartStop)

***
## Introduction

One of the key value propositions of cloud computing is only paying for resources when you need them.
So why pay to run an expensive in-memory model, like Azure Analysis Services when you aren't using it.
Using Azure Automation runbooks this tutorial will show you how to automatically pause and resume your Azure Analysis Services models on a schedule.

You could combine this with the article I wrote on pausing and resuming a VM from Data Factory, to use this as a trigger instead or even call the PowerShell scripts from Azure DevOps to automate the starting of a development server when you are running your testing pipelines.

{{< admonition type=tip title="Want to implement this even more effectively?" open=true >}}

[Check out this article](/posts/post11/) where I implement a PowerShell script that allows you to scale the tier of the Azure Analysis Services model as well as pause/resume it on a schedule. Even more potential for maximizing users' experience during peak report use hours and savings of infrastructure costs during low use hours!

{{< /admonition >}}

***
## Step 1: Create an Azure automation account
From within the Azure portal, navigate to the `Automation Account` service and create a new account.
You will need elevated privledges to create this account.
Make sure to create this account within the same subscription and resource group as the virtual machines you want to control.
The `Create Azure Run as account` option must be set to 'Yes'.

***
## Step 2: Import the required modules
You will need to import the `az-accounts` and `az-analysisservices` module for the automation account.

***
## Step 3: Create a runbook
Create runbooks using the script in [this repo](https://github.com/lmcconnell1665/AzureAnalysisServices-StartStop). This script checks to see if the model is paused or running and flips the switch the other way. It would be easy to adapt this code to only ever turn on or off, which I would recommend in a live environment.

***
## Step 4: Link to a schedule
Create an automation schedule to start and stop the model at the needed time intervals. You can also create a webhook to connect to Data Factory as a trigger (mentioned above).