# OULAD - Open University Learning Analytics
## Tools
1. ETL: SSIS
2. Database: SQL Server
3. Visualization: Tableau Desktop
## Dataset
1. Source from: https://analyse.kmi.open.ac.uk/open_dataset
2. **Database schema** <p align = 'center'><img src="image/Database_Schema.png" alt="Italian Trulli"></p>
3. **Row count** <p align = 'center'><img src="image/Rowcount.png" alt="Italian Trulli"></p>
4. **Script create schema (Create_Starschema.sql)**
```
create table Dim_Assessments(
	sk_assessment_id int primary key not null,
	assessment_id int,
	assessment_type char(100),
	weight int
)

create table Dim_Vle(
	sk_site_id int primary key not null,
	site_id int,
	activity_type char(100)
)

create table Dim_Students(
	sk_student_id int primary key not null,
	student_id int,
	gender char(100),
	imd_band char(100),
	highest_education char(100),
	age_band char(100),
	disability char(100)
)

create table Dim_Modules(
	module_id int primary key not null,
	module_name char(100),
	module_length int
)

create table Dim_Presentations(
	presentation_id int primary key not null,
	presentation_name char(100),
)

create table Dim_Time(
	time_id int primary key not null,
	date_registration char(100),
	month_registration int,
	day_registration int,
	year_registration int,
	---
	date_unregistration char(100),
	month_unregistration int,
	day_unregistration int,
	year_unregistration int,
	---
	date_submitted char(100),
	month_submitted int,
	day_submitted int,
	year_submitted int,
	---
	date_deadline char(100),
	month_deadline int,
	day_deadline int,
	year_deadline int,
	---
	date_click char(100),
	month_click int,
	day_click int,
	year_click int
)

create table Dim_Regions(
	region_id int primary key not null,
	region_name char(100)
)

create table Fact_ELearning(
	row_id int primary key not null,
	sk_assessment_id int not null FOREIGN KEY REFERENCES Dim_Assessments(sk_assessment_id),
	module_id int not null FOREIGN KEY REFERENCES Dim_Modules(module_id),
	presentation_id int not null FOREIGN KEY REFERENCES Dim_Presentations(presentation_id),
	sk_site_id int not null FOREIGN KEY REFERENCES Dim_Vle(sk_site_id),
	time_id int not null FOREIGN KEY REFERENCES Dim_Time(time_id),
	sk_student_id int not null FOREIGN KEY REFERENCES Dim_Students(sk_student_id),
	region_id int not null FOREIGN KEY REFERENCES Dim_Regions(region_id),
	---
	studied_credits int,
	num_of_prev_attempts int,
	is_banked int default 0 check(is_banked = 0 or is_banked = 1),
	is_submission_assessment int check(is_submission_assessment = 0 or is_submission_assessment = 1), 
	-- check submission status. if students doesn't submit assessment then is_submission = 0, else is_submission_assessment = 1
	is_submission_late int check(is_submission_late = 0 or is_submission_late = 1), 
	-- check submission date. if students submit assessment after deadline then is_submission_late = 1, else is_submission_late = 0
	score_assessment float check(score_assessment >= 0 and score_assessment <= 100),
	sum_click_vle int,
	final_result char(100)
)
```
## Data warehouse(DWH) - data mart(DM)
1. **Type of Schema**: Star schema <p align = 'center'><img src="image/StarSchema.png" alt="Italian Trulli"></p>
2. **Data flow architecture** <p align = 'center'><img src="image/Dataflow.png" alt="Italian Trulli"></p> <p align = 'center'><img src="image/Dataflow_full.png" alt="Italian Trulli"></p>
- **Staging table**: Structure of Staging tables are excactly the same sources data, except St_StudentVle have 1 more date_click column. Staging table is stored in Stage_Elearning database.
- **ODS (Operational Data Source)**: ODS is joined from all Staging table. ODS have almost all columns in Staging table. ODS is stored in ODS_Elearning database.
- ** ***NOTE***: I used to create ODS with full data source. It took a long time to finish, my laptop almost froze when I ran it and sometimes my laptop's disk was full. So I decided to split St_StudentVle from about 10m rows to 200k rows with this code:
```
select top (200000)
*
from St_StudentVle
order by date_click
```
This absolutely changed my result, ODS table from storing 100 million rows only has 2 million rows left but I will try to figure out another way to handle full data. Sorry for my problem!
## ETL Implementation
I split control flow into 2 packages:
1. **LoadStaging.dtsx**: This package has control flow and data flow for loading from the data source to the staging table.
- Control Flow: <p align = 'center'><img src="image/LoadStaging/Pipeline_Stage.png" alt="Italian Trulli"></p>
- Data flow for Assessments.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow1.png" alt="Italian Trulli"></p>
- Data flow for Course.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow2.png" alt="Italian Trulli"></p>
- Data flow for StudentAssessment.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow3.png" alt="Italian Trulli"></p>
- Data flow for StudentInfo.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow4.png" alt="Italian Trulli"></p>
- Data flow for StudentRegistration.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow5.png" alt="Italian Trulli"></p>
- Data flow for StudentVle.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow6.png" alt="Italian Trulli"></p>
- Data flow for Vle.csv: <p align = 'center'><img src="image/LoadStaging/Dataflow7.png" alt="Italian Trulli"></p>
- Add column date_submitted(date format) in St_StudentAssessment: 
```
ALTER TABLE St_StudentAssessment
add date_submitted varchar(50)

WITH
    cte1
    AS
    
    (
        SELECT
            s_sta.id_assessment AS id_assessment,
            s_sta.id_student AS id_student,
            cast(dateadd(day, cast(s_sta.number_of_days_submitted AS int), DATEFROMPARTS(LEFT(s_a.code_presentation, 4), 
    CASE 
        WHEN RIGHT(s_a.code_presentation, 1) = 'B' THEN 2
    ELSE 10 END, 
    1)) AS varchar) AS date_submitted
        FROM St_StudentAssessment s_sta
            JOIN St_Assessment s_a ON s_sta.id_assessment = s_a.id_assessment
    ),
    cte2
    AS
    (
        SELECT
            cte1.date_submitted AS date_submitted,
            St_StudentAssessment.id_assessment,
            St_StudentAssessment.id_student
        FROM St_StudentAssessment
            JOIN cte1
            ON St_StudentAssessment.id_assessment = cte1.id_assessment
            AND St_StudentAssessment.id_student = cte1.id_student
    )
UPDATE St_StudentAssessment
SET St_StudentAssessment.date_submitted = cte2.date_submitted
FROM cte2 
JOIN St_StudentAssessment 
    ON St_StudentAssessment.id_assessment = cte2.id_assessment
    AND St_StudentAssessment.id_student = cte2.id_student
```
- Add column length to st_studentregistration from st_course
```
ALTER TABLE St_StudentRegistration
add module_length varchar(50)

UPDATE 
    St_StudentRegistration
SET 
    St_StudentRegistration.module_length = St_Course.length
FROM 
    St_StudentRegistration
    left JOIN St_Course 
		ON St_StudentRegistration.code_module = St_Course.code_module
		and St_StudentRegistration.code_presentation = St_Course.code_presentation
```
- Add column activity_type to St_StudentVle from St_Vle
```
ALTER TABLE St_StudentVle
add activity_type varchar(50)

UPDATE 
    St_StudentVle
SET 
    St_StudentVle.activity_type = St_Vle.activity_type
FROM 
    St_StudentVle
    left JOIN St_Vle 
		ON St_StudentVle.id_site = St_Vle.id_site
		and St_StudentVle.code_module = St_Vle.code_module
		and St_StudentVle.code_presentation = St_Vle.code_presentation
```
- Add column assessment_type, nod_deadline, weight, date_deadline to St_StudentAssessment from St_Assessment
```
ALTER TABLE St_StudentAssessment
add assessment_type varchar(50),
nod_deadline varchar(50),
weight varchar(50),
date_deadline varchar(50)

UPDATE 
    St_StudentAssessment
SET 
    St_StudentAssessment.assessment_type = St_Assessment.assessment_type,
	St_StudentAssessment.nod_deadline = St_Assessment.nod_deadline,
	St_StudentAssessment.weight = St_Assessment.weight,
	St_StudentAssessment.date_deadline = St_Assessment.date_deadline
FROM 
    St_StudentAssessment
    left join St_Assessment
		on St_StudentAssessment.id_assessment = St_Assessment.id_assessment
```
- Convert white blank to null value St_StudentRegistration
```
update [St_StudentRegistration]
set date_unregistration = null 
where date_unregistration = ''
```
- Row count all table in db
```
CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)
EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY table_name, row_count DESC
DROP TABLE #counts
```
2. **Load_ODS_DW.dtsx**: This package has control flow and data flow for loading from the the staging table, ODS table to DW.
- Control Flow: <p align = 'center'><img src="image/Load_ODS_DW/Pipeline_Dwh-Dm.png" alt="Italian Trulli"></p>
- ODS table: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow1.png" alt="Italian Trulli"></p>
- Dim_Modules: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow2.png" alt="Italian Trulli"></p>
- Dim_Presentations: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow3.png" alt="Italian Trulli"></p>
- Dim_Assessments: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow4.png" alt="Italian Trulli"></p>
- Dim_Vle: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow5.png" alt="Italian Trulli"></p>
- Dim_Students: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow6.png" alt="Italian Trulli"></p>
- Dim_Regions: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow7.png" alt="Italian Trulli"></p>
- Dim_Time: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow8.png" alt="Italian Trulli"></p>
- Fact_Elearning: <p align = 'center'><img src="image/Load_ODS_DW/Dataflow9.png" alt="Italian Trulli"></p>
- ** ***NOTE***: I could use ODS for loading all tables in DWH but it took a long time to finish all tables. Therefore, I used ODS for some tables that have multiple columns to load(Dim_Time, Fact_Elearning). I also checked the similarity between staging tables and ODS tables to ensure data integrity.
- ** ***NOTE***: According to the description of the database, St_StudentAssessment and St_StudentVle tables don't record students who don't submit assessments or don't use vle. Therefore, when I load ODS, some students have null values in id_assessment column or id_site column. To fix that problem, I added a line containing only null values in the Dim_Assessment and Dim_Vle tables when loading these tables. This code is into "OLE DB Source" in the data flow of these two tables.
- Dim_Assessment: 
```
SELECT id_assessment, assessment_type, weight
FROM St_Assessment
UNION
SELECT NULL AS Expr1, NULL AS Expr2, NULL AS Expr3
```
- Dim_Vle: 
```
SELECT [id_site]
      ,[activity_type]
  FROM [Stage_Elearning].[dbo].[St_Vle]
  union 
  select null, null
```
## Visualization
Link Tableau Public: https://tinyurl.com/bdf4wbzd
<p align = 'center'><img src="image/visualize/most student are male (52.27%).png" alt="Italian Trulli"></p>
## Model
---Updating---
