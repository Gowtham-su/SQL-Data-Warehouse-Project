/*
	**************************************************************************************
	Stored Procedure: Load Silver Layer (Bronze layer --> SIlver Layer)
	**************************************************************************************
	Script Purpose:
		This Stored Procedure Performs ETL(Extract, Transform, Load) process to populate 
		the 'Silver' Schema table From 'Bronze' Schema.
	Actions Performed:
		-Truncate Silver tables.
		-Inserts Transformed and Cleansed Data from Bronze into Silver tables.

	Parameters:
		None.
		This stored procedure does not accept any parameter or return any values.

	Usage Example:
		EXEC silver.load_silver

	**************************************************************************************
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '***********************************************************';
		PRINT 'Loading Silver Layer';
		PRINT '***********************************************************';

		PRINT '***********************************************************';
		PRINT 'Loading CRM Tables';
		PRINT '***********************************************************';

		-- Loading silver.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT 'Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname ,
		TRIM(cst_lastname) as cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			ELSE 'N/A'
		END cst_material_status, -- Normalize martial status into readable format
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
			ELSE 'N/A'
		END cst_gndr, -- Normalize gender status into readable format
		cst_create_date
		FROM (

		SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_latest
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL) as tab 
		WHERE flag_latest =1; -- Select the most recent record per customer
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

		-- Loading silver.crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT 'Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- Extract Category ID
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,	   -- Extract Product Key
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'N/A'
			END	prd_line,				-- Map Product line codes to descriptive values
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt -- Calculate end date as one day before the next start date
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- Loading silver.crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT 'Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,

			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE

				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,

			CASE
				WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales   -- Recalculate sales if original valur is missing or Incorrect or in negative
			END sls_sales,
			sls_quantity,
			CASE
			WHEN sls_price IS NULL OR sls_price <=0
			THEN sls_sales / NULLIF(sls_quantity,0)
			ELSE sls_price  -- Recalculate Price if Original valuee is invalid
		END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-----------------';

		---------------------------------------------------------------- ERP Layer Starts -------------------------------------------------------------
		-- Loading silver.erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT 'Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12
		(
			cid,
			bdate,
			gen
		)
		SELECT 
		CASE
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END AS cid,
		CASE
			WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,

		CASE
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'N/A'
		END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------';

		-- Loading silver.erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT 'Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101
		(
			cid,
			cntry
		)
		SELECT 
		-- Data Standardization  & Consistency
		REPLACE(cid,'-','') AS cid,
		CASE
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'N/A'
			ELSE TRIM(cntry)
		END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT'>> Loading Duration' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT'-------------------';

		-- Loading silver.erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT 'Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
		(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @batch_end_time = GETDATE();
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>------------------';

		SET @batch_end_time = GETDATE();
		PRINT '***************************************************************';
		PRINT 'Loading Silver layer is complete';
		PRINT '- Total Batch Loading Duration:' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '***************************************************************';
	END TRY

	BEGIN CATCH
		PRINT '----------------------------------------------';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '----------------------------------------------';
	END CATCH
END