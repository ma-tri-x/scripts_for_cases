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
    parser.add_argument("-c", "--column", help="which column of the set to merge?", type=int, required=True)
    parser.add_argument("-f", "--field", help="name of the field (e.g. rho or p)", type=str, required=True)
    #try:
        #time = float(sys.argv[1])
    #except(ValueError):
        #print("first argument must be time")
        #exit(1)
        
    #time = sys.argv[1]
    
    args = parser.parse_args()
    timepath = "processor0"
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, timepath)
    
    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    
    times = np.sort(time_steps)
    
    alltimes=[]
    timedir0 = "postProcessing/sets/0"
    l = glob.glob(os.path.join(timedir0,"data*.xy"))
    timefile0 = l[0]
    a = np.loadtxt(timefile0)
    location = a.T[0]
    
    for time in times:
        print(time)
        timedir = os.path.join("postProcessing/sets/",str(time))
        try:
            l = glob.glob(os.path.join(timedir,"data*.xy"))
            timefile = l[0]
            a = np.loadtxt(timefile)
            if len(a[0]) > args.column + 1:
                print ("ERROR: column {} is not available in {}".format(args.column,timefile))
                exit(1)
            thearray = a.T[args.column]
            thetime = (np.zeros(len(thearray)) + 1.0)*time
            alltimes.extend([" "," "," "])
            alltimes.extend(np.array([thetime,location,thearray]).T)
        except(IndexError):
            print("found no data for {}".format(time))
        except(IOError):
            print("no data sampled for {}".format(time))
        
    with open("DATA_of_alltimes_{}.dat".format(args.field),"w") as f:
        for line in alltimes:
            temp_str = "{}".format(line[0])
            for i in line[1:]:
                temp_str = "{}    {}".format(temp_str,i)
            f.write(temp_str)
            f.write("\n")
    #np.savetxt()
    
if __name__=="__main__":
    main()
