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


-- Check For Invalid Dates

SELECT 
NULLIF(sls_order_dt,0), sls_order_dt -- For 0 Values Replacing With NULL Value
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) !=8
OR sls_order_dt < 19000101
OR sls_order_dt > 20500101;

SELECT 
NULLIF(sls_ship_dt,0), sls_ship_dt -- For 0 Values Replacing With NULL Value
FROM bronze.crm_sales_details
WHERE sls_ship_dt <=0 
OR LEN(sls_ship_dt) !=8
OR sls_ship_dt < 19000101
OR sls_ship_dt > 20500101;

SELECT 
NULLIF(sls_due_dt,0), sls_due_dt -- For 0 Values Replacing With NULL Value
FROM bronze.crm_sales_details
WHERE sls_due_dt <=0 
OR LEN(sls_due_dt) !=8
OR sls_due_dt < 19000101
OR sls_due_dt > 20500101;


SELECT
sls_sales
FROM bronze.crm_sales_details
WHERE sls_sales = 0 OR sls_sales IS NULL; -- foinding o and NULL values

SELECT
sls_sales,count(*)
FROM bronze.crm_sales_details
GROUP BY sls_sales
HAVING count(*) < 0; -- finiding negative values

SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt; -- Checking that order date is smaller than the due date and ship date.

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_quantity IS NULL OR sls_price IS NULL OR sls_sales IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price;


SELECT 
*
FROM silver.crm_sales_details;


-- Check For Unwanted Spaces
-- Expectation : No Results

SELECT
prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

SELECT
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check For Null and Negative Numbers
-- Expectation : No Results

SELECT
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL ;

SELECT 
*
FROM silver.crm_prd_info;


----- erp file test

SELECT 
*
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

SELECT 
*
FROM silver.crm_cust_info;


SELECT 
cid AS old_cid,
CASE
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE  cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm );

SELECT 
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

SELECT DISTINCT
gen,
CASE
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'N/A'
END AS gen
FROM bronze.erp_cust_az12;

SELECT
*
FROM silver.erp_cust_az12;


-------------------------------
SELECT 
REPLACE(cid,'-','') AS cid

FROM bronze.erp_loc_a101;

SELECT DISTINCT

CASE
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'N/A'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101 
ORDER BY cntry;

------------------------------------------------

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;
-- Check Unwanted Spaces
SELECT
*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency

SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2;


SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2;


SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT 
*
FROM silver.erp_px_cat_g1v2;