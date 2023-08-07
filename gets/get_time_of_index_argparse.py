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
    parser.add_argument("-i", "--index", help="time index", type=int, required=True)
    parser.add_argument("-c", "--casedir", help="directory of case", type=str, required=False, default=".")
    
    args = parser.parse_args()
        
    index = args.index
    
    timepath = "processor0"
    fpath = os.path.abspath(".") #os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.casedir, timepath)
    
    time_files = [ i for i in os.listdir(dpath) if path_is_num(i)]  
    time_files_float = [ float(i) for i in time_files]  
    time_steps = np.array(time_files_float)
    
    times = np.sort(time_steps)
    
    time = times[index]
    
    index01 = np.argmin(np.abs((time_files_float) -time))
    
    print(time_files[index01])
    
if __name__=="__main__":
    main()
