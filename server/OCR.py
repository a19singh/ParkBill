#!/usr/bin/env python
# coding: utf-8

# In[1]:


import cv2
import io
import requests
import json
import re
from config import apikey ## comment this if using "apikey" variable in this file (below function)


def get_number(image):
    #image = cv2.imread('crop.jpg')

    #Image saturation
    ret, thresh1 = cv2.threshold(image, 120, 255, cv2.ADAPTIVE_THRESH_MEAN_C)

    #OCR space api used to extract number plate
    api = 'https://api.ocr.space/parse/image'
    _, compress_img = cv2.imencode('.jpg', thresh1)
    
    #convert image into bytes
    file_byte = io.BytesIO(compress_img)

    #api key for ocr.space free plan
    #apikey = 'mainahibataunga' ## keep this commented if using apikey from the config file above imported
	
	#api call
    result = requests.post(api,
                         files = {'crop.jpg': file_byte},
                         data = {'apikey': apikey }
                         )
    
    #converting and extracting number plate
    res = result.content.decode()
    x = json.loads(res)['ParsedResults'][0]['ParsedText']
    
    #removing unnecessary data like escape sequences
    x = re.sub("[^0-9a-zA-Z' ]+", '',x)
    
    #return clean extracted number plate
    return x
