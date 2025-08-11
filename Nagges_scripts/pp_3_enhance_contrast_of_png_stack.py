import numpy as np
import os,sys #,argparse
import cv2, glob

def rotate(img):
    for i in range(3):
        img = np.rot90(img)
    return img

def CLAHE_enhance_contrast(img):
    #-----Converting image to LAB Color model----------------------------------- 
    lab= cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    #-----Splitting the LAB image to different channels-------------------------
    l, a, b = cv2.split(lab)
    #-----Applying CLAHE to L-channel-------------------------------------------
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
    cl = clahe.apply(l)
    #cv2.imshow('CLAHE output', cl)
    return cl
    #-----Merge the CLAHE enhanced L-channel with the a and b channel-----------
    #limg = cv2.merge((cl,a,b))
    #-----Converting image from LAB Color model to RGB model--------------------
    #final = cv2.cvtColor(limg, cv2.COLOR_LAB2BGR)
    #return final
    
def global_enhance_contrast(img):
    #img = cv2.imread('wiki.jpg',0)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    equ = cv2.equalizeHist(gray)
    #res = np.hstack((img,equ)) #stacking images side-by-side
    #cv2.imwrite('res.png',res)
    return equ

def main():
    f=''
    try:
        f = sys.argv[1]
    except(IndexError):
        print('usage: {} imagefiles prefix'.format(sys.argv[0]))
        exit(1)
    
    infiles=glob.glob(sys.argv[1])
    if not infiles:
        print("error: no such file or directory")
        exit(1)
    for infile in infiles:
        print(infile)
        img = cv2.imread(infile)
        y, x, channels = img.shape
        enh_img = CLAHE_enhance_contrast(img)
        #print("writing to enh_{}.png".format(os.path.basename(infile).split('.png')[0]))
        dest_filename='{}/enh_{}.png'.format(os.path.dirname(infile),os.path.basename(infile).split('.png')[0])
        cv2.imwrite(dest_filename,enh_img)
        #cv2.imwrite(infile,enh_img)
    
    
    
    
if __name__=="__main__":
    main()
