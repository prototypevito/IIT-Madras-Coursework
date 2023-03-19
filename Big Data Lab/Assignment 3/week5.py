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

# ... create the updated customer records dataframe such that
# both the previous version and new version of a record are tracked
# using timestamp of update

# We will create the current version of the full customer record
fullrowupdates_df=updates_df.set_index('name').join(cm_df.set_index('name'))
fullrowupdates_df=fullrowupdates_df.drop(columns=['dob'])
fullrowupdates_df.rename(columns={'updated_dob':'dob'},inplace='True')
fullrowupdates_df['validity_start']=[now for i in range(len(fullrowupdates_df.index))]

# Update the previous record to close the validity
closeprev_df=cm_df.set_index('name').join(updates_df.set_index('name'))
closeprev_df['validity_end']=np.where(pd.isna(closeprev_df['updated_dob']),closeprev_df['validity_end'],now)
closeprev_df=closeprev_df.drop(columns=['updated_dob'])

# Set the final customer master as a combination of old and new records
frames = [closeprev_df, fullrowupdates_df]
cm_df= pd.concat(frames)
print(cm_df)


