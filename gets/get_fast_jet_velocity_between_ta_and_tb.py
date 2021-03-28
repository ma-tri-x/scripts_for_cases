#!/bin/python

import os, sys, argparse, glob, time
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-ta", "--ta", help="time of jet impact", type=float, required=True)
    parser.add_argument("-tb", "--tb", help="time of jet impact", type=float, required=True)

    args = parser.parse_args()
    
    vjet = np.loadtxt(os.path.join(this_path,"postProcessing/swakExpression_extremeUy/0/extremeUy"))
    times = vjet.T[0]
    index_a = np.argmin(np.abs(times-args.ta))
    index_b = np.argmin(np.abs(times-args.tb))
    average = np.trapz(vjet.T[1][index_a:index_b],times[index_a:index_b]) #trapezoid integration of y(x) in trapz(y,x)
    average = average/(args.tb-args.ta)
    print(average)

if __name__=="__main__":
    main()
