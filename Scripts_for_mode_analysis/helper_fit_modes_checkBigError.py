#!/bin/python

import os, sys, argparse
#, glob, time
#import numpy as np

def extract_percentage_value(line):
    val_str = (line.split("(")[1]).split("%")[0]
    return float(val_str)

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-z", "--zeroth_only", help="set to \"true\" if only zeroth mode is checked", type=str, required=False, default="false")

    args = parser.parse_args()
    
    #print("use parenthesis for prints")
    
    with open("fit.log","r") as f:
        lines = f.readlines()
    
    badError = False
    
    for line in lines:
        if "%" in line:
            percentage_error = extract_percentage_value(line)
            if percentage_error > 95.: badError = True
            if "a0" in line and args.zeroth_only == "true" and percentage_error > 1.0: badError = True
            #print(line.split("\n")[0], extract_percentage_value(line),badError)
    if badError:
        print("true")
    else:
        print("false")

if __name__=="__main__":
    main()
