"""
Original Author: Advait Jawaji, ajawaji@purdue.edu
Additions by: Stephen Misenit
Assignment: Tracking Spot in Shipboard Environments
Date: 03/14/2024

Description:
    This program analyzes videos using OpenCV and returns the x-y coordinates of the April Tag on left side of Spot.
"""
import cv2
import numpy as np
import matplotlib.pyplot as plt
import time
import pyapriltags
import os


def is_apriltag(approx):
    # Check if the polygon has 4 vertices (quadrilateral)
    if len(approx) == 4:
        # Calculate the bounding box for the quadrilateral
        x, y, w, h = cv2.boundingRect(approx)

        # Check if the bounding box has a reasonable aspect ratio
        aspect_ratio =  h / float(w)
        if aspect_ratio and w :
            return True

    return False

def find_apriltag(frame, txtFile):
    # Convert the frame to grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    detector = pyapriltags.Detector()
    # Apply GaussianBlur to reduce noise and improve contour detection
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    results = detector.detect(gray)
    # Use adaptive thresholding to convert the image to binary
    _, thresh = cv2.threshold(blurred, 1, 255, cv2.THRESH_BINARY)

    # Find contours in the binary image
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Iterate through the contours
    for detection in results:
        for i in range(4):
            p1 = tuple(detection.corners[i - 1, :].astype(int))
            p2 = tuple(detection.corners[i, :].astype(int))
            cv2.line(frame, p1, p2, color=(0, 255, 0), thickness=2)

        cv2.putText(frame, str(detection.tag_id), (int(detection.center[0]), int(detection.center[1])),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        cv2.rectangle(frame, (int(detection.center[0]), int(detection.center[1])),(int(detection.center[0]), int(detection.center[1])+160),(255,0,0),2) #corner 1q
       
        if detection.tag_id == 2:
            # provide a point you wish to map from image 1 to image 2
            a = np.array([[detection.center[0],detection.center[1]+145]], dtype='float32')
            a = np.array([a])

            # finally, get the mapping
            pointsOut = cv2.perspectiveTransform(a, H)


            with open(txtFile,'+a') as fo:
                fo.write(f'{count/fps} {pointsOut[0,0,0]} {pointsOut[0,0,1]}\n')

    return frame

pts_src = np.array([[720,150],[1490,150], [1620,550],[1220,585],[720,640]])
# corresponding points from image 2 (i.e. (1490, 150) matches (0, 2750))
pts_dst = np.array([[0,0],[0,2750],[1375, 2750],[1375,1375],[1375,0]])
H, status = cv2.findHomography(pts_src, pts_dst, cv2.RANSAC, ransacReprojThreshold=5.0)



def main():
    # Find video folder
    directory = '..\..\..\..\Videos\Stiletto Videos\Left_Ceiling\\'
    for filename in os.listdir(directory):      # loop through items in folder
        if filename.endswith('.MP4'):           # If its a video, do the thing
            print("Analyzing video: "+filename+"\n")
            filePath = directory + filename
            txtFile  = "stiletto_vidData\\left_ceiling\\" + filename.replace(".MP4", ".txt")
            open(txtFile, 'w').close()
            # Open a video capture device (you can replace '0' with the camera index)
            cap = cv2.VideoCapture(cv2.samples.findFile(filePath))
            a = 0
            global fps
            global count
            fps = cap.get(cv2.CAP_PROP_FPS)
            count = 0
            while True:
                # Read a frame from the video capture

                ret, frame = cap.read()
                count+=1

                if not ret:
                    break

                # Find and draw AprilTag in the frame
                result_frame = find_apriltag(frame,txtFile)


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
