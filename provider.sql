// STEP 1 - CREATE DATAABSE OBJECTS AND LOAD PATIENT DATA
use role accountadmin; 

--or use a role with the following grants: 
    --CREATE DATABASE 
    --CREATE APPLICATION PACKAGE
    --CREATE APPLICATION
    --CREATE DATA EXCHANGE LISTING 
    --CREATE INTEGRATION
    --IMPORT SHARE 
    --CREATE ROLE 
    --CREATE SHARE 

--create warehouse or use existing    
create warehouse cortex_analyst_wh with warehouse_size='SMALL';
use warehouse cortex_analyst_wh;

-- create database and schema or use existing
create database CORTEX_ANALYST_DEMO;
create schema CORTEX_ANALYST_DEMO.MEDICAL;
use schema CORTEX_ANALYST_DEMO.MEDICAL;

-- create file format
create or replace file format medical.csv_ff
	TYPE = CSV
	COMPRESSION = AUTO 
	FIELD_DELIMITER = '|'
	SKIP_HEADER = 0
	FIELD_OPTIONALLY_ENCLOSED_BY = '"'
	EMPTY_FIELD_AS_NULL = TRUE;

-- create stage
CREATE OR REPLACE STAGE medical.setup_stage
  FILE_FORMAT = medical.csv_ff
  DIRECTORY = ( ENABLE = TRUE )
;

-- IMPORTANTdownload data.csv.gz file from the git repository and upload it the medical.setup_stage
-- This can be done via SnowSQL, SnowCLI, Python, VS Code or the File Upload Wizard in your Snowsight UI. 
-- To use the File Upload UI, hover over the Data Icon in Snowsight > Add Data > Load Files into a Stage.

-- verify patient file is in stage
list @medical.setup_stage;

-- create patient metrics table
create or replace TABLE CORTEX_ANALYST_DEMO.MEDICAL.PATIENT_METRICS (
	SNOWFLAKE_REALID VARCHAR(16777216),
	SOURCE_MEMBER_ID NUMBER(20,0),
	FIRST_NAME VARCHAR(16777216),
	LAST_NAME VARCHAR(16777216),
	PHONE_NUMBER VARCHAR(16777216),
	ZIPCODE NUMBER(5,0),
	PRIMARYADDRESS VARCHAR(16777216),
	LONGITUDE FLOAT,
	LATITUDE FLOAT,
	POINT GEOGRAPHY,
	POSTCODE VARCHAR(50),
	AGE NUMBER(5,0),
	REGULARLYVISITSDOCTOR NUMBER(38,0),
	FREQUENTVOTER NUMBER(38,0),
	GENDER VARCHAR(300),
	RACE VARCHAR(300),
	EDUCATION NUMBER(5,0),
	VEHICLE NUMBER(5,0),
	MARITALSTATUS VARCHAR(300),
	GENERATIONSINHOUSEHOLD NUMBER(5,0),
	HOUSEHOLDSIZE NUMBER(5,0),
	NUMBEROFADULTS NUMBER(5,0),
	NUMBEROFCHILDREN NUMBER(5,0),
	PRESENCEOFCHILDREN VARCHAR(1),
	HOUSEHOLD_EDUCATION_ZIP NUMBER(5,0),
	INTEREST_HOMEOPATHIC NUMBER(5,0),
	INTEREST_ARTHRITISMOBILITY NUMBER(5,0),
	INTEREST_DIABETIC NUMBER(5,0),
	INTEREST_ORGANICFOCUS NUMBER(5,0),
	INTEREST_ORTHOPEDIC NUMBER(5,0),
	INTEREST_HEALTHANDMEDICAL NUMBER(5,0),
	SINGLEPARENT NUMBER(5,0),
	INTEREST_CHARITIES NUMBER(5,0),
	INTEREST_EXERCISEHEALTH NUMBER(5,0),
	DISTRESSED_POVERTY NUMBER(5,0),
	DISTRESSED_UNEMPLOYMENT NUMBER(5,0),
	DISTRESSED_POPULATION NUMBER(5,0),
	REMOTERURALUNDERSERVED NUMBER(5,0),
	PLACE_INCOMECLASSIFICATIONCODE NUMBER(38,0),
	PLACE_COSTOFLIVING_COMPOSITEINDEX NUMBER(38,0),
	PLACE_COSTOFLIVING_GROCERYINDEX NUMBER(38,0),
	PLACE_COSTOFLIVING_HEALTHCAREINDEX NUMBER(38,0),
	PLACE_COSTOFLIVING_HOUSINGINDEX NUMBER(38,0),
	PLACE_COSTOFLIVING_TRANSPORTATIONINDEX NUMBER(38,0),
	PLACE_COSTOFLIVING_UTILITYINDEX NUMBER(38,0),
	PLACE_ETHNICITY_MODE VARCHAR(1),
	RACE_DESC VARCHAR(60),
	RESIDENCY_OWNERRENTERINFERRED VARCHAR(1),
	RESIDENCY_LENGTHOFRESIDENCE NUMBER(5,0),
	LANGUAGE_INFERRED VARCHAR(60),
	OCCUPATION VARCHAR(60),
	DIAG_LANGUAGE VARCHAR(7),
	DIAG_ID NUMBER(2,0),
	DIAG_DESCRIPTION VARCHAR(16777216),
	CLINICAL_NOTES VARCHAR(16777216),
	LAST_APPT_DATE DATE
);

