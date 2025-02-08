# Data-Analysis-using-MySQL-Workbench

Overview

In this project, I conducted a data analysis for a fictional company named MintClassics. The goal was to analyze their database to explore potential opportunities to reorganise the inventory and remove one of their storage facilities from the chain.

Database Structure

A relational database was provided for this company, including nine entities: warehouses, products, productlines, orders, orderdetails, payments, customers, employees, offices, which each have several attributes. The file containing the script to create and populate the Mint Classics relational database is available on the repository files (mintclassicsDB.sql). Coursera provided this file. 

Analysis Conducted

After exploring the database and identifying the required parts of the database for this analysis, I extracted a number of insights around the four warehouses in MintClassics. 6 figures were calculated based on this insight, which was then summarised on a weighted average named PerformanceScore. This performance score was the final criteria to rank warehouses and the South Warehouse with the lowest score on this variable was identified as the reluctant facility and the suitable candidate to be removed with the lowest negative impact. The full analysis queries have been provided by me on the repository files (Full Final Analysis Query.sql).

