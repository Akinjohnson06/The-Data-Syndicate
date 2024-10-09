SELECT current_schema();
--view the data (for the students table)
SELECT * 
FROM student_performance_data;

--view the data (for the teachers table)
SELECT * 
FROM teacher_performance_data;

--Count the number of students that filled the survey form
SELECT COUNT (*) AS no_of_students
FROM student_performance_data


--DESCRIPTIVE STATISTICAL ANALYSIS
--Calculating the Average, Median and Mode for study hours
SELECT ROUND(CAST(AVG(study_hours) AS NUMERIC), 2) AS avg_study_hours, 
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY study_hours) AS median_study_hours,
       MODE() WITHIN GROUP (ORDER BY study_hours) AS mode_study_hours
FROM student_performance_data;

--Calculating the average of exam scores in the past term and the percentage of students who attend private tutoring
SELECT 
   ROUND(CAST(AVG(exam_score) AS numeric), 2) AS avg_exam_score,
   ROUND((SUM(CASE WHEN private_tutoring = 'Always' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_always,
   ROUND((SUM(CASE WHEN private_tutoring = 'Occasionally' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_occasionally,
   ROUND((SUM(CASE WHEN private_tutoring = 'Never' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_never,
   ROUND((SUM(CASE WHEN private_tutoring = 'Frequently' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_frequently
FROM student_performance_data;

--Count of students who use online resources and who attend private tutoring
SELECT 
  COUNT(CASE WHEN online_platforms = 'Yes' THEN 1 END) AS students_using_online_platforms,
  COUNT(CASE WHEN private_tutoring = 'Always' THEN 1 END) AS students_attending_tutoring
FROM student_performance_data;

--Calculate the average number of students who use online platforms and the effect on their exam scores.
SELECT 
  online_platforms, 
  ROUND(AVG(exam_score), 2) AS avg_exam_score
FROM student_performance_data
GROUP BY online_platforms;


--Calculating the percentage of students who use online platforms and attend private tutoring in comparison to those who do not
SELECT
   -- Percentage of students using online platforms
   ROUND((SUM(CASE WHEN online_platforms = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_using_online_resources,
   
   -- Percentage of students attending private tutoring
   ROUND((SUM(CASE WHEN private_tutoring != 'Never' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_attending_private_tutoring,
   
   -- Percentage of students who neither use online platforms nor attend tutoring
   ROUND((SUM(CASE WHEN online_platforms = 'No' 
   					AND private_tutoring = 'Never' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_not_using_online_or_tutoring,

   -- Percentage of students using online platforms AND attending tutoring
   ROUND((SUM(CASE WHEN online_platforms = 'Yes' 
   					AND private_tutoring != 'Never' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS percent_using_online_and_tutoring
FROM student_performance_data;

--Calculating the average exam score for each tutoring category
SELECT 
  private_tutoring, 
  ROUND(AVG(exam_score), 1) AS avg_exam_score
FROM student_performance_data
GROUP BY private_tutoring;
/* This is to explore the impact of private tutoring on exam scores */


--CORRELATION ANALYSIS
SELECT 
   CORR(exam_score, study_hours) AS correlation_coefficient
FROM 
   student_performance_data;

SELECT 
  ROUND(CAST(CORR(exam_score, study_hours) AS numeric), 2) AS corr_exam_hours, 
  ROUND(CAST(CORR(exam_score, 
       CASE 
         WHEN private_tutoring = 'Always' THEN 4
         WHEN private_tutoring = 'Frequently' THEN 3
         WHEN private_tutoring = 'Occasionally' THEN 2
         ELSE 1
       END) AS numeric), 2) AS corr_exam_tutoring
FROM student_performance_data;
/* There is no correlation at all between the hours studied and the score of the students last term's exam as well as 
the students involvement in private tutoring */


--CROSS TABULATION (Contingency Table)
--calculating the average exam score for each combination (private_tutoring and online_platforms)
SELECT 
  private_tutoring, 
  online_platforms, 
  ROUND(AVG(exam_score), 2) AS avg_exam_score
FROM student_performance_data
GROUP BY private_tutoring, online_platforms;

--calculating the average exam score for each combination (study hours and online platforms)
SELECT 
  study_hours, 
  online_platforms, 
  ROUND(AVG(exam_score), 2) AS avg_exam_score
FROM student_performance_data
GROUP BY study_hours, online_platforms;

--comparing the percentage of students using online platforms who scored above/below the average exam score
WITH average_score AS (
  SELECT ROUND(AVG(exam_score), 2) AS avg_score
  FROM student_performance_data
)
SELECT 
  online_platforms,
  (SELECT avg_score FROM average_score) AS avg_exam_score, -- Include the average score
  ROUND(COUNT(CASE WHEN exam_score >= (SELECT avg_score FROM average_score) THEN 1 END) * 100.0 / COUNT(*), 2) AS percent_above_avg,
  ROUND(COUNT(CASE WHEN exam_score < (SELECT avg_score FROM average_score) THEN 1 END) * 100.0 / COUNT(*), 2) AS percent_below_avg
FROM student_performance_data
GROUP BY online_platforms;


--Analysis from the Teachers table
--Distribution of Mock exam frequency
SELECT mock_exams, COUNT(*) AS frequency
FROM teacher_performance_data
GROUP BY mock_exams
ORDER BY frequency DESC;

--Average passing rate by learning materials availability
SELECT learning_materials, 
       ROUND(AVG(
           CASE 
               WHEN passing_rate ~ '^[0-9]+$' THEN CAST(passing_rate AS numeric)
               WHEN passing_rate ~ '^[0-9]+-[0-9]+$' THEN 
                   (CAST(SUBSTRING(passing_rate FROM '^[0-9]+') AS numeric) + 
                    CAST(SUBSTRING(passing_rate FROM '-([0-9]+)$') AS numeric)) / 2
               ELSE NULL
           END
       ), 2) AS avg_passing_rate
FROM teacher_performance_data
GROUP BY learning_materials;

--Top Challenges faced by students
SELECT students_challenge, COUNT(*) AS count
FROM teacher_performance_data
GROUP BY students_challenge
ORDER BY count DESC;

--Correlation between school resources and passing rate
SELECT 
    school_resources,
    ROUND(AVG(
        CASE 
            WHEN passing_rate = '0-30' THEN 15
            WHEN passing_rate = '31-50' THEN 50
            WHEN passing_rate = '>50' THEN 70
            ELSE NULL
        END
    ), 0) AS avg_passing_rate
FROM teacher_performance_data
GROUP BY school_resources;








