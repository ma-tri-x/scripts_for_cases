import numpy as np
import os,sys,glob,argparse

def find_first_min(alpha2array):
    lastitem = alpha2array[0]
    for num,item in enumerate(alpha2array[:-2]):
        if (lastitem-item)*(item-alpha2array[num+1]) < 0:
            return num
        lastitem = item

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--case", help="case dir.", type=str, required=False, default=".")
    
    # NOTE: "This script is written for cases which write theta (half opening angle in degrees)
    #        into THETA file in case dir"
    
    args = parser.parse_args()
    thispath = os.path.dirname(os.path.realpath(__file__))
    fpath = os.path.join(thispath,args.case)

    alpha2path = "postProcessing/volumeIntegrate_volumeIntegral/0/alpha2"
    dpath = os.path.join(fpath, alpha2path)
    a = np.loadtxt(dpath)

    time_of_maximum = np.argmax(a.T[1])
    time_of_collapse = find_first_min(a.T[1][time_of_maximum:])
    Tc = a[time_of_collapse+time_of_maximum][0]
    print(Tc)
    
if __name__=="__main__":
    main()
