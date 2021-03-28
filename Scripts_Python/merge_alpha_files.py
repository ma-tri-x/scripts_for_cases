import numpy as np
import os,sys,glob,argparse

def main():
    fpath = os.path.dirname(os.path.realpath(__file__))
    alpha_path = "postProcessing/volumeIntegrate_volumeIntegral/"
    alpha0_path = "{}0/alpha2".format(alpha_path)
    dpath = os.path.join(fpath, alpha_path)
    
    times = os.listdir(dpath)
    if len(times) > 1:
        times_sorted = np.sort(times)
        a0 = np.loadtxt(alpha0_path)
        for time in times[1:]:
            index_of_next_time = np.argmin(np.abs(a0.T[0] - float(time)))
            alpha_next_time = np.loadtxt(os.path.join(alpha_path,time,"alpha2"))
            np.savetxt(alpha0_path,np.append(a0[:index_of_next_time],alpha_next_time,axis=0))
            
    
if __name__=="__main__":
    main()
