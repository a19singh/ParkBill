# Server Side

The system is implemented using Python and the model will be deployed on an AWS EC2 instance for real time use scenario.

The server side API is made with [flask](https://flask.palletsprojects.com/en/1.1.x/) and is deployed on WSGI server.

```
#Launch the api

cd server
python3 app.py
```

The developed model first detects the number plate portion from the image and then crops that entire portion for further processing using the [plate_detect.py](./plate_detect.py) file.

Using [OCR](./OCR.py) (Optical Character Recognition) method the model is successfully able to extract the registration number of the vehicle from the cropped portion which is further saved in a database. 

### Note:

If you are not provided with the config file then do generate your own free apikey from [ocr.space](https://ocr.space/ocrapi) and comment the apikey import line (line no. 12) in [OCR](./OCR.py) file.