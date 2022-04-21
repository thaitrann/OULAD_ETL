# OULAD_ETL
## Tools
1. SSIS: Visual Studio 2019, SQL Server
## Dataset
1. Source from: https://analyse.kmi.open.ac.uk/open_dataset
2. **Database schema** <p align = 'center'><img src="image/Database_Schema.png" alt="Italian Trulli"></p>
3. **Row count** <p align = 'center'><img src="image/Rowcount.png" alt="Italian Trulli"></p>
## Data warehouse(DWH) - data mart(DM)
1. **Type of Schema**: Star schema <p align = 'center'><img src="image/StarSchema.png" alt="Italian Trulli"></p>
2. **Data flow architecture** <p align = 'center'><img src="image/Dataflow.png" alt="Italian Trulli"></p> <p align = 'center'><img src="image/Dataflow_full.png" alt="Italian Trulli"></p>
- **Staging table**: Structure of Staging tables are excactly same sources data, except St_StudentVle have 1 more date_click column. Staging table stores in Stage_Elearning database.
- **ODS (Operational Data Source)**: ODS is joined from all Staging table. ODS have almost all columns in Staging table. ODS store in ODS_Elearning database.
- **Take note**: When I create ODS table, 
## Data warehouse(DWH) - data mart(DM)
