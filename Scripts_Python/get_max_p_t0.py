import numpy as np
import os,sys,glob,argparse,gzip

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--case", help="case dir.", type=str, required=False, default=".")
    
    # NOTE: "This script is written for cases which write theta (half opening angle in degrees)
    #        into THETA file in case dir"
    
    args = parser.parse_args()
    thispath = os.path.dirname(os.path.realpath(__file__))
    fpath = os.path.join(thispath,args.case)
    try:
        with gzip.open(os.path.join(fpath,"0/p_rgh.gz"),"r") as f:
            a = f.readlines()
    except(IOError):
        print("there is no 0/p_rgh.gz file")
        exit(1)
    
    pmax=0.
    for line in a[22:]:
        try:
            val = float((line.decode('utf-8')).split("\n")[0])
        except(ValueError):
            pass
        if val > pmax: pmax = val
        
    print(pmax)
    
if __name__=="__main__":
    main()
