#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import gzip

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))

    parser = argparse.ArgumentParser()
    parser.add_argument("-off", "--offset", help="offset to lower boundary. normally 1e-6", 
                        type=float, required=False, default=0.0)
    args = parser.parse_args()

    infiles=glob.glob(os.path.join(this_path,"proc*/constant/polyMesh/points.gz"))

    minpoint=10000.
    for points in infiles:
        p = []
        with gzip.open(points,"r") as f:
            while True:
                l = f.readline()
                if not l: break
                if "(" in l and ")" in l:
                    p.append(float(l.split(" ")[1]))
        minp=np.min(p)
        if minp < minpoint: minpoint = minp
    print(minpoint+args.offset)

if __name__=="__main__":
    main()
