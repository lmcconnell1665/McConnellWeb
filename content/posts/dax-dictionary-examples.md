---
title: "DAX Dictionary - Example Measures/Columns"
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
hiddenFromHomePage: true
---

***
## Introduction

I found myself referencing these DAX measures often to repurpose for new projects. Hopefully some of them can be useful for you as well!

[GitHub Issue: Integrate with DAXformatter.com](https://github.com/lmcconnell1665/McConnellWeb/issues/2)

***
## SUMX()
#### Takes a table as the first argument, and an expression you want to calculate row by row and then take the sun of as the second argument

{{< admonition type=example title="SUMX examples" open=true >}}
**Example 1:** Calculate Sales, which is the `Quantity` times the `Price` for the line items
```
Sales Amount =
SUMX ( Sales, Sales[Quantity] * Sales[Net Price] )
```

**Example 2:** Calculate the average sales per customer, for customers with a type = "Company"
```
Amount/Company = 
CALCULATE (
    AVERAGEX ( Customer, Sales[Sales Amount] ),
    Customer[Customer Type] = "Company"
)
```
{{< /admonition >}}

***
## AVERAGEX()
#### Takes a table as the first argument, and an expression you want to calculate row by row and then take the average of as the second argument

{{< admonition type=example title="AVERAGEX examples" open=true >}}
**Example 1:** Calculate the average delivery time for all sales (using `ALL()`) will make this measure return the same number no matter then filter context)
```
Avg All Delivery =
AVERAGEX ( ALL ( Sales ), Sales[Delivery Date] - Sales[Order Date] )
```

**Example 2:** Same calculation as Example 1, except will dynamically adjust based on the filter context of the row (average delivery time of the specific delivery)
```
Avg Delivery = 
AVERAGEX ( Sales, Sales[Delivery Date] - Sales[Order Date] )
```

**Example 3:** If the delivery time is longer then the average for all deliveries, return `Above Average`, else return `Below Average`
```
Delivery State = 
IF ( Sales[Delivery Date] - Sales[Order Date] >= [Avg All Delivery], "Above Average", "Below Average" )
```
{{< /admonition >}}

***
## Percent of Total Calculations
#### Different ways to adjust the filter context and calculate % of total

{{< admonition type=example title="Percent of Total Calculation examples" open=true >}}
**Example 1:** Basic percent of sales calculation
```
% of Sales = 
DIVIDE ( Sales[Sales Amount], CALCULATE ( Sales[Sales Amount], ALL ( Sales ) ) )
```

**Example 2:** Calculate percent of sales that are delivered in under 7 days
```
% Within 7 Days =
VAR OnTime =
    CALCULATE ( COUNTROWS ( Sales ), Sales[Delivery Working Days] <= 7 )
VAR TotalOrders =
    COUNTROWS ( ( Sales ) )
RETURN
    DIVIDE ( OnTime, TotalOrders )
```

**Example 3:** Calculate percent of total sales for the current year (total category sales / total sales for year)
```
% Year = 
// Get the sales amount for the selected year
VAR SalesAmount = Sales[Sales Amount]
// Get the sales table records where the [Year] is same as the selected year
VAR AllSalesTable =
    FILTER ( ALL ( Sales ), RELATED ( 'Date'[Year] ) IN VALUES ( 'Date'[Year] ) )
// Calculate the sum if multiplying quantity 
// times the price for each row in the AllSalesTable
VAR AllSalesAmount =
    SUMX ( AllSalesTable, Sales[Quantity] * Sales[Net Price] )
// Get the percent of the total (percent of total 
// sales of the category for selected year)
VAR Result =
    DIVIDE ( SalesAmount, AllSalesAmount )
RETURN
    Result
```

**Example 4:** Same as example 3, but using CALCULATE
```
% Year using Calculate :=
VAR SalesAmount = [Sales Amount]
VAR AllSalesAmount =
    CALCULATE ( [Sales Amount], ALL ( Sales ), VALUES ( 'Date'[Year] ) )
VAR Result =
    DIVIDE ( SalesAmount, AllSalesAmount )
RETURN
    Result
```

