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


delete [dbo].[Dim_Assessments]
delete [dbo].[Dim_Modules]
delete [dbo].[Dim_Presentations]
delete [dbo].[Dim_Regions]
delete [dbo].[Dim_Students]
delete [dbo].[Dim_Vle]
delete [dbo].Dim_Time
delete [dbo].Fact_ELearning

DROP TABLE [Dim_Assessments];
DROP TABLE [Dim_Modules];
DROP TABLE [Dim_Presentations];
DROP TABLE [Dim_Regions];
DROP TABLE [Dim_Students];
DROP TABLE [Dim_Vle];
DROP TABLE [dbo].[Dim_Time]
DROP TABLE Fact_ELearning;



