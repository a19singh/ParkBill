#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Extract json file and store data in a list
def extract_json(path):
    data = list()
    with open(path,'r') as f:
        while True:
            x = f.readline()
            if not x:
                break
            data.append(x[:-1])
    return data


# In[ ]:





# In[2]:


# calculating cordinates of bounding boxes 
def dim(r):
    a = r[0]
    b = r[1]
    
    #returning a list that contains the dimmension of the bounding box
    return [round(a['x']+b['x'],4)/2.0,round(a['y']+b['y'],4)/2.0,round(abs(b['x']-a['x']),4),round(abs(b['y']-a['y']),4)]


# In[3]:


# main method for saving images and saving coordinates in a txt file along with class
def main(json_path):
    data = extract_json(json_path)
    
    #creating directory to store dataset and switching to that very directory
    os.mkdir('dataset')
    os.chdir('dataset')
    
    #counter used for file naming
    c = 1
    
    #extracting data corresponding to each image
    for i in data:
        
        # converting string data to json(dictionary) type
        r = json.loads(i)
        
        #wget module used to get images downloaded from the image url provided
        wget.download(r['content'],'{0}.jpg'.format(c))
        
        #extracting the dimmensions of bounding box
        z = dim(r['annotation'][0]['points'])
        
        # writing the above dimmension in a text file along with the class number 
        with open('{0}.txt'.format(c),'w') as f:
            f.write('0 '+str(z[0])+' '+str(z[1])+' '+str(z[2])+' '+str(z[3]))
            
        # incrementing the counter used for file name
        c+=1
    


# In[4]:



import json
import wget
import os

# path to the json file
json_path = 'Number_plates.json'

#invoking main function
main(json_path)


# In[ ]:




