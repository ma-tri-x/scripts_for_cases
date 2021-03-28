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
    #parser = argparse.ArgumentParser()
    #parser.add_argument("-s", "--numstring", help="list string of time step numbers", type=str, required=True)
    try:
        time = float(sys.argv[1])
    except(ValueError):
        print("first argument must be time")
        exit(1)
        
    #time = sys.argv[1]
    
    #args = parser.parse_args()
    timepath = "processor0"
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, timepath)
    
    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    
    times = np.sort(time_steps)
    
    index = np.argmin(np.abs(times -time))
    
    if index == len(times)-1:
        index = index - 1
    
    print(index)
    
if __name__=="__main__":
    main()
