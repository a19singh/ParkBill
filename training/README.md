## Dataset Collection

The dataset is in the json format named [Indian_Number_plates.json](https://www.kaggle.com/dataturks/vehicle-number-plate-detection) available at Kaggle.com. This file contains links to the images of vehicles along with the coordinates of localization of number plates.

## Dataset Preparation

Using python script [Prepare_Dataset.py](./Prepare_Dataset.py) , these images have been downloaded and coordinates have been extracted and stored into a text file on the basis of which the model will be trained.

## Model Training 

### Steps to follow

- Compress all the images and txt files in a zip format named **images.zip**
- create a folder named **yolov3** in your google drive
- Upload the zip file to same yolov3 folder
- Upload Train_YoloV3.ipynb file to google colab

After the completion of above steps model is ready to be trained. After the training the weights file can be obtained from the very folder where the images.zip file has been uploaded. The obtained **yolov3_training_final.weights** file will be used for testing and the deployment of the model.

###Note:
Due to the use of makefile a linux machine(Colab) will be the preferred choice to train the model as it is a bit complicated to create executable file on windows but [here](https://github.com/AlexeyAB/darknet#how-to-compile-on-windows-using-cmake) is the step to do so if someone wants to perform it on windows machine.