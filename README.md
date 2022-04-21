# OULAD_ETL
## Tools
SSIS: Visual Studio 2019, SQL Server
## Dataset
- Source from: https://analyse.kmi.open.ac.uk/open_dataset.
- Decription:
1. Database schema
<img src="image/Database_Schema.png">
2. Row count
<img src="image/Rowcount.png">
3. Data flow architecture
<img src="image/Dataflow.png">
<img src="image/Dataflow_full.png">
-** Staging table: ** Structure of Staging tables are excactly same sources data, except St_StudentVle have 1 more date_click column. Staging table stores in Stage_Elearning database.
- ODS (Operational Data Source): ODS is joined from all Staging table. ODS have almost all columns in Staging table.

