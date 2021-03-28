import os
import shutil
import sys
import numpy as np
import argparse

def path_is_num(path):
    '''
    Check whether path is timestep.
    Args:
        path: path to timesteps
    Returns:
        true if path is timestep
    '''
    if os.path.isdir(path):
        try:
            float(path)
        except ValueError: 
            return False
        else:
            return True
    return False

def time_is_num(num):
    try:
        float(num)
    except ValueError: 
        return False
    else:
        return True

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="path e.g. like \"processor0\"", type=str, required=True)
    parser.add_argument("-t", "--starttime", help="start time from where to delete times from. Must have same format as directory of that timestep", type=str, required=True)
    args = parser.parse_args()
    path2files = args.path
    start_time = args.starttime
    
    
    path = os.path.join(path2files,start_time)
    if not os.path.isdir(path):    
        print 'cannot open {}'.format(path)
        sys.exit()
        
    if not time_is_num(start_time):
        raise IOError ('start time is not a number')

    time_files = [i for i in os.listdir(path2files) if ( time_is_num(i) and float(i) > float(start_time) )]
    #time_steps = np.array(time_files).astype('float64')
    
    print "removing: {} from {} on".format(path2files,start_time)
    for item in [path2files + time for time in time_files]:
        shutil.rmtree( item )

if __name__ == "__main__":
    main()