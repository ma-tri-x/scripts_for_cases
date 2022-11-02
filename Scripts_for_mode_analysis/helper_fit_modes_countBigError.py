#!/bin/python

import os, sys, argparse
#, glob, time
#import numpy as np

def extract_percentage_value(line):
    val_str = (line.split("(")[1]).split("%")[0]
    parm = int(line.split(" ")[0][1:])
    return float(val_str), parm

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-z", "--zeroth_only", help="set to \"true\" if only zeroth mode is checked", type=str, required=False, default="false")

    args = parser.parse_args()
    
    #print("use parenthesis for prints")
    
    with open("fit.log","r") as f:
        lines = f.readlines()
    
    count = 0
    
    for line in lines:
        if "%" in line:
            percentage_error,parm = extract_percentage_value(line)
            if percentage_error > 100. and parm < 4: count = count +1
    if count >= 2:
        print("breakup")
    else:
        print("smooth")

if __name__=="__main__":
    main()
