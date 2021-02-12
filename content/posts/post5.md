---
title: "Storing Stock API Data in DynamoDB"
date: 2020-06-20T04:06:22Z
author:
authorLink:
description:
tags:
- AWS
- Data Pipeline
- DynamoDB
categories:
- Tutorial
draft: false
hiddenFromHomePage: true
---

***
[Access the GitHub repo here](https://github.com/lmcconnell1665/StockTrader)

![Python application test with Github Actions](https://github.com/lmcconnell1665/StockTrader/workflows/Python%20application%20test%20with%20Github%20Actions/badge.svg)

***
## Introduction

A machine learning project that I am working on requires access to historical stock trading data.
[Alpha Vantage](https://www.alphavantage.co) provides a free API for accessing this kind of data and I am storing the information that I retrieve from this API in an AWS DynamoDB table.
DynamoDB is a very simple, managed NoSQL database service from AWS that can automatically scale to hold a near-unlimited amount of data.

I have built a command line tool using the [Click](https://click.palletsprojects.com) framework in Python.
Configuration and use of this tool to pull and store data from an API can be easily adapted using the source code in [this public GitHub repo](https://github.com/lmcconnell1665/StockTrader).

***
## Step 1: Install this command line tool
Clone this GitHub repo by running `git clone https://github.com/lmcconnell1665/StockTrader.git` from your terminal. 
Once the repository has been cloned, change into the repository directory by running `cd StockTrader`.

***
## Step 2: Configure the tool
Open the `stonk.py` file and change the values for `DYNAMO_DB_TABLE_NAME` and `AWS_REGION` to match your environment.
You will need to create a DynamoDB table with `ticker` as the Primary partition key and `date` as the primary sort key.
Make sure that the name of that table matches your setting of `DYNAMO_DB_TABLE_NAME` in `stonk.py`.
The environment that you install the command line tool in will also need the proper AWS credentials to read and write to this DynamoDB table.

***
## Step 3: Use this tool
There are two primary commands with this tool, grab and clear.
- grab: pull in stock data from API
- clear: clear all stock data from the database

Each command requires one argument (--ticker), which is the ticker that corresponds to the stock that you want to grab or clear.

### Grab command
Run `python stonk.py grab` from a terminal with your directory in `/StockTrader`.
You will be asked to enter an `api_key` to authenticate with the API.
You can set a default for this key by changing the value for `TOKEN` in `stonk.py`.
Once a default is set it will be displayed in brackets.
Just press `enter` to use the saved default value for the token.
You will be asked to enter a `ticker` for the stock you want to grab.
Once you see `DONE grabbing` the stocks historical information has been saved to the DynamoDB table.

### Clear command
Run `python stonk.py clear` from a terminal with your directory in `/StockTrader`.
You will be asked to enter a `ticker` for the stock you want to clear.
Once you see `DONE deleting` the stocks historical information has been removed from the DynamoDB table.

***
## Demo

{{< youtube tU_yvEbdsPE >}}