---
title: "Implementing RPA at Scale using HEAT Methods"
date: 2022-11-05T04:06:22Z
author:
authorLink:
description:
tags:
- Power Automate
- RPA
- Digital Transformation
categories:
- Best Practices
draft: false
---

***

## Introduction

At the heart of digital transformation is automation. As my company has been on this journey, I've noticed two challenges with process automation that needed a solution:

&nbsp;

- **Identifying the right candidates:** How does an organization target the right processes to automate, taking both ROI and complexity into account? Stakeholders need both quick wins and a large return in time/dollar savings.

&nbsp;

- **Managing deployment at scale:** As additional RPA solutions are developed, artifacts begin to scatter across the organization. One process is deployed for a team in isolation using Azure Functions while another lives in a Power Automate solution file tied to another developer's personal account. There is no enterprise visibility into the success of the RPA campaign.

***

## Holistic Enterprise Automation Techniques (HEAT)

The first tool that helped me begin to wrap my head around a strategy for deploying RPA across an organization is the HEAT method. Starting with process before tooling, this approach helps establish a Center of Excellence mindset with a 7 step process for each automation initiative.

[You can learn more about HEAT methods here.](https://flow.microsoft.com/en-us/blog/heat-holistic-enterprise-automation-techniques-for-rpa-and-more/)

***

## Identifying the Right Candidates

Not every job is the right candidate for automation. As an organization begins a campaign to search for processes to target, you need to view each opportunity through two lenses:

&nbsp;

**Technical Complexity:** Some processes are easier to automate then others. An organization needs to know the right questions to ask to determine the potential complexity before targeting the process as a candidate.

[Here's where I started to come up with the right questions to ask.](https://enterprisersproject.com/article/2019/6/rpa-robotic-process-automation-find-use-cases#:~:text=If%20you%20answer%20yes%20to%20these%20questions%2C%20you%E2%80%99ve,task%20more%20than%20once%20per%20week%3F%20More%20items)

&nbsp;

**ROI:** Time is money. How does an organization calculate return on investment for each of these potential candidates? These type of calculations have always existed, with a goal of ensuring that an organization doesn't spend months of development time automating a process that can be completed manually in a few minutes once a year.

{{< admonition type=example title="ROI Calculation" open=true >}}
**Cost of Process Occurance** = Hours the Process Owner Spends Completing Process * Value of 1 Hour of the Process Owner's time

**Cost of Process per Year** = Cost of Process Occurance * Number of Occurances per Year (include all users)

**Cost of Automation** = Cost to implement RPA process

**ROI** = Cost of Process per Year / Cost of Process Automation
{{< /admonition >}}

***

## Managing Deployment at Scale

There will be a variety of teams developing the automation solutions and a variety of tools / systems involved. Some implementations might include custom APIs built by development teams and other are desktop flows built internally by the finance team. An organization needs an overall governance strategy to monitor that these tools are being used effectively as well as provide executive visibility into the overall campaign success.

If you come from a Microsoft shop like me, there are a variety of tools available to aid with these enterprise deployment strategies. Here are a few of my favorites:

&nbsp;

**Automation Kit for Power Platform:** A Power Platform solution including tools to help organizations manage, govern, and scale automation platform adoption based on industry best practices. [Check it out here.](https://powerautomate.microsoft.com/en-us/blog/introducing-the-automation-kit-for-power-platform/)

&nbsp;

**Application Lifecycle Management (ALM) Environments:** The Power Platform allows you to separate your development, test, and production environments as well as automation deployment of solutions between these environments with ALM. [Learn more here.](https://learn.microsoft.com/en-us/power-platform/alm/overview-alm)

&nbsp;

**Hosted RPA Bots:** Managing infrastructure to run RPA bots at scale introduces an additional layer of complexity. The new Hosted RPA bots, adopts a cloud-native experience which allow you to run unattended automation at scale without the need to provide or set up any machines. [Check out this feature (in preview at time of writing) here.](https://learn.microsoft.com/en-us/power-automate/desktop-flows/hosted-rpa-bots)

***

## Conclusion

I am just beginning to scratch the surface in terms of enterprise RPA strategy. What other tools and techniques have you seen work at scale? [Let me know.](mailto:luke.m.mcconnell@gmail.com)