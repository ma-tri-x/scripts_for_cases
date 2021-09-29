import os
import sys
import numpy as np
import argparse
import paraview.simple as pv
from shutil import copy2

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def get_timesteps(dpath):
    time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    return time_steps

def get_closest_timestep(time_steps, time):
    return time_steps[np.argmin(np.abs(time_steps - time))]

def find_biggest_timestep(time_steps):
    return np.max(time_steps)

def rescale_data_range(view):
    #lut =view.Representations[0].LookupTable
    #rgbpoints = lut.RGBPoints.GetData()
    #print(rgbpoints)
    #numpts = len(rgbpoints)/4
    #minvalue = min(minvalue, rgbpoints[0])
    #maxvalue = max(maxvalue, rgbpoints[(numpts-1)*4])
    #if minvalue != rgbpoints[0] or maxvalue != rgbpoints[(numpts-1)*4]:
        ## rescale all of the points
        ##print("this STEEEEEEEEEEP")
        #oldrange = rgbpoints[(numpts-1)*4] - rgbpoints[0]
        #newrange = maxvalue - minvalue
        #newrgbpoints = list(rgbpoints)
        #for v in range(numpts):
            #newrgbpoints[v*4] = minvalue+(rgbpoints[v*4] - rgbpoints[0])*newrange/oldrange
 
        #lut.RGBPoints.SetData(newrgbpoints)
    #print(lut.RGBPoints.GetData())
    for i in view.Representations[5:-1]:
        try:
            i.RescaleTransferFunctionToDataRange()
        except(AttributeError):
            pass

def render_timestep():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="path e.g. like \"processor0\"", type=str, required=True)
    parser.add_argument("-dt", "--delta_t", help="delta_t e.g. like 1e-6. If dt=0 then use all existent timesteps", type=float, required=True)
    parser.add_argument("-a", "--starttime", help="start time of the timesteps \
                        to be written (float)", type=float, required=False, default=0.0)
    parser.add_argument("-b", "--endtime", help="end time of the timesteps \
                        to be written (float)", type=float, required=True)
    parser.add_argument("-s", "--state_file", help="path to pvsm file", type=str, required=True)
    parser.add_argument("-o", "--outfiles", help="dest of output incl file string e.g.\
                        \"bla/blup\"", type=str, required=False, 
                        default="{}/test".format(this_path))
    parser.add_argument("-w", "--write_data_or_render", help="stl files or rendered images? \
                        \"d\" or \"r\"", type=str, required=True, choices=['d','r'])
    
    args = parser.parse_args()
    
    print("please MIND TO USE pvpython instead of python")
    
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.path)
    
    time_steps = get_timesteps(dpath)
    tmax = find_biggest_timestep(time_steps)
    
    case_name = fpath.split("/")[-1]
    keyword = case_name
    if args.write_data_or_render == 'd': keyword = "RotationalExtrusion1"
    
    if not os.path.isfile(args.state_file):
        print("error: state file does not exist")
        exit(1)
        
    try:
        copy2("{}.backup".format(args.state_file),args.state_file)
    except:
        print("no state file backup found")
        
    check_template_state = False
    with open(args.state_file,'r') as i:
        lines = i.readlines()
    for line in lines:
        if "TEMPLATE" in line: check_template_state = True
    
    if not check_template_state:
        print("The state file is not a template file.\
            Please edit and replace directory with \"TEMPLATEDIR\".\
            and the name with \"TEMPLATENAME\"")
        exit(1)
            
    with open(args.state_file,'w') as o:
        for line in lines: 
            l = line.replace("TEMPLATENAME",case_name)
            l = l.replace("TEMPLATEDIR",os.path.join(this_path,case_name + ".foam"))
            o.write(l)
        
    print("Loading state file...")
    pv.LoadState(args.state_file)
    sources = pv.GetSources()
    print(keyword)
    source_key = ""
    source_key2 = ""
    for item in sources:
        print(item)
        if case_name in item[0]:
            print("success finding case_name in pvsm file")
            source_key = item
        if keyword in item[0]:
            print("success finding keyword in pvsm file")
            source_key2 = item
    reader = sources[source_key]
    try:
        reader2 = sources[source_key2]
    except(KeyError):
        try:
            keyword = "Transform1"
            for item in sources:
                if keyword in item[0]:
                    print("success finding keyword in pvsm file")
                    source_key2 = item
            reader2 = sources[source_key2]
        except(KeyError):
            print("ERROR: couldn't find second source_key (try naming it either \
                   Transform1 or RotationalExtrusion1)")
            exit(1)
        
    
    times = reader.TimestepValues
    ta = args.starttime
    tb = args.endtime
    t = get_closest_timestep(time_steps,ta)
    tsi = 0
    if args.delta_t > 0.0:
        while t<tb and t<tmax:
            view = pv.GetActiveView()
            view.UseOffscreenRendering = 1
            view.Background = [1,1,1]  ##set the background color white
            view.ViewTime = get_closest_timestep(time_steps,t) #times[n]
            print("timestep, used time:{}    {}".format(t,view.ViewTime))
            if args.write_data_or_render == 'r':
                #pv.Render()
                view.StillRender()
                #save screenshot
                pv.WriteImage("{}{}.png".format(args.outfiles,tsi))
                os.system("convert -trim {}{}.png {}{}.png".format(args.outfiles,tsi,args.outfiles,tsi))
            else:
                #view = pv.GetActiveView()
                #view.ViewTime = get_closest_timestep(time_steps,t) #times[n]
                #print tsi
                #writer = pv.CreateWriter("{}{}.stl".format(args.outfiles,tsi), reader2)
                writer = pv.PSTLWriter(FileName="{}{}.stl".format(os.path.join(this_path,args.outfiles),tsi), Input=reader2)
                writer.WriteAllTimeSteps = 0
                #writer.FieldAssociation = "Points" # or "Cells"
                writer.UpdatePipeline(t)
                del writer
            t += args.delta_t
            tsi += 1
    else:
        if args.starttime == 0.0: t_idx = 0
        else: t_idx = list(times).index(t)
        while t<tb and t<tmax:
            view = pv.GetActiveView()
            view.UseOffscreenRendering = 1
            view.Background = [1,1,1]  ##set the background color white
            view.ViewTime = times[t_idx]
            print("timestep, used time:{}    {}".format(t,view.ViewTime))
            if args.write_data_or_render == 'r':
                #pv.Render()
                view.StillRender()
                reader.UpdatePipeline()
                rescale_data_range(view)
                #save screenshot
                pv.WriteImage("{}{}.png".format(args.outfiles,str(t_idx).zfill(4)))
                os.system("convert -trim {}{}.png {}{}.png".format(args.outfiles,str(t_idx).zfill(4),args.outfiles,str(t_idx).zfill(4)))
                #if t_idx ==2: exit(0)
            else:
                #view = pv.GetActiveView()
                #view.ViewTime = get_closest_timestep(time_steps,t) #times[n]
                #print tsi
                #writer = pv.CreateWriter("{}{}.stl".format(args.outfiles,tsi), reader2)
                writer = pv.PSTLWriter(FileName="{}.{}..stl".format(os.path.join(this_path,args.outfiles),t_idx), Input=reader2)
                writer.WriteAllTimeSteps = 0
                #writer.FieldAssociation = "Points" # or "Cells"
                writer.UpdatePipeline(t)
                del writer
            t_idx +=1
            t = times[t_idx]


def main():
    render_timestep()

if __name__ == "__main__":
    main()
