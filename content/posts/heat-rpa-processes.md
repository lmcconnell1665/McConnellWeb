---
title: "Implementing RPA at Scale using HEAT Methods"
date: 2022-11-5T04:06:22Z
author:
authorLink:
description:
tags:
- Power Automate
- RPA
categories:
- Best Practices
draft: false
---

***

## Introduction

At the heart of digital transformation is automation. As my company has been on this journey, I've noticied two challenges with process automation that needed a solution:

- Identifying the right candidates: How does an organization target the right processes to automate, taking both ROI and complexity into account? Stakeholders need both quick wins and a large return in time/dollar savings.

- Managing deployment at scale: As additional RPA solutions are developed, artifacts begin to scatter across the organization. One process is deployed for a team in isolation using Azure Functions while another lives in a Power Automate solution file tied to another developer's personal account. There is no enterprise visibility into the success of the RPA campaign.

***

## Holistic Enterprise Automation Techniques (HEAT)

The first tool that helped me begin to wrap my head around a strategy for deploying RPA across an organization is the HEAT method. Starting with process before tooling, this approach helps establish a Center of Excellence mindset with a 7 step process for each automation initiative.

[You can learn more about HEAT methods here.](https://flow.microsoft.com/en-us/blog/heat-holistic-enterprise-automation-techniques-for-rpa-and-more/)

***

## Identifying the Right Candidates

Not every job is the right candidate for automation. As an organization begins a campaign to search for processes to target, you need to view each opportunity through two lenses:

&nbsp;

**Technical Complexity:** Some processes are easier to automate then others. An organization needs to know the right questions to ask to determine the potential complexity before targeting the process as a candidate.

[Here's where I started to come up with these questions.](https://enterprisersproject.com/article/2019/6/rpa-robotic-process-automation-find-use-cases#:~:text=If%20you%20answer%20yes%20to%20these%20questions%2C%20you%E2%80%99ve,task%20more%20than%20once%20per%20week%3F%20More%20items)

&nbsp;

**ROI:** Time is money. How does an organization calculate return on investment for each of these potential candidates?





***

## Managing Deployment at Scale

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

## Conclusion

Check out some of the resources below to see how easy it is to get started with Bicep or other IAC languages. If your organization is looking for help or advice on implementing these strategies, reach out to me!

*** 

## Additional Resources

- [Azure Bicep Templates - Open Source](https://github.com/Azure/ResourceModules)
- [Azure Bicep Learning Path](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep)
- [Terraform Tutorials](https://learn.hashicorp.com/terraform)
- [How to Export IAC Templates from Resources in Azure](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/export-template-portal)