{{< image src="/img/post9/Percent-of-Total-by-Year.png" caption="Example of how Examples 3 & 4 can be used.">}}

{{< /admonition >}}

***
## ALL and ALLSELECTED()
#### Removes any filters from the selected columns or tables

{{< admonition type=example title="ALL and ALLSELECTED() examples" open=true >}}
**Example 1:** Calculate % of Total Sales (without letting report slicers affect the results)
```
% On All = 
DIVIDE ( [Sales Amount], CALCULATE ( Sales[Sales Amount], ALLSELECTED( Sales ) ) )
```
{{< /admonition >}}

***
## SWITCH()
#### Takes an expression as the first argument and then values to match and switch between (last argument can be the default if not previously matched)

{{< admonition type=example title="SWITCH examples" open=true >}}
**Example 1:** By setting the first argument of switch as `TRUE()` you can use it like a nested if function
```
Discount Category = 
VAR DiscountPercent =
    DIVIDE ( Sales[Unit Discount], Sales[Unit Price], 0 )
RETURN
    SWITCH (
        TRUE (),
        DiscountPercent > 0.10, "HIGH",
        AND ( DiscountPercent > 0.05, DiscountPercent <= 0.10 ), "MEDIUM",
        AND ( DiscountPercent <= 0.05, DiscountPercent > 0 ), "LOW",
        "FULL PRICE"
    )
```

**Example 2:** Need to generate a numerical `Sort By` column since it sorts alphabetically by default (Low, Medium, High isntead of High, Low, Medium)
```
Discount Category Sort = 
VAR DiscountPercent =
    DIVIDE ( Sales[Unit Discount], Sales[Unit Price], 0 )
RETURN
    SWITCH (
        TRUE (),
        DiscountPercent > 0.10, 3,
        AND ( DiscountPercent > 0.05, DiscountPercent <= 0.10 ), 2,
        AND ( DiscountPercent <= 0.05, DiscountPercent > 0 ), 1,
        0
    )
```
{{< /admonition >}}

***
## COUNTROWS() and DISTINCTCOUNT()
#### Takes a table or column as the first argument (don't forget how semantic models handle unknown values, by adding a BLANK() row, which is only counted by specific functions)

{{< admonition type=example title="COUNTROWS and DISTINCTCOUNT examples" open=true >}}
**Example 1:** Counts all of the rows in Sales (dynamic, based on the filter context of the row)
```
# Sales = COUNTROWS ( Sales )
```

**Example 2:** Counts the number of distinct values for the CustomerKey column in the Sales table (does *NOT* count BLANK rows)
```
# Customers = DISTINCTCOUNT( Sales[CustomerKey] )
```

**Example 3:** Counts the number of distinct values for the Order Date column in the Sales table (if a day does not exist as an order date in sales it is not counted)
```
# Days = DISTINCTCOUNT(Sales[Order Date])
```
{{< /admonition >}}

***
## RELATED() and RELATEDTABLE()
#### Allows you to access columns that are stored in related tables (relationship must already be created in the semantic model)

{{< admonition type=example title="RELATED and RELATEDTABLE examples" open=true >}}
**Example 1:** There is a relationship between the Sales and the Date table, so if a sale occured in a Working day it is multiplied by 0.001 versus a non-working day which is multiplied by 0.002
```
Bonus = 
SUMX (
    Sales,
    VAR Amt = Sales[Quantity] * Sales[Net Price]
    VAR Perc =
        IF ( RELATED ( 'Date'[Working Day] ) = 1, 0.001, 0.002 )
    RETURN
        Amt * Perc
)
```

**Example 2:** There is a relationship between the Customer and Date table (and this calculated column was created on the customer table), so find the `MAX` order date from the sales table for each customer
```
Last Updated = 
MAXX ( RELATEDTABLE ( Sales ), Sales[Order Date] )
```

