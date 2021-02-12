---
title: "Lubridate Package"
date: 2020-05-04T04:06:22Z
author:
authorLink:
description:
tags:
- R
- Tool of the Week
categories:
- Tool of the Week
draft: false
hiddenFromHomePage: true
---

***
> **Data Analytics Tool of the Week:** a new tool to gain insight from your data explained before you can finish your coffee

***
## Working with dates in R (without crying)

With almost any coding language, working with date and time data is a nightmare.
Data-generating systems all use different formats, countries all display information in different ways, and your boss has a personal preference to see dates displayed MM/YYYY/DD.
Lubridate is an R package that makes working with dates of any format simple.

&nbsp;

This package works by having an easy way to parse data of any format into the lubridate format and just as intuitive functions to extract the elements you need.
Check out the example video below to see how to parse and extract data and [this reference sheet](https://lubridate.tidyverse.org/reference/index.html) contains a large list of the different functions you can use.

***
## Example

{{< youtube VGVo5K9SNdQ >}}

###### A quick introduction to parsing dates and extracting information using lubridate.

***
## Code from Video 
(click the arrow to expand)

```R
library(lubridate)

birthday <- '09/1996/30'

bday_parsed <- myd(birthday)

month(bday_parsed)
month(bday_parsed, label = TRUE)
month(bday_parsed, label = TRUE, abbr = FALSE)

date(bday_parsed)
cat(month(bday_parsed), '/', day(bday_parsed), '/', year(bday_parsed), sep = '')

today <- Sys.time()
today_parsed <- ymd_hms(today)

as.numeric(date(today_parsed) - date(bday_parsed)) / 365
```

***
## More Resources

[Lubridate Overview and Installation Instructions](https://lubridate.tidyverse.org)

[Lubridate Cheatsheet](https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf)