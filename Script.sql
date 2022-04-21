-- add column date_submitted(date format) in St_StudentAssessment
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

/* ALTER TABLE St_StudentAssessment
add date_submitted varchar(50)
 */

--- row count all table in db
CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)
EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY table_name, row_count DESC
DROP TABLE #counts

-- update column length to st_studentregistration from st_course
UPDATE 
    St_StudentRegistration
SET 
    St_StudentRegistration.module_length = St_Course.length
FROM 
    St_StudentRegistration
    left JOIN St_Course 
		ON St_StudentRegistration.code_module = St_Course.code_module
		and St_StudentRegistration.code_presentation = St_Course.code_presentation
/* ALTER TABLE St_StudentRegistration
add module_length varchar(50)
 */

-- update column activity_type to st_studentvle from st_vle
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

-- update column assessment_type, nod_deadline, weight, date_deadline to St_StudentAssessment from St_Assessment
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

-- convert white blank to null value St_StudentRegistration
update [St_StudentRegistration]
set date_unregistration = null 
where date_unregistration = ''

-- DELETE FROM [ODS] WHERE date_ods is null;

/* ALTER TABLE St_StudentVle
add activity_type varchar(50)
 */

--ALTER TABLE St_StudentAssessment
--add assessment_type varchar(50),
--nod_deadline varchar(50),
--weight varchar(50),
--date_deadline varchar(50)

