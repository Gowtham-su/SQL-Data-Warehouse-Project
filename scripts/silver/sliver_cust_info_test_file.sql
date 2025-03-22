/* -- Check For Nulls or Duplicates in Primary Key
   -- Expectation : No Result
*/

SELECT 
cst_id, COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check Unwanted Spaces
-- Expectation: No Results

SELECT 
cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT 
cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT
cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT
DISTINCT cst_gndr
FROM bronze.crm_cust_info;


SELECT
*
FROM(

SELECT
*,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_latest
FROM bronze.crm_cust_info
) as tab WHERE flag_latest =1 AND cst_id IS NOT NULL;

SELECT 
cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

SELECT 
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT
*
FROM silver.crm_cust_info;
