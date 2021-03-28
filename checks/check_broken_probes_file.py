#!/bin/python

import os, sys, argparse, glob, time
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    try:
        f=sys.argv[1]
    except:
        print("usage: {} <probesFile>")
        exit(1)
    
    a=np.loadtxt(f)
    for i in a:
        if np.abs(i[1]) > 1e20:
            print("broken")
            break
    

if __name__=="__main__":
    main()
