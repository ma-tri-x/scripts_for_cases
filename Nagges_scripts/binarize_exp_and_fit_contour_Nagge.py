#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import cv2,json
import matplotlib.pyplot as plt

def draw_ellipse(center_x,center_y,axis_x,axis_y):
    center_coordinates = (center_x, center_y)
    
    axesLength = (axis_x, axis_y)
    
    angle = 0
    
    startAngle = 0
    
    endAngle = 360
    
    # Red color in BGR
    color = (0, 0, 255)
    
    # Line thickness of 5 px
    thickness = 5
    
    # Using cv2.ellipse() method
    # Draw a ellipse with red line borders of thickness of 5 px
    return (center_coordinates, axesLength,
            angle)

def crop_the_contour(cnt,y_thres_bottom=150,y_thres_upper=100):
    l = []
    for i,k in enumerate(cnt): 
        if k[0][1] > y_thres_upper and k[0][1] < y_thres_bottom:  
            l.append([[k[0][0],k[0][1]]])
    crop_cnt = np.array(l,dtype="int32")
    return crop_cnt

def test_line_draw(thresh_cropped_img):
    row=200
    for i,k in enumerate(thresh_cropped_img[200]):
        thresh_cropped_img[200][i] = 0
    return thresh_cropped_img

def crop_to_bubble(thresh_cropped_img,crum=False):
    #lower border:
    row = len(thresh_cropped_img)-1
    thesum = np.sum(thresh_cropped_img[row])
    thesum_temp = thesum
    while thesum_temp > 0.80*thesum:
        row = row - 1
        thesum_temp = np.sum(thresh_cropped_img[row])
    lower_border = row
    
    #upper border:
    row = 0
    thesum = np.sum(thresh_cropped_img[row])
    thesum_temp = thesum
    two_percent_white = len(thresh_cropped_img[row])*255*0.02
    while thesum_temp < two_percent_white:
        row = row + 1
        thesum_temp = np.sum(thresh_cropped_img[row])
    upper_border = row
    
    #left border:
    col = 0
    thesum = np.sum(thresh_cropped_img.T[col])
    thesum_temp = thesum
    factor = 1.1*thesum
    if crum:
        factor = 1.4*thesum
    while thesum_temp < factor:
        col = col + 1
        thesum_temp = np.sum(thresh_cropped_img.T[col])
    left_border = col
    
    #right border:
    col = -1
    thesum = np.sum(thresh_cropped_img.T[col])
    thesum_temp = thesum
    twenty_percent_bigger = 1.2*thesum
    while thesum_temp < twenty_percent_bigger:
        col = col - 1
        thesum_temp = np.sum(thresh_cropped_img.T[col])
    right_border = col
    
    return thresh_cropped_img[upper_border:lower_border, left_border:right_border]

def get_sorted_times(dpath):
    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.sort(np.array([float(i.split('/')[-1]) for i in time_files]))
    return time_steps

def get_fps(dpath):
    logfile = glob.glob(f"{dpath}/*.cihx")[0]
    l = []
    with open(logfile, "rb") as f:
        l = f.readlines()
    fps = np.nan
    for i in l:
        if b"recordRate" in i:
            try:
                fps = float(str(i).split("<recordRate>")[1].split("</recordRate>")[0])
            except:
                print(f"Warning, cannot get fps in {dpath}")
                
    return fps