show tables in schema;

-- copy data into table & query it
copy into CORTEX_ANALYST_DEMO.MEDICAL.PATIENT_METRICS from @medical.setup_stage/;
select * from CORTEX_ANALYST_DEMO.MEDICAL.PATIENT_METRICS limit 10;



//*------------------------------------------------------------------------------------------------------------*\\
// STEP 2 - SETUP YOUR PROVIDER NATIVE APP PACKAGE

-- Step 2 - Create the application package and its associated schemas and stage

create application package clinical_cortex_analyst_app_pkg;

create schema clinical_cortex_analyst_app_pkg.stages;
create stage clinical_cortex_analyst_app_pkg.stages.app_code_stage; 
create schema clinical_cortex_analyst_app_pkg.shared_content;

--Step 3 - create "proxy view" in the Native App Package
create view clinical_cortex_analyst_app_pkg.shared_content.patient_metrics as 
    select *
    from cortex_analyst_demo.medical.patient_metrics;

--Step 4 - grants for this proxy view
grant usage on schema clinical_cortex_analyst_app_pkg.shared_content to share in application package clinical_cortex_analyst_app_pkg;
grant reference_usage on database cortex_analyst_demo to share in application package clinical_cortex_analyst_app_pkg;
grant select on view clinical_cortex_analyst_app_pkg.shared_content.patient_metrics to share in application package clinical_cortex_analyst_app_pkg;

--test the proxy view to ensure all OK
select * from clinical_cortex_analyst_app_pkg.shared_content.patient_metrics limit 10;

-- Step 5 - Load the files listed above from your desktop to the Native Application Snowflake Stage as described in the blog

-- Upload code assets to stage via SnowSQL, SnowCLI, Python, using the VS Code, or the File Upload Wizard in your Snowsight UI 
-- - manifest.yml 
-- - environment.yml 
-- - setup.sql 
-- - ux_main.py 
-- - readme.md


ls @clinical_cortex_analyst_app_pkg.stages.app_code_stage;

-- Step 6 - Create a version, release directive, and "local" test instance of the Native Application.
alter application package clinical_cortex_analyst_app_pkg
    ADD VERSION v01
    USING '@clinical_cortex_analyst_app_pkg.stages.app_code_stage';

alter application package clinical_cortex_analyst_app_pkg 
    set default release directive version=v01 patch=0;

--test locally in provider account
create application clinical_cortex_analyst_app from APPLICATION PACKAGE clinical_cortex_analyst_app_pkg;



//*------------------------------------------------------------------------------------------------------------*\\
// STEP 3 - Create a Semantic Model .yaml file using our Semantic Model Generator


-- Step 7 - Optional: After setting up the Semantic Model Generator (preferably in Streamlit), input your desired semantic model name, define the maximum number of sample values per column based on your dataset, and select the CLINICAL_CORTEX_ANALYST_APP database, the MEDICAL schema, and the PATIENT_METRICS table (as shown in the image below).
    -- https://developers.snowflake.com/solution/creating-semantic-models-for-snowflakes-cortex-analyst/

    
-- Step 8 - Review the auto-generated patient_semantic_model.yamland upload it either from your desktop or directly from the Semantic Model Generator Streamlit app to the specified Native Application Snowflake Stage (as shown in the image below).
    -- Database & Schema CLINICAL_CORTEX_ANALYST_APP_PKG.STAGES and stage APP_CODE_STAGE.

    
-- Step 9 - delete the current version (v01) of the CLINICAL_CORTEX_ANALYST_APP, and repeat step 6 to recreate it. 
-- NOTE: This will ensure that the newly created CLINICAL_CORTEX_ANALYST_APP now references the .yaml file added to the CLINICAL_CORTEX_ANALYST_APP_PKG in step 8.
drop application if exists clinical_cortex_analyst_app CASCADE;

alter application package clinical_cortex_analyst_app_pkg
    ADD VERSION v02
    USING '@clinical_cortex_analyst_app_pkg.stages.app_code_stage';

alter application package clinical_cortex_analyst_app_pkg 
    set default release directive version=v02 patch=0;

--test locally in provider account
create application clinical_cortex_analyst_app from APPLICATION PACKAGE clinical_cortex_analyst_app_pkg;

-- Step 10 - Call an initialization Stored Procedure which is required to allow the Native App to read the semantic model yaml file.
--call this stored procedure to copy semantic model yml file from "package" stage to "app" stage
--note that by the end of CY24, this call should be able to be moved to the setup script 
call clinical_cortex_analyst_app.src.sp_init();

--go to the UI/UX and try it out

--cleanup if needed
drop application if exists clinical_cortex_analyst_app CASCADE;
drop application package if exists clinical_cortex_analyst_app_pkg;

