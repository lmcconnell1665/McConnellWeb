---
title: "Auto-Scaling an Azure Analysis Services model"
date: 2021-02-27T04:06:22Z
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
[Here is great documentation by the script's author](https://jorgklein.com/2017/10/11/azure-analysis-services-scheduled-autoscaling/)

[Access the GitHub repo here](https://github.com/lmcconnell1665/AzureAnalysisServices-StartStop)

***
## Introduction

One of the key value propositions of cloud computing is only paying for resources when you need them.
So why pay to run an expensive in-memory model, like Azure Analysis Services when you aren't using it.
Using Azure Automation runbooks this tutorial will show you how to automatically pause, resume, scale up, and scale down your Azure Analysis Services models on a schedule.

You could combine this with the article I wrote on pausing and resuming a VM from Data Factory, to use this as a trigger instead or even call the PowerShell scripts from Azure DevOps to automate the starting of a development server when you are running your testing pipelines.

***
## Step 1: Create an Azure automation account
From within the Azure portal, navigate to the `Automation Account` service and create a new account.
You will need elevated privledges to create this account.
Make sure to create this account within the same subscription and resource group as the Azure Analysis Services model you want to control.
The `Create Azure Run as account` option must be set to 'Yes'.

***
## Step 2: Import the required modules
You will need to import the `AzureRM.Profile` and `AzureRM.AnalysisServices` module for the automation account.

{{< admonition type=warning title="Using AzureRM PowerShell Modules" open=true >}}

The AzureRM modules will be retired on February 29, 2024, so this script needs to be updated to use the new Az PowerShell modules. However, I haven't foudn the time to do that yet, so let me know if you know anyone who already has!

{{< /admonition >}}

***
## Step 3: Create a runbook and adjust parameters
Create a PowerShell runbook using the script `ScalingSchedule.ps1` in [this repo](https://github.com/lmcconnell1665/AzureAnalysisServices-StartStop). This script has a few required parameters that you must configure for your specific environment.

These parameters can be changed in the code of the runbook or in the user interface. I like changing them in the code so that the default values that appear in the user interfact and always correct.

### Configuring parameters using GUI
{{< image src="/img/azure-autoscale-analysisservices/Parameters.png" caption="This is what the window looks like when you start the runbook and need to configure your parameters (defaults controlled within code).">}}

### Configuring parameters within PowerShell script

```PowerShell
# Found in lines 61 - 79 of the script
param(
[parameter(Mandatory=$false)]
[string] $environmentName = "AzureCloud", # Leave this one alone, unless you are operating on another cloud such as Azure Gov Cloud
 
[parameter(Mandatory=$false)]
[string] $resourceGroupName = "rg-analysis-services", # Set this to the name of the resource group your Azure Analysis Services model lives in
 
[parameter(Mandatory=$false)]
[string] $azureRunAsConnectionName = "AzureRunAsConnection", # Leave this one alone, unless you changed the name of your "RunAs" Account from the default

[parameter(Mandatory=$false)]
[string] $serverName = "scalingautomation", # Set this to the name of the Azure Analysis Services server you want to control (just the name, not the full link to the server)

[parameter(Mandatory=$false)]
[string] $scalingSchedule = "[{WeekDays:[1], StartTime:'12:59:59', StopTime:'13:10:59', Sku: 'B2'}, {WeekDays:[2,3,4,5], StartTime:'12:59:59', StopTime:'13:10:00', Sku: 'B1'}]", # Set this to match the schedule you want your model to keep (including days, times, and tiers)
 
[parameter(Mandatory=$false)]
[string] $scalingScheduleTimeZone = "Central Standard Time" # Set this to the time zone of your schedule
)
```

***
## Step 4: Link to a schedule
Create an automation schedule to run this script at a regular frequency (I'd recommend once every hour). Automation runbooks are very cheap (first 500 minutes of runtime a month are free, then $0.002 per minute of runtime). This script will run at the set interval, check to see what the status of the server is and adjust it if it doesn't match the schedule for that time period. If there is not a set schedule for a time period, the server will be paused.

### Note:
I really like this because I can make manual adjustments to the tier of the model myself (if I needed more processing power for an unscheduled deployment, for example), and the script will come at the top of the next hour and correct the pricing tier back to the schedule. However, sometimes this can be inconvenient so you will need to temporarily disable the schedule.