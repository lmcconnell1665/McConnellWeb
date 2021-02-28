---
title: "Processing Analysis Services Model from Azure Data Factory"
date: 2020-10-21T04:06:22Z
author:
authorLink:
description:
tags:
- Azure
- Data Pipeline
- Analysis Services
categories:
- Tutorial
draft: false
hiddenFromHomePage: true
---

***
[Access the GitHub repo here](https://github.com/lmcconnell1665/AnalysisServicesRefresh-AzureDataFactory)

***
## Introduction

At the core of many enterprise-scale data solutions is an [Analysis Services](https://azure.microsoft.com/en-us/services/analysis-services/) model that holds all of this data in memory for quick and efficient access.
As the data that is stored in this model is updated, the model needs to be "processed" for the changes to be reflected to end users.
This tutorial details how you can use an [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) pipeline to automate the processing of an analysis services model.


{{< admonition type=info title="Incomplete walk thru" open=true >}}

I haven't had a chance to create step-by-step documentation for this process. However, the `json` file linked in the GitHub repo above can be imported into Azure Data Factory to allow many of the settings to be configured directly within the ADF GUI. 

The author of the pipeline has a great [walk thru of the setup process](https://medium.com/ricoh-digital-services/process-azure-analysis-services-models-with-azure-data-factory-v2-d7c6288f352c).


{{< /admonition >}}

***

