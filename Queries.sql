--What is the percentage of female employees compared to male employees in the company overall?
SELECT Gender,
	FORMAT(CAST(COUNT(No) AS FLOAT) / (SELECT COUNT(No) FROM Employees), 'P2') AS 'Gender Percentage'
FROM Employees
GROUP BY Gender;

--What is the gender distribution in each country, 
SELECT Country,
	Gender,
	FORMAT(CAST(COUNT(No) AS FLOAT) / SUM(COUNT(No)) OVER(PARTITION BY Country), 'P2') AS 'Gender'
FROM Employees
GROUP BY Country ,Gender;

--and which countries have more female employees than male employees?
SELECT *
FROM(
SELECT Country,
CASE
	WHEN [Gender Percentage] > LEAD([Gender Percentage]) OVER(PARTITION BY Country ORDER BY Gender)  THEN 'Female Country'
	ELSE 'Male Country'
END AS Type,
ROUND(CAST(REPLACE(LEAD([Gender Percentage]) OVER(PARTITION BY Country ORDER BY Gender) , '%' ,'') AS FLOAT)-
CAST(REPLACE([Gender Percentage] , '%' , '') AS FLOAT) , 2) AS 'Difference'
FROM(
	SELECT Country,
		Gender,
		FORMAT(CAST(COUNT(No) AS FLOAT) / SUM(COUNT(No)) OVER(PARTITION BY Country), 'P2') AS 'Gender Percentage'
	FROM Employees
	GROUP BY Country ,Gender) AS Gen_Dist) AS Dift
WHERE Difference IS NOT NULL;

--What is the impact of gender on monthly salary?
SELECT Gender,
	ROUND(AVG([Monthly Salary]) , 2)AS 'Salary Average'
FROM Employees
GROUP BY Gender;

--Which departments attract more female employees?
--and Which departments attract more male employees?
SELECT DISTINCT Department,
CASE
	WHEN Percentage > LEAD(Percentage , 1) OVER(PARTITION BY Department 
	ORDER BY CASE WHEN Gender = 'Female' THEN 1 ELSE 2 END) 
	THEN 'Female Department'
	ELSE 'Male Department'
END AS 'Departmet Type'
FROM(
	SELECT Gender,
		Department,
		FORMAT(CAST(COUNT(No) AS FLOAT) /SUM(COUNT(No)) OVER(PARTITION BY Department) , 'P2') AS 'Percentage'
	FROM Employees
	GROUP BY Gender , Department) AS Percentage

--What is the average salary for each department?
SELECT Department,
	ROUND(AVG([Monthly Salary]) , 2) AS 'Salary Average'
FROM Employees
GROUP BY Department
ORDER BY [Salary Average] DESC;

--What is the average salary in each country?
SELECT Country,
	ROUND(AVG([Monthly Salary]),2) AS 'Salary Average'
FROM Employees
GROUP BY Country
ORDER BY [Salary Average] DESC;

--In which country does each department have the highest average salary?
SELECT Country,
	Department,
	[Salary Average]
FROM(
SELECT Country ,
	Department,
	ROUND(AVG([Monthly Salary]) , 2) AS 'Salary Average',
	RANK() OVER(PARTITION BY Department ORDER BY ROUND(AVG([Monthly Salary]) , 2) DESC) AS Number
FROM Employees
GROUP BY Country , Department) AS RANKED
WHERE Number = 1;

-- What is the percentage of employees in each department over the years?
SELECT Department , 
	YEAR([Start Date]) AS YEAR,
	FORMAT(CAST(COUNT(No) AS FLOAT) / SUM(COUNT(No)) OVER(PARTITION BY Department) , 'P2') AS 'Percentage'
FROM Employees
GROUP BY Department , YEAR([Start Date]);

-- What is the hiring percentage in each country over the years?
SELECT Country,
	YEAR([Start Date]) AS Year,
		FORMAT(CAST(COUNT(No) AS FLOAT) / SUM(COUNT(No)) OVER(PARTITION BY Country) , 'P2') AS 'Percentage'
FROM Employees 
GROUP BY Country , YEAR([Start Date]);

-- What is the hiring percentage of males and females over the years?
SELECT Gender , 
	YEAR([Start Date]) AS YEAR,
	FORMAT(CAST(COUNT(No) AS FLOAT) / SUM(COUNT(No)) OVER(PARTITION BY Gender), 'P2') AS 'Percentage'
FROM Employees
GROUP BY YEAR([Start Date]) , Gender;

-- What is the average years of experience for employees in each country?
SELECT Country,
	ROUND(AVG(Years) , 2) AS 'Experienced Years'
FROM Employees
GROUP BY Country
ORDER BY [Experienced Years] DESC;
