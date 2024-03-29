import os
import sys
import numpy as np
import argparse

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
    parser.add_argument("-p", "--path", help="path e.g. like \"processor0\"", type=str, required=True)
    args = parser.parse_args()
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.path)

    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.sort(np.array([float(i.split('/')[-1]) for i in time_files]))
    
    #print (len(time_steps))
    with open("modes.txt", 'r') as f:
        with open("modes2.txt","w") as g:
            for i,row in enumerate(f):
                try:
                    g.write(str(time_steps[i])+" "+str(row))
                except(IndexError):
                    print("wrote modes of {} with {} timesteps".format(dpath,i))
                    exit(0)
            

if __name__ == "__main__":
    main()