def get_leftmost_and_topmost(cnt):
    leftmost = 100000000
    topmost = 100000000
    formated_cnt = np.array([i[0] for i in cnt]) # bec it's stored as [[0,1]], ... , [[x,y]]
    topmost = np.min(formated_cnt[:,1]) # for this writing it needs to be a np-array
    leftmost = np.min(formated_cnt[:,0])
    return [leftmost,topmost]
        

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--dpath", help="path to images of recording", type=str, required=True)
    parser.add_argument("-p", "--pxpermm", help="pixel per millimeter", type=float, required=True)

    args = parser.parse_args()
    
    #print("use parenthesis for prints")
    
    dpath = args.dpath
    
    files = sorted(glob.glob(f"{dpath}/*png"))
    #files = sorted(glob.glob(f"{dpath}/sequence/cav*0010.png"))
    
    if not files:
        print("ERROR: {} - no duch file or directory".format(filesString))
        exit(1)
    
    area_array = []
    
    fps = get_fps(dpath)
    T = 1./fps
    pxpermm = args.pxpermm
    pxperm = pxpermm * 1e3
    scale = 1./pxperm
    
    
    for num,thefile in enumerate(files):
        leftmost,topmost = np.nan,np.nan
        #print(thefile)
        imgname = thefile
        number = num+1 #int(thefile.split("/")[-1].split(".")[1])
        
        ts = number*T
        img = cv2.imread(imgname)
        pre_cropped_image = img[0:16, 0:120]
        gray = cv2.cvtColor(pre_cropped_image, cv2.COLOR_BGR2GRAY)
        ret,thresh = cv2.threshold(gray,150,255,0)
        #invert the image
        thresh = cv2.bitwise_not(thresh)
        
        thresh_cropped_to_bubble = thresh #crop_to_bubble(thresh)
        ###contours, _ = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        ##contours, _ = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
        ##cnt = sorted(contours, key=cv2.contourArea)[-1]
        ##crop_cnt = crop_the_contour(cnt)
        ##print(crop_cnt)
        ##cv2.drawContours(cropped_image, [crop_cnt], 0, (0,255,0), 3)
        ##ellipse = cv2.fitEllipse(crop_cnt)
        ###print(ellipse)
        ###cv2.ellipse(img,ellipse, (0,0,255), 3)
        ##thresh_test_line_draw = test_line_draw(thresh)
        #cv2.imshow("gray", gray)
        #cv2.imshow("thresh", thresh)
        #y_half = int(len(thresh_cropped_to_bubble)*0.5)
        #x_half = int(len(thresh_cropped_to_bubble[0])*0.5)
        #ellipse = draw_ellipse(center_x=x_half,center_y=y_half,axis_x=2*x_half,axis_y=2*y_half)
        #cv2.ellipse(thresh_cropped_to_bubble,ellipse, (0,0,255), 3)
        
        contours, _ = cv2.findContours(thresh_cropped_to_bubble, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
        try:
            cnt = sorted(contours, key=cv2.contourArea)[-1]
            #crop_cnt = crop_the_contour(cnt)
            #print(crop_cnt)
            rgb_img = cv2.cvtColor(thresh_cropped_to_bubble, cv2.COLOR_GRAY2BGR)
            cv2.drawContours(rgb_img, [cnt], 0, (0,255,0), 1)
            
            #cv2.imshow("thresh_cropped_to_bubble", thresh_cropped_to_bubble)
            #cv2.imshow("Ellipse", cropped_image)
            #cv2.imshow("thresh_test", thresh_test_line_draw)
            
            outfilename = "{}/contour_{}".format(os.path.dirname(imgname),os.path.basename(imgname))
            
            #cv2.imshow("thresh_cropped_to_bubble", rgb_img)
            #cv2.waitKey(0)
            #cv2.destroyAllWindows()
            
            cv2.imwrite(outfilename, rgb_img)
            area = float(cv2.contourArea(cnt))*(scale)**2
            radius = np.sqrt(area/np.pi)
            # compute the center of the contour
            M = cv2.moments(cnt)
            lm = get_leftmost_and_topmost(cnt)
            leftmost,topmost = lm[0]*scale,lm[1]*scale
            ## only for deciphering cnt:
                #print(np.array(cnt).shape)
                #print("")
                #print(np.array(formated_cnt)[:,0])
                #print(np.array(formated_cnt).shape)
                #plt.scatter(np.array(formated_cnt)[:,0],np.array(formated_cnt)[:,1])
                #plt.show()
            ##
            try:
                cX = float(M["m10"] / M["m00"])*(scale)
                cY = float(M["m01"] / M["m00"])*(scale)
            except(ZeroDivisionError):
                cX = np.nan
                cY = np.nan
        except(IndexError):
            area = np.nan
            radius = np.nan
            cX = np.nan
            cY = np.nan
        
        area_array.append([number,ts, area, radius, cX, cY, leftmost,topmost])
        #except(IndexError):
            #print("skipping {} due to IndexError".format(thefile))
    area_array = sorted(area_array)
    
    np.savetxt("area_of_bubble.dat",area_array,header="frame number, time [s], area [m^2], radius [m], center_x, center_y, left_extension, top_extension")
    d = {"fps":fps}
    with open("fps.dat","w") as f:
        json.dump(d,f)

if __name__=="__main__":
    main()
