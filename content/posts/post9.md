---
title: "DAX Example Measures/Columns"
date: 2021-02-07T04:06:22Z
author:
authorLink:
description:
tags:
- DAX
- Analysis Services
- Power BI
categories:
- References
draft: false
---

***
## Introduction

I found myself referencing these DAX measures often to repurpose for new projects. Hopefully some of them can be useful for you as well!

***
## DAX Function
Take this [link to AWS](https://portal.aws.amazon.com/billing/signup#/start) and sign up for a free account.
The credentials you use to create this account will be your root user.
It is best practice NOT to use the root user to login to AWS.
I'd recommend creating yourself an admin IAM user and using this for the rest of the tutorial.

Once you have created your accounts and completed the setup process you should see the AWS Management Console.

{{< image src="/img/post8/AWSManagementConsole.png" caption="The AWS Management Console">}}

***
## DAX Function 2
Navigate to the `EC2` console by selecting this option under compute.
This is where we can create a virtual machine.
Next select `Spot Requests` on the left.
An AWS spot instance allows you to take advantage of unused compute nodes at a discounted price.
Instead of letting compute units that aren't currently in use in AWS data centers sit idle, they "auction" these off at a discounted price.

{{< image src="/img/post8/SpotRequest.png" caption="Spot Request Window">}}

The next page is where we select the kind of machine that we want to request.
This is where we can begin to leverage the benefits of the cloud.
Instead of being limited by the hardware of your local machine, we now can access a very powerful one in the cloud.
You are billed by the amount of time you use these resources. 
The more powerful the resources, the most expensive they are.

I used the following criteria to request a pretty powerful spot instance.
Adjust these to match your workload and don't forget to shut down these resources when you are finished with them.

Need: `Big data workloads`
Launch template: `None` (use one of these if you will set the same request often)
AMI: `Windows Server 2019` (this is how you select the flavor of virtual machine you will have)

{{< image src="/img/post8/WindowsAMI.png" caption="Search the community AMIs to find an operating system for the virtual machine. I recommend Windows for beginners for a familiar user experience (no command line code).">}}

Minimum compute unit: `c3.8xlarge` (this cost can add up if you forget to terminate the instance when done!) 

{{< image src="/img/post8/InstanceType.png" caption="Select the specs of your machine. The more CPUs and Memory the faster your machine learning models will run, but the more expensive the instance.">}}

Network: `leave as default`
Availability zone: `any is fine` (use the region that is closest to you, which is controlled in the top right of the AWS Management Console)
Key pair name: `Create a new pair` (VERY IMPORTANT: You must create and save a new key pair to connect to the instance. Walk through this process and download the .pem file to your local computer)

Target capacity: `1`
Fleet request settings: `uncheck "Apply recommendations"`

Click launch.

{{< image src="/img/post8/ActiveSpotRequest.png" caption="You should now see the active spot instance request. It will take a few minutes for AWS to fulfil your request.">}}
