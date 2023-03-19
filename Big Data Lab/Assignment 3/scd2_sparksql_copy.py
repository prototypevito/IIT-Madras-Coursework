from pyspark.sql.functions import col, when, lit
from pyspark.sql import SparkSession
import pandas as pd
import numpy as np
# Given a dataframe of customer records, where
# validity_start is set to a date from a long time ago - e.g. 01-01-1970
# while validity_end will be set to a long time in the future
# such that there is only 1 record per customer that is valid as on date
customer_master=[[1,'Harsha','20-08-1990','01-01-1970','12-12-9999'],[2,'Goldie','11-02-1990','01-01-1970','12-12-9999'],[3,'Divya','25-12-1990','01-01-1970','12-12-9999']]
cm_df=pd.DataFrame(customer_master,columns=['id','name','dob','validity_start','validity_end'])

# ... and given some updates to some of the records
# as of now
updates=[['Harsha','05-09-1990']]
updates_df=pd.DataFrame(updates,columns=['name','updated_dob'])
now='12-03-2023'

# Create SparkSession
spark = SparkSession.builder.appName('SCD Type II').getOrCreate()

# Convert the pandas data frame to PySpark data frame
customer_master = spark.createDataFrame(cm_df)
updates_df = spark.createDataFrame(updates_df)
customer_master.createOrReplaceTempView("customer_master")
updates_df.createOrReplaceTempView("updates_df")

#Make the dataframe with the newly updated data
fullrowupdates_df = spark.sql("""
    SELECT cm.name, cm.id,
        CASE WHEN ud.updated_dob IS NULL THEN cm.dob ELSE ud.updated_dob END AS dob,
        CASE WHEN ud.updated_dob IS NULL THEN cm.validity_start ELSE '{0}' END AS validity_start,
        cm.validity_end AS validity_end
    FROM customer_master cm
    LEFT JOIN updates_df ud ON cm.name = ud.name
""".format('12-03-2023'))

# Update the validity_end of previous records
closeprev_df = spark.sql("""
    SELECT cm.name, cm.id, cm.dob, cm.validity_start,
        CASE WHEN ud.updated_dob IS NULL THEN '12-12-9999' ELSE '{0}' END AS validity_end
    FROM customer_master cm
    LEFT JOIN updates_df ud ON cm.name = ud.name
""".format('12-03-2023'))

#Create the final dataframe using SQL to merge historical data with the new data
fullrowupdates_df.createOrReplaceTempView("fullrowupdates")
closeprev_df.createOrReplaceTempView("closeprev")
final_df = spark.sql("""
    SELECT DISTINCT *
    FROM (
        SELECT * FROM fullrowupdates
        UNION ALL
        SELECT * FROM closeprev
    ) temp
    ORDER BY validity_end, validity_start, id
""")

final_df.show()