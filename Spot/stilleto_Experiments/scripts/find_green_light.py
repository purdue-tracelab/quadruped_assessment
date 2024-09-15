"""
Author: Advait Jawaji, ajawaji@purdue.edu
Assignment: Tracking Spot in Shipboard Environments
Date: 03/14/2024

Description:
    This program analyzes videos using OpenCV and returns the x-y coordinates of the green light in front of Spot.
"""
import cv2
import numpy as np
import matplotlib.pyplot as plt
import time
import pyapriltags
import os

'''plt.ion()
plt.grid()
plt.title('Strafing Underway')
plt.xlabel('Displacement (in mm)')
plt.ylabel('Displacement (in mm)')
plt.plot([0,0,1375,1375,0],[0,2750,2750,0,0],'k-')
plt.xlim(-1037.5,2412.5)
plt.ylim(-350,3100)'''
def is_green(approx):
    # Check if the polygon has 4 vertices (quadrilateral)
    if len(approx) == 4:
        # Calculate the bounding box for the quadrilateral
        x, y, w, h = cv2.boundingRect(approx)
        # Check if the bounding box has a reasonable aspect ratio
        aspect_ratio =  h / float(w)
        if aspect_ratio > 1.2:
            return True

    return False
'''
def find_apriltag(frame):
    # Convert the frame to grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Apply GaussianBlur to reduce noise and improve contour detection
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # Use adaptive thresholding to convert the image to binary
    _, thresh = cv2.threshold(blurred, 200, 255, cv2.THRESH_BINARY)

    # Find contours in the binary image
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Iterate through the contours
    for contour in contours:
        # Approximate the contour to a polygon
        epsilon = 0.05 * cv2.arcLength(contour, True)
        approx = cv2.approxPolyDP(contour, epsilon, True)

        # Check if the polygon represents an AprilTag
        if is_apriltag(approx):
            # Draw the bounding box on the original frame
            x, y, w, h = cv2.boundingRect(approx)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

    return frame
'''
pts_src = np.array([[180, 680], [1180, 100], [1760, 340],[610,1055],[1430,740]])
# corresponding points from image 2 (i.e. (154, 174) matches (212, 80))
pts_dst = np.array([[0,0],[0,2750],[1375, 2750],[917,0],[1375,1375]])
H, status = cv2.findHomography(pts_src, pts_dst, cv2.RANSAC, ransacReprojThreshold=5.0)


def find_green_light(frame, txtFile):
    # Convert the frame to the HSV color space
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    # Define the lower and upper bounds for green color in HSV
    lower_green = np.array([40, 40, 255])
    upper_green = np.array([80, 255, 255])
    #lower_green = np.array([75, 50, 255])  # Adjust the lower bounds
    #upper_green = np.array([80, 100, 255])
    # Create a binary mask using the inRange function
    mask = cv2.inRange(hsv, lower_green, upper_green)

    # Find contours in the binary mask
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Iterate through the contours
    for contour in contours:
        epsilon = 0.05 * cv2.arcLength(contour, True)
        approx = cv2.approxPolyDP(contour, epsilon, True)

        if is_green(approx):
        # Calculate the bounding box for the contour
            x, y, w, h = cv2.boundingRect(contour)

            # Draw the bounding box on the original frame
            cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 4)
            #cv2.rectangle(frame, (180,680),(190,690),(255,0,0),2) #corner 1q
            #cv2.rectangle(frame, (1180,100),(1190,110),(255,0,0),2)
            #cv2.rectangle(frame, (1430,740),(1440,750),(255,0,0),2)
            #cv2.rectangle(frame,(610,1055),(620,1065),(255,0,0),2)
            #cv2.rectangle(frame,(1760,340),(1770,350),(255,0,0),2)
            # provide points from image 1


            # calculate matrix H
            

            # provide a point you wish to map from image 1 to image 2
            a = np.array([[x, y+200]], dtype='float32')
            a = np.array([a])

            # finally, get the mapping
            pointsOut = cv2.perspectiveTransform(a, H)
            #print()
            #print(f'{x},{y}')
            #plt.plot([180,1180,1760],1088-np.array([680,100,340]),'k-')
            #plt.plot(x,1088-y,'bo')

            
            
            #plt.plot(pointsOut[0,0,0],pointsOut[0,0,1],'bo')

            with open(txtFile,'+a') as fo:
                fo.write(f'{count/fps} {pointsOut[0,0,0]} {pointsOut[0,0,1]}\n')
    return frame



def main():
    # Find video folder
    directory = '..\..\..\..\Videos\Stiletto Videos\Front_Left_Cabinet\\'
    for filename in os.listdir(directory):  # loop through items in folder
        if filename.endswith('.MP4'):  # If its a video, do the thing
            print("Analyzing video: " + filename + "\n")
            filePath = directory + filename
            txtFile = "stiletto_vidData\\front_left_cabinet\\" + filename.replace(".MP4", ".txt")
            # Erase txt file if already exists to reset it for new data
            open(txtFile, 'w').close()
            # Open a video capture device (you can replace '0' with the camera index)
            cap = cv2.VideoCapture(cv2.samples.findFile(filePath))
            a = 0
            global fps
            global count
            fps = cap.get(cv2.CAP_PROP_FPS)
            count = 0
            length = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            for f in range(length):
            #while True:
                # Read a frame from the video capture

                ret, frame = cap.read()
                count+=1

                if not ret:
                    break

                # Print percentage of completion
                #percent = (f/length) * 100
                #print("Percent Analyzed: ",end='')
                #print(str(percent), end='\r')

                # Find and draw AprilTag in the frame
                result_frame = find_green_light(frame,txtFile)

                # Display the frame
                #cv2.imshow('Spot Tracking', result_frame)

                # Break the loop if 'q' key is pressed
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

            # Release the video capture device and close OpenCV windows
            cap.release()
            cv2.destroyAllWindows()

        else:
            print("Skipping: " + filename)


if __name__ == "__main__":
    main()
