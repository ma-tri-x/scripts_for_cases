#!/bin/python

import os, sys, glob
#, argparse, time
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    #parser = argparse.ArgumentParser()
    #parser.add_argument("-a", "--argument", help="some required string", type=str, required=True)
    #parser.add_argument("-b", "--secondarg", help="some default float", type=float, required=False, default=1.5)

    #args = parser.parse_args()
    
    #print("use parenthesis for prints")
    dest_dir = sys.argv[1]
    startNUM = int(sys.argv[2])
    dest_dir = dest_dir.replace("//","/")
    
    l = glob.glob("{}/contours0.*.csv".format(dest_dir).replace("//","/"))
    if l == []: 
        print("ERROR: not found: {}/contours0.*.csv".format(dest_dir).replace("//","/"))
        exit(1)
    ll = [ int((i.split("{}/contours0.".format(dest_dir).replace("//","/"))[1]).split(".csv")[0]) for i in l ]
    for i in np.sort(ll):
        if i >= startNUM:
            print(i)

if __name__=="__main__":
    main()
