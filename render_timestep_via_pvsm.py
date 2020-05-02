import os
import sys
import numpy as np
import argparse
import paraview.simple as pv

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def get_closest_timestep(dpath, time):

    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    
    return time_steps[np.argmin(np.abs(time_steps - time))]

def render_timestep():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="path e.g. like \"processor0\"", type=str, required=True)
    parser.add_argument("-dt", "--delta_t", help="delta_t e.g. like 1e-6", type=float, required=True)
    parser.add_argument("-n", "--number", help="how many timesteps should be written (int)", type=int, required=True)
    parser.add_argument("-s", "--state_file", help="path to pvsm file", type=str, required=True)
    parser.add_argument("-o", "--outfiles", help="dest of output incl file string e.g. \"bla/blup\"", type=str, required=False, default="test")
    args = parser.parse_args()
    
    
    if not os.path.isfile(args.state_file):
        print("error: state file does not exist")
        exit(1)
            
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.path)
    keyword = fpath.split("/")[-1]
    print("Loading state file...")
    pv.LoadState(args.state_file)
    sources = pv.GetSources()
    for item in sources:
        if keyword in item[0]:
            source_key = item
            break
    
    reader = sources[source_key]
    times = reader.TimestepValues
    
    for tsi in range(0,args.number):
        ts = float(tsi)*args.delta_t
        view = pv.GetActiveView()
        view.UseOffscreenRendering = 1
        view.Background = [1,1,1]  ##set the background color white
        view.ViewTime = get_closest_timestep(dpath,ts) #times[n]
        print("timestep, used time:{}    {}".format(ts,view.ViewTime))
        pv.Render()
        #save screenshot
        pv.WriteImage("{}{}.png".format(args.outfiles,tsi))
        os.system("convert -trim {}{}.png {}{}.png".format(args.outfiles,tsi,args.outfiles,tsi))

def main():
    render_timestep()

if __name__ == "__main__":
    main()