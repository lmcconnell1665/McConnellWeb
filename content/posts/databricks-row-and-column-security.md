---
title: "Databricks Unity Catalog: Row Level Security and Column Level Security"
date: 2023-09-09T04:06:22Z
author:
authorLink:
description: "Implement row level security, column level security, and dynamic data masking in Databricks Unity Catalog. SQL examples for data governance and sensitive data protection in Delta tables."
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

***
## Frequently Asked Questions

**What is the difference between row level security and column level security in Databricks?**

Row level security filters which *rows* a user can see — similar to adding a `WHERE` clause per user. Column level security (dynamic data masking) controls which *column values* are visible, replacing sensitive data (such as SSNs or emails) with masked values like `****` for unauthorized users while returning the real values for admins.

**Do I need Unity Catalog to implement row level security in Databricks?**

Yes. Row filters and column masks using SQL functions (as shown above) require Databricks Unity Catalog. The legacy Table ACLs in the Hive metastore do not support these fine-grained access controls. If you are still on the Hive metastore, you will need to migrate to Unity Catalog first.

**How does dynamic data masking work in Databricks Unity Catalog?**

You create a masking function using `CREATE FUNCTION` that returns either the real value or a masked substitute based on the calling user's group membership. You then attach that function to a specific column with `ALTER TABLE ... ALTER COLUMN ... SET MASK`. Every subsequent query against that table automatically applies the masking logic at query time.

**Can I apply multiple row filters or column masks to the same table?**

Each table supports one active row filter and one mask per column at a time. You can replace existing filters or masks by rerunning the `ALTER TABLE SET ROW FILTER` or `SET MASK` commands with a new function.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the difference between row level security and column level security in Databricks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Row level security filters which rows a user can see — similar to adding a WHERE clause per user. Column level security (dynamic data masking) controls which column values are visible, replacing sensitive data with masked values for unauthorized users."
      }
    },
    {
      "@type": "Question",
      "name": "Do I need Unity Catalog to implement row level security in Databricks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Row filters and column masks using SQL functions require Databricks Unity Catalog. The legacy Table ACLs in the Hive metastore do not support these fine-grained access controls."
      }
    },
    {
      "@type": "Question",
      "name": "How does dynamic data masking work in Databricks Unity Catalog?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You create a masking function using CREATE FUNCTION that returns either the real value or a masked substitute based on the calling user's group membership. You then attach that function to a specific column with ALTER TABLE ... ALTER COLUMN ... SET MASK."
      }
    },
    {
      "@type": "Question",
      "name": "Can I apply multiple row filters or column masks to the same table?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Each table supports one active row filter and one mask per column at a time. You can replace existing filters or masks by rerunning the ALTER TABLE SET ROW FILTER or SET MASK commands with a new function."
      }
    }
  ]
}
</script>
