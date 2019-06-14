# MBTA-Denial-Project

## Purpose

The purpose of this project is to evaluate Buyers' denial rates/frequencies on requisitions within the Procurement and Logistics Division. Data is from over the first three quarters of the 2019 MBTA Fiscal Year.

### Package Requirements

#### Software Packages

* `R 3.5.1`

#### R Packages

* `dplyr` for data manipulation
* `lubridate` for date handling
* `tidyverse` for data tidying
* `kableExtra` for generating tables
* `readxl` for importing data from excel
* `ggplot2` for data visualization (not explicitly used but this project could potentially feature a graph/chart)
* `tidyr` for data tidying

### Data Requirements

This project takes 2 excel files as input:

#### `SLT_DENIAL_PUBLIC.xlsx`

This excel file should contain the following columns:

| Columns                      | Purpose/Use                               |
| ---------------------------- | ----------------------------------------- |
| PO_NO                        | Unique Identifier of each Purchase Order  |
| Work_List                    | Not used                                  |
| Approval_Number              | Not used                                  |
| Appr_Status                  | Approval Status; all "D" in this case     |
| Status                       | Same as previous column; all "Denied"     |
| Date_Time                    | Date of Denial                            |
| User                         | Not used                                  |
| Unit                         | Business Unit of Purchase Order           |
| Status2                      | PO Status                                 |
| Dispatch_DTTM                | Timestamp of the last change made to PO   |
| Threshold                    | Price range that PO falls in to           |
| Buyer                        | Buyer assigned to that PO                 |
| Line_Count                   | Line of PO; always 1 in this case         |

* NOTE: Multiple denials on one requisition are counted individually rather than simply as one denial; as theoretically the Buyer made multiple, separate mistakes warranting multiple denials despite it being on one requisition

#### `REQ_TO_PO_SPILT_PO_SIDE_DanZ.xlsx`

This excel file should contain the following fields:

| Columns                     | Purpose/Use                                |
| ----------------------------| -------------------------------------------|
| Business_Unit               | Business Unit of Purchase Order            |
| PO_No.                      | Unique Identifier of each Purchase Order   |
| PO_Line                     | Line number within each PO                 |
| Status                      | PO Status                                  |
| PO_Date                     | Date of Purchase Order approval            |
| Buyer                       | Buyer assigned to that PO                  |
| Origin                      | Not used                                   |
| Approved_By                 | Not used                                   |
| Mfg_ID                      | Not used                                   |
| Mfg_Itm_ID                  | Not used                                   |
| PO_Qty                      | Not used                                   |
| Sum_Amount                  | Total amount spent on that PO line         |
| Level_1                     | Category of Purchase Order                 |
| Level_2                     | Categoru of PO under umbrella of Level_1   |
| Vendor_Name                 | Name of company we buy from for that PO    |
| Descr                       | Description of that line of PO             |
| Item                        | Not used                                   |
| Req_ID                      | Unique Identifier of req  that PO came from|
| REQ_Line                    | Line number within each requisition        |
| QuoteLink                   | Not used                                   |
| Vendor                      | Vendor ID; Unique Identifier of each vendor|

### Output File(s)

This project compiles a table featuring each Buyer, their buyer team, the number of denied PO's they've had over the first three quarters of the fiscal year, their total number of PO's over the same time period, and a percentage that is Denial Count/Total PO count.
