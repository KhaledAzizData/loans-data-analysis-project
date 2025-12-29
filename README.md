* Loan Repayment Analysis

This project analyzes loan-level data to understand repayment behavior and credit risk.
Each row in the dataset represents one loan, not a customer.

The analysis focuses on identifying patterns associated with late repayments and comparing credit exposure across different groups.

*Questions Answered

-How do on-time and late loans differ?

-Does employment stability, income type, or education level affect late payment rates?

-Which segments have the highest average loan amounts?

-How heavy is the repayment burden relative to income and credit size?

*Tools Used

-PostgreSQL

Views, CTEs, window functions

-Power BI

Interactive dashboard

Decomposition Tree, KPI cards, slicers

*Data Preparation (SQL)

Created a unified view for analysis

Standardized repayment status (on time / late)

Derived:

Age and employment length

Payment-to-income and payment-to-credit ratios

Used window functions for portfolio-level percentages

*Dashboard Highlights

Repayment status distribution

Late payment rate by:

Employment stability

Income type

Education level

Family status

Average loan amount by segment

Slicers allow interactive filtering by repayment status, age group, and employment stability.

*Key Insights

-Shorter employment history is linked to higher late payment rates

-Higher education correlates with higher loan amounts, not necessarily higher risk

-Income type shows clear differences in repayment behavior

-Ratio-based metrics are more informative than loan amount alone

