import numpy as np
import os,sys,glob,argparse,gzip

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--case", help="case dir.", type=str, required=False, default=".")
    parser.add_argument("-t", "--startTime", help="start time", type=str, required=True)
    parser.add_argument("-f", "--field", help="field name", type=str, required=True)
    
    
    
    args = parser.parse_args()
    thispath = os.path.dirname(os.path.realpath(__file__))
    fpath = os.path.join(thispath,args.case)
    file_to_open="{}/{}.gz".format(args.startTime,args.field)
    try:
        with gzip.open(os.path.join(fpath,file_to_open),"r") as f:
            a = f.readlines()
    except(IOError):
        print("there is no {} file".format(file_to_open))
        exit(1)
    
    fmax=0.
    fmin=1e10
    for line in a[22:]:
        try:
            val = float(line.split("\n")[0])
        except(ValueError):
            pass
        if val > fmax: fmax = val
        if val < fmin: fmin = val
        
    print("{} {}".format(fmin,fmax))
    
if __name__=="__main__":
    main()
