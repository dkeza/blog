---
title: "Projects"
date: 2019-11-24T18:59:23+01:00
draft: false
staticpage: true
contactform: false
---
Here is list of my side projects

# GoExpenses
 
This is expenses app, which I am using to track my expenses. Exchange rate between RSD and EUR currencies is automatically updated daily. User can create accounts, expenses and incomes.   
It is possible to use SQLite or PostgreSQL database.

That can be set in goexpenses.ini file:

{{< highlight bash >}}
[settings]
databasetype=postgres
{{< /highlight >}}

For SQLite *databasetype* should be set to *sqlite*.  
In goexpenses.ini file is possible also to set other parameters, like mail server, openexchange id etc.

[Live web site goexpenses.kezic.net](https://goexpenses.kezic.net/)  
[Source on Github](https://github.com/dkeza/goexpenses)


