import pylab as plt
import numpy as np
import cv2
import argparse
import glob

def subtract_background(img,background_img):
    diff = (255.-img) - (255.-background_img)
    #print np.max(diff),np.min(diff)
    diff = np.clip(diff*(255./(np.max(diff)+0.1)),0,255)
    return diff

def create_blank(width, height, rgb_color=(0, 0, 0)):
    """Create new image(numpy array) filled with certain color in RGB"""
    # Create black blank image
    image = np.zeros((height, width, 3), np.uint8)

    # Since OpenCV uses BGR, convert the color first
    color = tuple(reversed(rgb_color))
    # Fill image with color
    image[:] = color

    return image

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--background", help="background file to subtract", type=str, required=True)
    parser.add_argument("-i", "--input", help="input file to modify", type=str, required=True)
    parser.add_argument("-o", "--output", help="output file", type=str, required=True)
    args = parser.parse_args()

    if not "reference" in args.input:
        #background preparation
        bck = cv2.imread(args.background)
        grb = cv2.cvtColor(bck, cv2.COLOR_BGR2GRAY)
        y = len(grb)
        x = len(grb[0])
        dummy = create_blank(x,y)
        output = cv2.cvtColor(dummy, cv2.COLOR_BGR2GRAY)

        #image processing
        cap = cv2.imread(args.input)
        gray = cv2.cvtColor(cap, cv2.COLOR_BGR2GRAY)
        diff = subtract_background(gray,grb)
        output = output + diff
        
        output_col = np.clip(255.-output,0,255).astype(np.uint8)
        #im_color = cv2.applyColorMap(output_col, cv2.COLORMAP_JET)
        
        #cv2.imwrite((args.input).replace("extr","BGsubtr"), output_col)
        cv2.imwrite(args.output, output_col)
    else:
        print("skipping subtracting reference from reference")

if __name__ == '__main__':
    main()
