#/usr/bin/env python
# coding: utf-8

# In[3]:


import OCR
import plate_detect
import cv2
from flask import Flask, request, jsonify
import json
#import mysql.connector
import base64
from datetime import datetime, timedelta
import sqlite3
import re
#from config import passw       #uncomment this file if you have config file and are using mysql as database
# In[4]:


#extracting image back from base64 enocded String
def convert_and_save(b64_string):
    with open("detect.jpg", "wb") as fh:
        fh.write(base64.decodebytes(b64_string.encode()))


app = Flask(__name__)

@app.route('/', methods = ['POST','GET'])
def index():
    try:
#        print(request)

		#Extracting data from Rest Api
        data = dict(request.form)
        time = data['time']
        img = data['file_data']

		#Coverting base64 String to image
        convert_and_save(img)
#        print(time)

        #Getting image 
        img_path=r"./detect.jpg"
        img = cv2.imread(img_path)  #cv2.imread(file)
   
		#current time when request came and calculating the end time
        start_time = datetime.now()
        end_time = start_time+ timedelta(hours= int(time))

		#extracting Number from the image
        x = plate_detect.main(img)
  
		#Creating table in the table
        tableCreate()
		
		#Writing data into database plate number, start time, end time 
        dataEntry(x, start_time, end_time)
		
		#fetching receipt number from database
        fetch = extract(x)
        fetch = re.sub("[^0-9a-zA-Z]+",'',str(fetch))


        s = {'Receipt No.' : str(fetch),
             'Reg No.': x,
             'Start Time': start_time.strftime("%Y/%m/%d, %H:%M"),
             'End Time': end_time.strftime("%Y/%m/%d, %H:%M")
            }

        return s

    except Exception as e:
        print('Error: ',e)


#table creation having fields sno., numberPlate, start and end time
def tableCreate():

#    mydb = mysql.connector.connect(
#            host = "localhost",
#            user = "root",
#            password = "passw",
#            database = "mydatabase"
#            )
#    mycursor = mydb.cursor()

    con = sqlite3.connect('mydatabase.db')

    mycursor = con.cursor()

    try:
        mycursor.execute("""
        CREATE TABLE IF NOT EXISTS number(
        SNO INTEGER PRIMARY KEY AUTOINCREMENT,
        NUMBER TEXT NOT NULL,
        START DATETIME NOT NULL,
        END DATETIME NOT NULL
        );
        """)

        con.close()

    except mysql.connector.Error as e:
        print(e)
        con.close()
        pass

#Inserting data into database
def dataEntry(x, s, e):

#    mydb = mysql.connector.connect(
#            host = "127.0.0.1",
#            user = "root",
#            password = passw,
#            database = "mydatabase"
#            )

#    mycursor = mydb.cursor()

   # data = """
   # INSERT INTO number(NUMBER, START, END)
   # VALUES (\'%s, %s, %s\') """, (%a, %s.strftime("%Y-%m-%d %H:%M:%S"), %e.strftime("%Y-%m-%d %H:%M:%S"))
    

    con= sqlite3.connect('mydatabase.db')

    mycursor = con.cursor()


    mycursor.execute("INSERT INTO number(NUMBER, START, END) VALUES (?, ?, ?)", (x, s.strftime("%Y-%m-%d %H:%M:%S"), e.strftime("%Y-%m-%d %H:%M:%S")))

    con.commit()

    con.close()


#Getting Reciept no. out of the database
def extract(a):

#    mydb = mysql.connector.connect(
#            host = "127.0.0.1",
#            user = "root",
#            password = passw,
#            database = "mydatabase"
#            )

#    mycursor = mydb.cursor()
    


    con = sqlite3.connect('mydatabase.db')
    
#    print('data')
    data = """SELECT SNO FROM number
    WHERE NUMBER like :a """
    
    
    mycursor = con.cursor()

    mycursor.execute(data, {'a':a})
   
    get = mycursor.fetchall()

    con.close()
#    return mycursor.fetchone()[0]
    return get[-1]
#    print(data[0])

#    return data[0]   
    
if __name__ == '__main__':
   app.run(host='0.0.0.0', port=8080) 

# In[ ]:




