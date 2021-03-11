#!/usr/bin/env python
# coding: utf-8

# In[8]:


import cv2
import numpy as np
import OCR

# loading the configuration and weights files obtained after training the model with the numberplate dataset
def load():
    net = cv2.dnn.readNet('./yolov3_training_final.weights','./yolov3_testing.cfg')
    return net


#extracting the cordinates of number plate out of the supplied image after detection
def get_cordinates(outs, image):  # suppling the custom output layer and the test image as input
    class_ids = []
    confidences = []
    boxes = []
    height, width, channels = image.shape  #getting the shape of input image
    for out in outs:
        for detection in out:
            scores = detection[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            if confidence > 0.3:
                # Object detected
                print(class_id)
                center_x = int(detection[0] * width)
                center_y = int(detection[1] * height)
                w = int(detection[2] * width)
                h = int(detection[3] * height)

                # Rectangle coordinates
                x = int(center_x - w / 2)
                y = int(center_y - h / 2)

                boxes.append([x, y, w, h])
                confidences.append(float(confidence))
                class_ids.append(class_id)
    return boxes, confidences, class_ids


#extract the part of image in which the number plate is detected 
def crop(boxes, image):
    img = image
    x, y, w, h = boxes[0]     #get the coordinates of the part the portion where the number plate is found
    crop_img = img[y:y+h, x:x+w]      #cropping the image
   # cv2.imwrite('crop.jpg',crop_img)
    x =  OCR.get_number(crop_img)    #sending the image for extraction of number using OCR from OCR space api
    return x
        

def main(image):
    net = load()
    classes = ["number_plate"]
    layer_names = net.getLayerNames()
    output_layers = [layer_names[i[0] - 1] for i in net.getUnconnectedOutLayers()]
    colors = np.random.uniform(0, 255, size=(len(classes), 3))
    
    
    #rescaling, size, mean, swapRB channels of the input image
    blob = cv2.dnn.blobFromImage(image, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
    net.setInput(blob)
    outs = net.forward(output_layers)
    boxes, confidences, class_ids = get_cordinates(outs, image)
    indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4, )
    #dele(boxes, confidences, indexes, image, colors, class_ids, classes)
    
    x = crop(boxes, image)    #sending the image to crop the detected number plate portion 
    return x








