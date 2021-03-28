import numpy as np
import os,sys,glob,argparse

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def main():
    fpath = os.path.dirname(os.path.realpath(__file__))
    
    alpha2path = "postProcessing/volumeIntegrate_volumeIntegral/0/alpha2"
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, alpha2path)
    
    a = np.loadtxt(dpath)
    times = a.T[0]
    alphas = a.T[1]
    index_max = np.argmax(alphas)
        
    print(times[index_max])
    
if __name__=="__main__":
    main()
