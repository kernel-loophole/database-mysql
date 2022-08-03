import mysql.connector
import pandas as pd
import smtplib,ssl
config = {
  'user': 'root',
  'password':'',
  'host': '127.0.0.1',
  'port':'3308',
  'database': 'task_inter',
  'raise_on_warnings': True
}

query = ("select sub,channel ,ondate,count(*)  as total from Data group by weekofyear(ondate),dayofyear(ondate) ;")
cnx = mysql.connector.connect(**config)
cursor = cnx.cursor()
cursor.execute(query)
df=pd.DataFrame(columns=['sub','channels','counts','ondate'])
counter=0
for (sub,channel,ondate,count) in cursor:
    # print(sub,channel,ondate)
    df.loc[counter]=[sub,channel,count,ondate]
    counter+=1
print(df)
cnx.close()
print("setup complete")
################################Email configuration################
