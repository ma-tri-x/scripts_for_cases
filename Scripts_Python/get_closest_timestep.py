import os
import sys
import numpy as np
import argparse

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="path e.g. like \"processor0\"", type=str, required=True)
    parser.add_argument("-t", "--time", help="time e.g. like 1e-6", type=float, required=True)
    args = parser.parse_args()
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.path)

    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    
    print time_steps[np.argmin(np.abs(time_steps - args.time))]

if __name__ == "__main__":
    main()