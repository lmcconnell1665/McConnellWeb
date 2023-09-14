---
title: "Row Level Security and Column Masking in Databricks"
date: 2023-09-09T04:06:22Z
author:
authorLink:
description:
tags:
- Databricks
- Delta Tables
- Unity Catalog
categories:
- Tutorial
draft: false
hiddenFromHomePage: true
---

## Introduction

Databricks supports both row level security (filtering of rows based on user identity) and dynamic data masking of columns (hiding data within specific columns for some users). Here are some code samples showing how this can be implemented: 


{{< admonition type=info title="Databricks Demos" open=true >}}

These code examples I am referencing came from the much more detailed `databricks demos` notebooks. [Check them out here.](https://www.databricks.com/resources/demos/tutorials/governance/table-acl-and-dynamic-views-with-uc)

{{< /admonition >}}


***
## Row level security
Row level security can be used to restrict the number of rows that a user can see. Think of this like a `where` clause to filter down data.

```sql
CREATE OR REPLACE FUNCTION region_filter(region_param STRING) 
RETURN 
  is_account_group_member('bu_admin') or -- admin can access all regions
  region_param like "%US%" or region_param = "CANADA";  -- everybody can access regions containing US or CANADA

-- country will be the column send as parameter to our SQL function (country_param)
ALTER TABLE customers SET ROW FILTER region_filter ON (country);
```

***
## Column masking
Dynamic column masking can be used to hide sensitive data from users. This can be useful when you need to mask data like SSN for most users and grant exceptions to others.

```sql
CREATE OR REPLACE FUNCTION simple_mask(column_value STRING)
   RETURN IF(is_account_group_member('bu_admin'), column_value, "****");

CREATE TABLE IF NOT EXISTS patient_ssn (
  `name` STRING,
   ssn STRING MASK simple_mask);
```
