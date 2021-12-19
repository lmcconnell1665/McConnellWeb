---
title: "Do NOT Touch the Azure Portal"
date: 2021-12-18T04:06:22Z
author:
authorLink:
description:
tags:
- Azure
- Bicep
- Infrastructure as Code
categories:
- Best Practices
draft: false
---

***
## Introduction
Ok, the title might be a slight clickbait hyperbole, as the Azure portal is an extremely useful interface for monitoring resources and learning. 
Even as I write this, I have 3 different tabs open to the Azure portal.
However, what does make me cringe is watching production environments be pieced together with a series of inconsistent mouse-clicks or fleets of virtual machines be deployed in the same manner. 
This isn't naturally *repeatable* or *scalable*, which are both supposed to be major value propositions of shifting to the cloud.

***
## Infrastructure as Code
Instead of tasking IT with clicking around the portal to create resource, configure settings, and assign access your organization needs to adopt the best practice of provisioning and managing your resource lifecycle using one of the many infrastructure as code language options. 

&nbsp;

As I spend most of my time working on the Azure stack, I primarily use the Microsoft domain-specific language, [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview), for these type of deployments. 
This article is not a tutorial on Bicep (although I've linked some great tutorials below), but instead focusing on convincing you **WHY** your organization need to adopt this practice and the problems that can be solved with these techniques. 

***
## Reason 1: Consistency
Both a benefit and a curse, there are A LOT of options available to us in the cloud. 
As of writing, there are 462 different virtual machine SKUs in Azure, each of which has a series of additional options relating to storage, networking, and other attributes. 
Even if you have well documented instructions stating exactly what configuration your organizations applications should be running on, the element of human error will take effect as you move more and more to the cloud.

&nbsp;

**The problem:** Your organization deploys software solutions that require very specific configuration to operate correctly. 
IT spends a lot of time manually configuring what some call a "pet" server, that must be carefully cared for and maintained. 
When they fail, they must be carefully nursed back to health.

&nbsp;

**The solution:** Instead, using infrastructure as code, organizations can take a "cattle" approach to managing servers. 
If the detailed configuration of these servers is stored as code, when one server fails, it can be replaced with a new identically configured server in minutes.

***
## Reason 2: Scalability (automation)
So maybe launching the Azure portal to spin up a few simple resources isn't very time consuming, but I can almost guarantee you that your simple one resource deployment will slowly grow into a complex solution of integrated resources. 
Implement the best practice while it is small and simple, so that it can grow with you!
When your one resource deployment turns into a scale set of thousands of servers, you'll be glad you have a consistent template that makes managing at this scale easy.

&nbsp;

**The Problem:** A DevOps best practice is to have development, test, and production environments to use as you make changes. As these environments grow more complex, individually maintaining the configuration becomes significantly more difficult.

&nbsp;

**The Solution:** Using a tool like [Azure DevOps Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/), [GitHub Actions](https://docs.github.com/en/actions), or [Jenkins](https://www.jenkins.io) to automate resource deployment between environments can ensure even the most complex configurations stay in-sync. Below is an example of a deployment pipeline we use that stands up a completely refresh analytics environment including storage, servers, network security configuration, and automatic disaster recovery in a few minutes. This would take a human a long time to do, especially to do so error-free.

&nbsp;

{{< image src="/img/dont-touch-the-azure-portal/deployment-pipeline.png" caption="Azure DevOps deployment pipeline.">}}

***
## Reason 3: Governance
As more agile and self-service IT strategies are adopted to increase velocity, the biggest concern is making sure governance and regulatory compliance controls are ingrained throughout the organization. Should every cloud resource only be accessible from the company's internal network to protect data? Or should databases be configured with a specific number of vCores to keep costs under control?

&nbsp;

**The Problem:** Organizations need processes and controls in place to protect their cloud resources. As mentioned above, this can relate to networking/data security, user access, or resource size allocation. Often as changes are needed, a JIRA ticket (insert your company's ticketing system) is generated to gather the necessary documentation, which results in someone on the IT team making the change manually once the correct approvals are received. This can create a bottleneck as the amount of resources under their control grows. 

&nbsp;

**The Solution:** Say a developer needs to allocate more storage to a server because of a feature they are working on. If the infrastructure as code lives in the repository along-side the other project code artifacts, the developer can adjust the amount of allocated storage and include this code change in their [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests), right alongside all of the other code changes they are proposing. This creates a chain of custody as well as the ability to require the proper approvals before automatically adjusting the resource in Azure. Bonus: IAM role assignments can also be controlled via Bicep!

*** 
## Conclusion
Check out some of the resources below to see how easy it is to get started with Bicep or other IAC languages. If your organization is looking for help or advice on implementing these strategies, reach out to me!

*** 
## Additional Resources
- [Azure Bicep Templates - Open Source](https://github.com/Azure/ResourceModules)
- [Azure Bicep Learning Path](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep)
- [Terraform Tutorials](https://learn.hashicorp.com/terraform)
- [How to Export IAC Templates from Resources in Azure](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/export-template-portal)
