---
title: "Create Delta Tables in Databricks"
date: 2023-09-09T04:06:22Z
author:
authorLink:
description:
tags:
- Databricks
- Delta Tables
categories:
- Tutorial
draft: false
hiddenFromHomePage: true
---

## Introduction

I find myself googling the syntax for these commands all the time. So here's some quick shortcuts:

***
## [Save df as delta table](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/api/pyspark.sql.DataFrameWriter.saveAsTable.html#pyspark.sql.DataFrameWriter.saveAsTable)

```python
# format
df.saveAsTable(name, format, mode, portitionBy)

# example
df.write.saveAsTable(delta_path, mode='overwrite')
```

### modes
- `append`: Append contents of this DataFrame to existing data.
- `overwrite`: Overwrite existing data.
- `error` or `errorifexists`: Throw an exception if data already exists.
- `ignore`: Silently ignore this operation if data already exists.


