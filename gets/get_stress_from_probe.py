#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
#import matplotlib.pyplot as plt

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-tr", "--threshold", help="threshold to count from (MPa)", type=float, required=False, default=1.0)
    parser.add_argument("-tmin", "--tmin", help="min time to start counting", type=float, required=False, default=20e-6)
    parser.add_argument("-ty", "--type", help="average (avg) or maximum (max)", type=str, required=False, default="avg")

    args = parser.parse_args()
    
    f = glob.glob(os.path.join(this_path,"probes/*/p_rgh"))[0]
    a = np.loadtxt(f,comments="#")
    fractions= []
    l=[]
    
    if args.type == "avg":
        for i,entry in enumerate(a):
            if entry[1]/1e6 > args.threshold and a[i-1][1]/1e6 < args.threshold and entry[0] > args.tmin:
                l =[]
                l.append(entry)
            elif entry[1]/1e6 > args.threshold and a[i-1][1]/1e6 > args.threshold and entry[0] > args.tmin:
                l.append(entry)
            elif entry[1]/1e6 < args.threshold and a[i-1][1]/1e6 > args.threshold and entry[0] > args.tmin:
                fractions.append(np.array(l))
                l = []
        average_stress_sum = 0.
        for i in fractions:
            average_stress = np.trapz(i.T[1]/1e6,i.T[0])/(i.T[0][-1]-i.T[0][0])
            average_stress_sum = average_stress_sum + average_stress
            #plt.plot(i.T[0],i.T[1])
        print(average_stress_sum)
    else:
        print(np.max(a.T[1]/1e6))
    #plt.plot(((a.T[1]/1e6)>args.threshold)*a.T[0],((a.T[1]/1e6)>args.threshold)*a.T[1]/1e6)
    #plt.show()


if __name__=="__main__":
    main()
