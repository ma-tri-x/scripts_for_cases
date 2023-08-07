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
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--time", help="time", type=float, required=True)
    parser.add_argument("-c", "--casedir", help="directory of case", type=str, required=False, default=".")
    
    args = parser.parse_args()
        
    time = args.time
    
    timepath = "processor0"
    fpath = os.path.abspath(".") #os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.casedir, timepath)
    
    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    
    times = np.sort(time_steps)
    
    index = np.argmin(np.abs(times -time))
    
    if index == len(times)-1:
        index = index - 1
    
    print(index)
    
if __name__=="__main__":
    main()
