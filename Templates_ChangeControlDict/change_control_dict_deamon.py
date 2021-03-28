#!/bin/python

import os, sys, argparse, glob, time, json, subprocess
import numpy as np
from datetime import datetime as dt

def tail(f, lines=1, _buffer=4098):
    """Tail a file and get X lines from the end"""
    # place holder for the lines found
    lines_found = []

    # block counter will be multiplied by buffer
    # to get the block size from the end
    block_counter = -1

    # loop until we find X lines
    while len(lines_found) < lines:
        try:
            f.seek(block_counter * _buffer, os.SEEK_END)
        except IOError:  # either file is too small, or too many lines requested
            f.seek(0)
            lines_found = f.readlines()
            break

        lines_found = f.readlines()

        # decrement the block counter to get the
        # next X bytes
        block_counter -= 1

    return lines_found[-lines:]

def get_current_runtime():
    try:
        with open("run.log","r") as f:
            lines = tail(f, 100)
    except(IOError):
        return
    takentime = 0.
    for line in lines:
        if "Taken" in line:
            time = float(line.split(" ")[3])
            if time > takentime: takentime = time
    return takentime

def change_controlDict(part_dict):
    for item in part_dict:
        os.system("sed -i \"s/^{} .*;/{}    {};/g\" system/controlDict".format(item, item, part_dict[item]))

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--interval", help="waiting interval", type=float, required=False, default=10.)

    dict_file = os.path.join(this_path,"change_controlDict.json")

    args = parser.parse_args()
    
    try:
        with open(dict_file,'r') as f:
            change_dict = json.load(f)
    except(IOError):
        with open(dict_file,"w") as f:
            d = {"110e-6" : {
                    "writeControl" : "adjustableRunTime",
                    "writeInterval" : 10e-6,
                    "stayBelowAcousticCo" : 30,
                    "critAcousticCo" : 0.01
                    }
                }
            json.dump(d,f)
    
    trial=0
    maxtrials=3
    while True:
        try:
            with open(dict_file,'r') as f:
                change_dict = json.load(f)
            
            now = (dt.now()).strftime("%Y-%m-%d %H:%M:%S")
            
            if os.path.isfile(os.path.join(this_path,"stop_deamon")):
                print("{} stopping deamon in {}".format(now,this_path))
                print("rm {}".format(os.path.join(this_path,"stop_deamon")))
                os.system("rm {}".format(os.path.join(this_path,"stop_deamon")))
                exit(0)
                
            curr_time = get_current_runtime()
            
            if curr_time:
                for time_switch in change_dict:
                    if curr_time > float(time_switch): 
                        change_controlDict(change_dict[time_switch])
                        print("{} controlDict changed to {}".format(now, change_dict[time_switch]))
            else:
                if trial >= maxtrials:
                    print("{} no run.log. Stopping deamon in {}".format(now,this_path))
                    exit(1)
                print("{} waiting for run.log".format(now))
                trial += 1
            
            time.sleep(args.interval)
        
        except(KeyboardInterrupt):
            print("{} stopping deamon in {}".format(now,this_path))
            exit(0)
    

if __name__=="__main__":
    main()
