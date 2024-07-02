#!/bin/python

import os, sys, argparse
import numpy as np

def determine_contours(contfile):
    list_of_contours = []
    with open(contfile, "r") as f:
        data = f.readlines()
    #append=False
    single_data=[]
    for i in data:
        if not "#" in i and not i == "\n":
            single_data.append([float(j) for j in i.replace("\n","").split()])
        if "# Contour" in i and not single_data == []:
            list_of_contours.append(single_data)
            single_data = []
    else: # for-else is for checking on eof!
        list_of_contours.append(single_data)
    return list_of_contours

def alter_contour_file(list_of_contours,outputfile,takeoutthree,fontsize):
    with open(outputfile,"w") as f:
        for l,contour in enumerate(list_of_contours):
            n = len(contour)
            middle = int(n/2)
            for k,datapoint in enumerate(contour):
                if not k == middle and not takeoutthree*(k == middle-1 or k == middle +1):
                    f.write(f"{datapoint[0]}  {datapoint[1]}  {datapoint[2]}\n")
                elif k == middle:
                    print(f"set label {l+1} \"{datapoint[2]}\" at {datapoint[0]},{datapoint[1]} centre front font \",{fontsize}\"")
                    f.write("\n")
            f.write("\n\n")
        

def main():
    #this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-w", "--takeoutthree", help="take out only one or three", type=bool, required=False, default=False)
    parser.add_argument("-f", "--fontsize", help="fontsize of label", type=int, required=False, default=12)

    args = parser.parse_args()
    
    #print("use parenthesis for prints")
    
    list_of_contours = determine_contours("cont.dat")
    #print(list_of_contours)
    alter_contour_file(list_of_contours,"altered_cont.dat",args.takeoutthree,args.fontsize)

if __name__=="__main__":
    main()
