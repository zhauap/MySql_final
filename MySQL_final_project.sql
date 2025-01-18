#1a) список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период
SELECT *
FROM customer_info 
WHERE Tenure = 12;

#1b) средний чек за период с 01.06.2015 по 01.06.2016
SELECT Id_client, AVG(Sum_payment) as `Средний чек`
FROM transaction_info 
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY Id_client;

#1c) средняя сумма покупок за месяц
SELECT Id_client, 
	AVG(Sum_payment) as `Средний чек`, 
    MONTH(date_new) AS `Месяц`
FROM transaction_info 
GROUP BY Id_client, MONTH(date_new)
ORDER BY Id_client, MONTH(date_new);

#1d) количество всех операций по клиенту за период;
SELECT Id_client, 
	COUNT(Sum_payment)
FROM transaction_info 
GROUP BY Id_client
ORDER BY Id_client;

/*2.	информацию в разрезе месяцев:
a)	средняя сумма чека в месяц;
b)	среднее количество операций в месяц;
c)	среднее количество клиентов, которые совершали операции;
d)	долю от общего количества операций за год и долю в месяц от общей суммы операций;*/
SELECT  
	   MONTH(date_new) as 'Месяц покупки', 
       ROUND(AVG(Sum_payment), 2) as 'Средний чек за месяц', 
       COUNT(*) as 'Количество покупок', 
       COUNT(DISTINCT Id_client) AS 'Количество клиентов',
       ROUND(
		   (COUNT(*) / (SELECT COUNT(*) FROM transaction_info
						WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'))*100, 2
			) AS 'Доля от общего количества операций за год, %',
        ROUND(    
			(SUM(Sum_payment) / (SELECT SUM(Sum_payment) FROM transaction_info
								WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'))*100, 2
			 ) AS 'Доля в месяц от общей суммы операций, %'
FROM transaction_info t
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY  MONTH(date_new);

#2e)	вывести % соотношение M/F/NA в каждом месяце с их долей затрат;
SELECT MONTH(t.date_new) as 'Месяц покупки',
		c.Gender as 'Пол', 
        COUNT(c.Gender) AS 'Количество людей',
        ROUND(
				(COUNT(*) / (SELECT COUNT(*) 
							FROM transaction_info ti
							WHERE MONTH(ti.date_new) = MONTH(t.date_new) 
							)
				)*100, 2
                )  as 'Соотношение M/F/NA в каждом месяце, %',
		ROUND(SUM(t.Sum_payment),2) as 'Затраты',
        ROUND(
				(
					SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) 
									from transaction_info ti
									WHERE MONTH(ti.date_new) = MONTH(t.date_new) 
									)
				)*100, 2
			) AS 'Доля затрат, %'
			
FROM customer_info c
JOIN transaction_info t ON t.Id_client = c.Id_client
GROUP BY c.Gender, MONTH(t.date_new)
ORDER BY MONTH(t.date_new)


#3.	возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество операций за весь период, и поквартально - средние показатели и %.
SELECT 
CASE 
    WHEN Age BETWEEN 1 AND 11 THEN '1-11'
    WHEN Age BETWEEN 11 AND 21 THEN '11-21'
    WHEN Age BETWEEN 21 AND 31 THEN '21-31'
    WHEN Age BETWEEN 31 AND 41 THEN '31-41'
    WHEN Age BETWEEN 41 AND 51 THEN '41-51'
    WHEN Age BETWEEN 51 AND 61 THEN '51-61'
    WHEN Age BETWEEN 61 AND 71 THEN '61-71'
    WHEN Age BETWEEN 71 AND 81 THEN '71-81'
    WHEN Age BETWEEN 81 AND 91 THEN '81-91'
    ELSE 'Возраст неизвестен'
END AS `Возрастные группы`,
ROUND(SUM(t.Sum_payment)) AS 'Сумма операций', 
COUNT(t.Sum_payment) AS 'Количество операций'
FROM customer_info c
JOIN transaction_info t
	ON c.Id_client = t.Id_client
GROUP BY `Возрастные группы`
ORDER BY `Возрастные группы`;


SELECT 
QUARTER(t.date_new) AS 'Квартал',
CASE 
    WHEN Age BETWEEN 0 AND 10 THEN '0-10'
    WHEN Age BETWEEN 11 AND 20 THEN '11-20'
    WHEN Age BETWEEN 21 AND 30 THEN '21-30'
    WHEN Age BETWEEN 31 AND 40 THEN '31-40'
    WHEN Age BETWEEN 41 AND 50 THEN '41-50'
    WHEN Age BETWEEN 51 AND 60 THEN '51-60'
    WHEN Age BETWEEN 61 AND 70 THEN '61-70'
    WHEN Age BETWEEN 71 AND 80 THEN '71-80'
    WHEN Age BETWEEN 81 AND 90 THEN '81-90'
    ELSE 'Возраст неизвестен'
END AS `Возрастные группы`,
COUNT(*) AS 'Количество людей',
ROUND(SUM(t.Sum_payment), 2)AS 'Сумма затрат',
ROUND(AVG(t.Sum_payment), 2) AS `Средние показатели`,
ROUND((SUM(t.Sum_payment) / (SELECT SUM(ti.Sum_payment) from transaction_info ti
							WHERE QUARTER(t.date_new) = QUARTER(ti.date_new) 
							) 
	) * 100, 2) as 'Доля за кватал, %'
FROM customer_info c
JOIN transaction_info t
	ON c.Id_client = t.Id_client
GROUP BY `Квартал`, `Возрастные группы`
ORDER BY `Квартал`, `Возрастные группы`;

