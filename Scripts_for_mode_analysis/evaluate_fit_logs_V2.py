#!/bin/python

import os, sys, argparse, glob
#, time
import numpy as np
from find_biggestNumber_py3 import *

def get_amp_and_err(line,parm):
    #print(line,parm)
    amp = float(line.split("=")[1].split("+")[0])
    err = float(line.split("+/-")[1].split("(")[0])
    #print(amp,err)
    return amp, err

def extract_modes(fit_log_file):
    try:
        with open(fit_log_file, "r") as f:
            lines = f.readlines()
    except(FileNotFoundError):
        print("bubble breakup at {}".format(fit_log_file))
        exit(0)
        
    modes, modes_err = np.zeros(9),np.zeros(9)
    for line in lines:
        if "a0" in line[:4] and "=" in line:
            modes[0],modes_err[0] = get_amp_and_err(line,"a0")
        for m in np.arange(0,10,1):
            parm = "a{}".format(m)
            if parm in line[:4] and "=" in line:
                amp,err = get_amp_and_err(line,parm)
                if abs(modes[m]) < abs(amp) or modes_err[m] > err:
                    modes[m],modes_err[m] = amp,err
    return modes,modes_err

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--case_dir", help="case dir without contours/...", type=str, required=True)
    args = parser.parse_args()
    
    print("evaluating {} for modes".format(args.case_dir))
    
    l = glob.glob("{}/contours/contours0.*.csv".format(args.case_dir.replace("/","")))
    tf = glob.glob("{}/processor0/*".format(args.case_dir.replace("/","")))
    time_files = [ i.split('/')[-1] for i in tf if path_is_num(i.split('/')[-1])]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    time_steps = np.sort(time_steps)
    if l == []: 
        print("ERROR: not found: {}/contours/contours0.*.csv".format(args.case_dir.replace("/","")))
        exit(1)
    ll = np.sort([ int((i.split("{}/contours/contours0.".format(args.case_dir.replace("/","")))[1]).split(".csv")[0]) for i in l ])
    
    with open("MODES_{}.dat".format(args.case_dir.replace("/","")),"w") as out:
        out.write("#time_step    mode 0    1    2    3    4    5    6    7    8 \t err  0    1    2    3    4    5    6    7    8 \n")
        for j,i in enumerate(ll):
            fit_log = "{}/fit_logs/fit.{}.log".format(args.case_dir.replace("/",""),i)
            modes,modes_err = extract_modes(fit_log)
            out.write("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format(
                      time_steps[j],modes[0],
                        modes[1],
                        modes[2],
                        modes[3],
                        modes[4],
                        modes[5],
                        modes[6],
                        modes[7],
                        modes[8],
                        modes_err[0],
                        modes_err[1],
                        modes_err[2],
                        modes_err[3],
                        modes_err[4],
                        modes_err[5],
                        modes_err[6],
                        modes_err[7],
                        modes_err[8]))

if __name__=="__main__":
    main()