**Example 3:** Find the total sales between a specific time period
```
First Week Sales = 
SUMX (
    FILTER (
        RELATEDTABLE ( Sales ),
        AND (
            Sales[Order Date] >= 'Product'[First Sale Date],
            Sales[Order Date] < 'Product'[First Sale Date] + 7
        )
    ),
    Sales[Quantity] * Sales[Net Price]
)

// Example 4: Create a new # Sales Transactions NA calculated column in the Product table that
counts the number of rows in Sales related to customers living in North America
# Sales Transactions NA = 
COUNTROWS (
    FILTER (
        RELATEDTABLE ( Sales ),
        RELATED ( Customer[Continent] ) = "North America"
    )
)
```
{{< /admonition >}}

***
## VARIABLES
#### Use variables to store values that need to be re-used (compares to a constant in other programming languages)

{{< admonition type=example title="VARIABLE examples" open=true >}}
**Example 1:**
```
Avg Discount = 
VAR GrossAmount = SUMX ( Sales, Sales[Quantity] * Sales[Unit Price] )
VAR Discount = SUMX ( Sales, Sales[Quantity] * Sales[Unit Discount] )
VAR AvgDiscount = DIVIDE ( Discount, GrossAmount )
RETURN
 AvgDiscount
```

**Example 2:**
```
Customer Age = 
IF (
    // if there is a missing value for either
    ISBLANK ( Customer[Last Updated] ) || ISBLANK ( Customer[Birth Date] ),
    // then return a blank
    BLANK (),
    // else calculate the age in days
    VAR AgeDays = Customer[Last Updated] - Customer[Birth Date]
    // then convert it to years
    VAR AgeYears =
        INT ( DIVIDE ( AgeDays, 365.25 ) )
    // then add some words to the end
    VAR Age =
        CONCATENATE ( AgeYears, " years" )
    // final the final string
    RETURN
        Age
```

**Example 3:** Variables can also be used to store tables
```
Delivery Working Days = 
VAR DateTable =
    FILTER (
        'Date',
        AND (
            AND ( 'Date'[Date] >= Sales[Order Date], 
                  'Date'[Date] <= Sales[Delivery Date] ),
            'Date'[Working Day] = "WorkDay"
        )
    )
RETURN
    COUNTROWS ( DateTable )
```
{{< /admonition >}}

***
## USING SLICER SELECTION AS METRIC PARAMETER
### Use the selected value from a slicer to dynamically adjust how a measure is calculated

{{< admonition type=example title="Slicer Selection examples" open=true >}}
```
Discounted Sales = 
VAR Discount =
    SELECTEDVALUE ( Discounts[Discount], 0 )
VAR PriceToUse =
    SELECTEDVALUE ( 'Price'[Price], "Use Net Price" )
VAR SalesAmount =
    IF (
        PriceToUse = "Use Unit Price",
        SUMX ( Sales, Sales[Quantity] * Sales[Unit Price] ),
        [Sales Amount]
    )
VAR Result = SalesAmount * ( 1 - Discount )
RETURN
    Result
```
{{< /admonition >}}

***
## CALCULATE()
### Using CALCULATE() to filter sales down to a unique combination of colors/brands

{{< admonition type=example title="CALCULATE() examples" open=true >}}
```
RedLitware/BlueContoso = 
CALCULATE (
    [Sales Amount],
    KEEPFILTERS (
        FILTER (
            ALL ( 'Product'[Color], 'Product'[Brand] ),
             ( 'Product'[Color], 'Product'[Brand] )
                IN { ( "Red", "Litware" ), ( "Blue", "Contoso" ) }
        )
    )
)
```
{{< /admonition >}}

***
## REMOVEFILTER()
### Removes all filters on a specific table 

{{< admonition type=example title="REMOVEFILTER() examples" open=true >}}
```
Audio Sales = 
CALCULATE (
    [Sales Amount],
    'Product'[Category] = "Audio",
    REMOVEFILTERS ( 'Product' )
)
```
{{< /admonition >}}