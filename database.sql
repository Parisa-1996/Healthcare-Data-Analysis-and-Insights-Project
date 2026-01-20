1. For each doctor, show the number of appointments they have had and the total fees collected (sum).

SELECT d.name AS doctor_name,count(a.appointment_date), sum(a.fee) as total_fee
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP by d.name;

2. Identify patients who have more than two appointments.

SELECT p.name as patient_name,  count(a.appointment_date)
FROM patients p
JOIN appointments a
on p.patient_id = a.patient_id
GROUP by p.name
HAVING count(a.appointment_date) > 2;

3. List the names of patients who have never received any prescription.

SELECT DISTINCT(p.name) as patient_name, count(pre.prescription_id)
FROM patients p
LEFT JOIN appointments a
ON p.patient_id = a.patient_id
Left JOIN prescriptions PRE
ON a.appointment_id = pre.appointment_id
GROUP by p.name
HAVING count(pre.prescription_id) = 0;

4. For each appointment, display the follow_up_date; if follow_up_date is not specified, 
display the appointment_date plus 30 days.

SELECT appointment_id,
CASE WHEN follow_up_date is NULL
    THEN date(appointment_date, '+30 days')
     ELSE follow_up_date END as follow_up
FROM appointments;


--5. For each doctor, compute their average appointment fee and return only those doctors 
--whose average is above the overall average appointment fee.

WITH overall_avg_fee AS (
    SELECT AVG(fee) AS avg_fee
    FROM appointments
)
SELECT 
    d.name AS doctor_name,
    AVG(a.fee) AS doctor_avg_fee
FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
CROSS JOIN overall_avg_fee o   -- اضافه کردن CTE برای استفاده در HAVING
GROUP BY d.name
HAVING AVG(a.fee) > o.avg_fee;



6. Use a CASE statement to classify patients into age groups: 
'Child' (<18), 'Adult' (18–64), and 'Senior' (65+). Count how many patients fall into each group.

SELECT count(patient_id) as patient_name,
CASE WHEN age < 18 THEN 'Child'
     WHEN age BETWEEN 18 AND 64 THEN 'Adult'
	 ELSE 'Senior' END as age_groups
FROM patients
GROUP by 
   CASE WHEN age < 18 THEN 'Child'
     WHEN age BETWEEN 18 AND 64 THEN 'Adult'
	 ELSE 'Senior' END;



7. For each patient, determine the time (in days) between their first and last appointment.

SELECT p.patient_id,julianday(max(a.appointment_date)) - julianday(min(a.appointment_date)) as days_betweem
FROM patients p
JOIN appointments a
on p.patient_id = a.patient_id
GROUP by p.patient_id;


8. For each department, rank the doctors by salary (highest to lowest) using DENSE_RANK. 
Show, doctor_id, doctor name, department name and salary rank.

SELECT d.doctor_id,d.name as doctor_name, de.name as department_name, d.salary,
dense_rank() OVER (ORDER by d.salary DESC)
FROM doctors d
JOIN departments de
on d.department_id = de.department_id
GROUP by d.doctor_id;

9. Find patients who have appointments in at least three different years.

SELECT p.name as patient_name, count(DISTINCT strftime('%Y',a.appointment_date)) as appointment_year
FROM patients p
JOIN appointments a
ON p.patient_id = a.patient_id
GROUP by p.patient_id
HAVING count( DISTINCT strftime ('%Y', a.appointment_date))>= 3;

10. For each appointment, compute the total treatment cost and then calculate the percentage that 
each treatment contributes to the appointment's total treatment cost.


SELECT 
    a.appointment_id,
    t.treatment_id,
    t.cost,
    SUM(t.cost) OVER (PARTITION BY a.appointment_id) AS total_cost,
    t.cost * 1.0 / SUM(t.cost) OVER (PARTITION BY a.appointment_id) AS percentage
FROM appointments a
JOIN treatments t 
    ON a.appointment_id = t.appointment_id;


17. Show appointments that have follow-up dates more than 30 days after the initial appointment date.

SELECT *
FROM appointments
WHERE follow_up_date > DATE(appointment_date, '+30 days');

							

18. List patients along with the total amount they have paid 
(sum of billing amounts across all their appointments).

