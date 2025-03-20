/* 
----------------------------------------------------------------------------------------
Stored Procedure: Load Bronze Layer (Source -> Bronze)
----------------------------------------------------------------------------------------
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from the external CSV files.
it performs the following actions:
-Truncates the bronze tables before loading data.
-uses the 'BULK INSERT' command to load data from the CSV files to bronze tables.

Parameters:
None.
This stored procedure does not accept any parameters or return any values.
----------------------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME ,@batch_start_time DATETIME , @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '*****************************************';
		PRINT 'Loading Bronze Layer';
		PRINT '*****************************************';

		PRINT '-----------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into:bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'datasets/source_CRM/cust_info.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) +' Seconds';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into:bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\DATA_ANALYTICS\WORK_FILES\DATA WITH BARAA\SQL\DataWarehouse\datasets\source_crm\prd_info.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) +' Seconds';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into:bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\DATA_ANALYTICS\WORK_FILES\DATA WITH BARAA\SQL\DataWarehouse\datasets\source_crm\sales_details.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) +' Seconds';
		PRINT '-----------------------------------------';
	
		PRINT '-----------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into:bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\DATA_ANALYTICS\WORK_FILES\DATA WITH BARAA\SQL\DataWarehouse\datasets\source_erp\CUST_AZ12.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) +' Seconds';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into:bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\DATA_ANALYTICS\WORK_FILES\DATA WITH BARAA\SQL\DataWarehouse\datasets\source_erp\LOC_A101.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) +' Seconds';
		PRINT '-----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into:bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\DATA_ANALYTICS\WORK_FILES\DATA WITH BARAA\SQL\DataWarehouse\datasets\source_erp\PX_CAT_G1V2.csv'

		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) +' Seconds';
		PRINT '-----------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '=============================================';
		PRINT '>>Loading Bronze Layer is Completed....';
		PRINT ' -Total Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '=============================================';
	END TRY
	BEGIN CATCH
		PRINT '******************************************';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '******************************************';
	END CATCH;
END;
