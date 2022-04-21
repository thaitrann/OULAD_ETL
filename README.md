# OULAD_ETL
## Tools
SSIS: Visual Studio 2019, SQL Server
## Dataset
1. Source from: https://analyse.kmi.open.ac.uk/open_dataset.
2. Description:
- Database schema
<img src="image/Database_Schema.png" alt="Italian Trulli">
- Row count
<img src="image/Rowcount.png" alt="Italian Trulli">
- Data flow architecture
<img src="image/Dataflow.png" alt="Italian Trulli">
<img src="image/Dataflow_full.png" alt="Italian Trulli">
- Staging table: Structure of Staging tables are excactly same sources data, except St_StudentVle have 1 more date_click column. Staging table stores in Stage_Elearning database.<br>
- ODS (Operational Data Source): ODS is joined from all Staging table. ODS have almost all columns in Staging table.
---