SELECT 
    p.patient_id,
    SUM(b.amount) AS total_paid
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN billing b ON b.appointment_id = a.appointment_id
GROUP BY p.patient_id;



19. For each appointment, display the appointment_id and a column showing the follow-up date; 
if follow_up_date is null, display the string 'No follow-up scheduled'.

SELECT appointment_id,
CASE WHEN follow_up_date is NULL THEN 'No follow-up scheduled'
ELSE follow_up_date END as follow_up_date
FROM appointments;


20. Find the average age of patients for each blood type.

SELECT avg(age), blood_type
FROM patients
GROUP by blood_type;


21. For each patient, find their most recent appointment date.

SELECT p.patient_id, max(a.appointment_date)
FROM patients p
INNER JOIN appointments a
on p.patient_id = a.patient_id
GROUP by p.patient_id;



22. For each doctor, calculate the ratio of completed appointments to total appointments.

SELECT d.doctor_id,COUNT(CASE WHEN a.status = 'completed' THEN 1 END) * 1.0 / COUNT(*) 
AS completion_ratio
FROM doctors d
INNER JOIN appointments a
on d.doctor_id = a.doctor_id
GROUP by d.doctor_id;




23. Determine the top 5 patients by total treatment cost across all their appointments.

SELECT p.patient_id, sum(t.cost) as total_treatment_cost
FROM patients p
JOIN appointments a
on p.patient_id = a.patient_id
JOIN treatments t
on t.appointment_id = a.appointment_id
GROUP by p.patient_id
LIMIT 5;




24. Categorize doctors based on years_of_experience into 'Junior' (<5), 'Mid' (5-10), and 'Senior' (>10). 
Display each doctor's name and experience category.

SELECT name as doctor_name, CASE WHEN years_of_experience < 5 THEN 'Junior'
                                 WHEN  years_of_experience BETWEEN 5 AND 10 THEN 'Mid'
								 else 'Senior'  END as experience_category
								 FROM doctors;
								
								

25. For each department, show the doctor(s) with the highest salary.

SELECT d.name AS doctor_name, d.department_id, d.salary
FROM doctors d
WHERE d.salary = (
    SELECT MAX(salary)
    FROM doctors
    WHERE department_id = d.department_id
);

26. Identify patients who have received prescriptions for at least three different medications.

SELECT p.patient_id, p.name, COUNT(DISTINCT pre.medication) AS num_medications
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN prescriptions pre ON pre.appointment_id = a.appointment_id
GROUP BY p.patient_id, p.name
HAVING COUNT(DISTINCT pre.medication) >= 3;

27. For each doctor, list their last 3 appointments (appointment_date and fee).

سثمWITH ranked_appointments AS (
    SELECT 
        a.doctor_id,
        a.appointment_date,
        a.fee,
        ROW_NUMBER() OVER (PARTITION BY a.doctor_id ORDER BY a.appointment_date DESC) AS rn
    FROM appointments a
)
SELECT doctor_id, appointment_date, fee
FROM ranked_appointments
WHERE rn <= 3;


28. Determine the department with the highest total billing amount.

SELECT department_id, SUM(fee) AS total_billing
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY department_id
ORDER BY total_billing DESC
LIMIT 1;


29. Calculate a 7-day moving average of appointment fees for each doctor and show doctor_id, appointment_date, 
and the moving average.

SELECT 
    d.doctor_id,
    a.appointment_date,
    AVG(a.fee) OVER (
        PARTITION BY d.doctor_id
        ORDER BY a.appointment_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg
FROM doctors d
JOIN appointments a
  ON d.doctor_id = a.doctor_id;


30. Identify patients whose average treatment cost is higher than the overall average treatment cost across 
all treatments.

WITH overall_avg_treatment AS (
    SELECT AVG(t.cost) as overall_avg
    FROM treatments t
)
SELECT 
    p.patient_id,
    AVG(t.cost) AS patient_avg_cost
FROM patients p 
JOIN appointments a
on p.patient_id = a.patient_id
JOIN treatments t
on t.appointment_id = a.appointment_id
JOIN overall_avg_treatment o
GROUP BY p.patient_id
HAVING AVG(t.cost) > o.overall_avg;

					   

