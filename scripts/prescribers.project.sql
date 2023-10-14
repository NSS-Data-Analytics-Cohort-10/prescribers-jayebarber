-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_drugs
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY npi
ORDER By total_drugs DESC
LIMIT 1;

-- ANSWER: Prescriber ID 1881634483/ CLAIM COUNT: 99707


    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY sum_total_claim_count DESC;

-- ANSWER: BRUCE PENDLEY/ TOTAL CLAIM COUNT 99707



-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, sum(TOTAL_CLAIM_COUNT) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
USING(NPI)
GROUP BY specialty_description
order by claim_count_sum DESC; 
-- ANSWER: Family Practice , 9752347


--     b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS sum_of_claim_count
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;
--- ANSWER: NURSE PRACTITONER/ CLAIM COUNT: 900845


--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost) AS total_cost
FROM drug
FULL JOIN prescription
USING (drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

-- ANSWER: INSULIN GLARGINE, HUM.REC.ANLOG


--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name,
ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS daily_cost
FROM prescription
LEFT JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY daily_cost DESC;

---ANSWER: C1 ESTERASE INHIBITOR


-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT drug_name, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug;


-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT DISTINCT(cbsaname)
FROM CBSA
WHERE cbsaname LIKE '%TN%';
 
 
-- ANSWER: 10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT c.cbsaname, SUM(p.population) 
FROM CBSA AS c
INNER JOIN population AS p
ON c.fipscounty = p.fipscounty
GROUP BY cbsaname, population
ORDER BY p.population DESC;

-- ANSWER: Largest Pop: Memphis, TN-MS-AR
Smallest Pop: 

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT f.county, p.population
FROM fips_county AS F
INNER JOIN population AS P
ON f.fipscounty = p.fipscounty
WHERE f.county NOT IN 



-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT p2.drug_name, p2.total_claim_count AS total_claims
FROM prescription AS p2
WHERE p2.total_claim_count >= 3000;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, 
CASE WHEN opioid_drug_flag = 'Y' then 'opioid'
	ELSE 'not an opioid' end as drug_type,
	sum(total_claim_count) as total_claim_count
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY drug_name, drug_type
ORDER BY SUM(total_claim_count) DESC;



--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name, 
CASE WHEN opioid_drug_flag = 'Y' then 'opioid'
	ELSE 'not an opioid' end as drug_type,
	sum(total_claim_count) as total_claim_count,
	nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription
INNER JOIN drug
USING (drug_name)
INNER JOIN prescriber
USING (NPI)
WHERE total_claim_count >= 3000
GROUP BY drug_name, drug_type, nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY SUM(total_claim_count) DESC;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT
	npi,
	drug_name
FROM prescriber 
CROSS JOIN drug
where specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'
group by npi, drug_name;

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p1.npi,
		d.drug_name,
		sum(total_claim_count) AS total_claim_count
	FROM prescriber as p1
	CROSS JOIN drug as d
	FULL JOIN prescription as p2
	USING (drug_name)
	WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	and opioid_drug_flag = 'Y'
	group by p1.npi,
		d.drug_name;


    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT p1.npi,
	d.drug_name,
	COALESCE (sum(total_claim_count),0)
	as total_claim_count
FROM prescriber as p1
CROSS JOIN drug as d
full join prescription as p2
USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
group by p1.npi,
d.drug_name;