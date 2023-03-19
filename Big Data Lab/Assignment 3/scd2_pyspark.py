import pandas as pd
import numpy as np
import pyspark
import sys
from pyspark.sql.functions import col
from pyspark.sql.functions import asc
from pyspark.sql.functions import current_date, lit, when
from pyspark.sql import SparkSession
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


#pySpark Code
spark = SparkSession.builder.appName('SCD Type II').getOrCreate()

# Convert the pandas data frame to PySpark data frame
customer_master = spark.createDataFrame(cm_df)

# Create a new data frame with updated records
updates_df = spark.createDataFrame(updates, ['name', 'updated_dob'])
fullrowupdates_df = customer_master.join(updates_df, on='name', how='left')
fullrowupdates_df = fullrowupdates_df \
    .withColumn('dob', when(fullrowupdates_df.updated_dob.isNull(), fullrowupdates_df.dob)
                .otherwise(fullrowupdates_df.updated_dob)) \
    .withColumn('validity_start',when(fullrowupdates_df.updated_dob.isNull(), fullrowupdates_df.validity_start)
                .otherwise(lit(now))) \
    .drop('updated_dob')
# Update the validity_end of previous records
closeprev_df = customer_master.join(updates_df, on='name', how='left')
closeprev_df = closeprev_df \
    .withColumn('validity_end', when(closeprev_df.updated_dob.isNull(), lit('12-12-9999'))
                .otherwise(lit(now))) \
    .drop('updated_dob')

# Create the final data frame by combining old and new records
fullrowupdates_df = fullrowupdates_df.select('id', 'name', 'dob', 'validity_start', 'validity_end')
closeprev_df = closeprev_df.select('id', 'name', 'dob', 'validity_start', 'validity_end')

closeprev_df = closeprev_df \
    .withColumnRenamed('validity_end', 'validity_end_prev') \
    .withColumnRenamed('validity_start', 'validity_start_prev')
fullrowupdates_df = fullrowupdates_df \
    .withColumnRenamed('validity_end', 'validity_end_new') \
    .withColumnRenamed('validity_start', 'validity_start_new')



# Select the columns needed from both dataframes and rename the columns as needed
fullrowupdates_df = fullrowupdates_df.select(
    col('name'),
    col('id'),
    col('dob'),
    col('validity_start_new').alias('validity_start'),
    col('validity_end_new').alias('validity_end')
)

closeprev_df = closeprev_df.select(
    col('name'),
    col('id'),
    col('dob'),
    col('validity_start_prev').alias('validity_start'),
    col('validity_end_prev').alias('validity_end')
)

# Union the dataframes
final_df = fullrowupdates_df.union(closeprev_df).dropDuplicates()

# Order the final dataframe by id
final_df = final_df.orderBy(asc("validity_end"),asc("validity_start"),asc("id"))
final_df.show()


