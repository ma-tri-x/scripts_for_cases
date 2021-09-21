import os
import sys
import numpy as np
import argparse
#import paraview.simple as pv
from paraview.simple import *
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

def render_timestep():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, "processor0")
    parser = argparse.ArgumentParser()
    parser.add_argument("-w", "--wantedtime", help="wanted time of the timesteps \
                        to be written (float)", type=float, required=True)
    args = parser.parse_args()
    
    tw = args.wantedtime
    
    time_steps = get_timesteps(dpath)
    
    state_file = os.path.join(fpath, "states/contour_export.pvsm")
    state_file_backup = os.path.join(fpath, "states/contour_export2.pvsm.backup")
    case_name = fpath.split("/")[-1]
    keyword = "PlotOnIntersectionCurves1"
    if not os.path.isfile(state_file_backup):
        print("error: states/contour_export.pvsm.backup file does not exist")
        exit(1)
        
    copy2(state_file_backup,state_file)
        
    check_template_state = False
    with open(state_file,'r') as i:
        lines = i.readlines()
    for line in lines:
        if "TEMPLATE" in line: check_template_state = True
    
    if not check_template_state:
        print("The state file is not a template file.\
            Please edit and replace directory with \"TEMPLATEDIR\".\
            and the name with \"TEMPLATENAME\"")
        exit(1)
            
    with open(state_file,'w') as o:
        for line in lines: 
            l = line.replace("TEMPLATENAME",case_name)
            l = l.replace("TEMPLATEDIR",os.path.join(this_path,case_name + ".foam"))
            o.write(l)
        
    print("Loading state file...")
    servermanager.LoadState(state_file)
    sources = GetSources()
    print(keyword)
    source_key = ""
    for item in sources:
        print(item)
        if keyword in item[0]:
            print("success finding {} in pvsm file".format(keyword))
            source_key = item
    try:
        reader = sources[source_key]
    except(KeyError):
            print("ERROR: couldn't find {} source key".format(keyword))
            exit(1)
    
    contour_path = os.path.join(fpath,"contour")
    if not os.path.isdir(contour_path):
        os.system("mkdir -p {}".format(contour_path))
    
    t = get_closest_timestep(time_steps,tw)
    SetActiveView(GetRenderView())
    view = GetActiveView()
    #print(view)
    #Render()
    #print(reader.TimestepValues)
    #exit(0)
    #view.UseOffscreenRendering = 1
    #view.Background = [1,1,1]  ##set the background color white
    writer = DataSetCSVWriter(FileName="contour/bla.csv",  Input=reader)
    view.ViewTime = get_closest_timestep(time_steps,t)
    #writer.WriteAllTimeSteps = 0
    #writer.TimePrecision = 10
    writer.UseScientificNotation = 10
    #writer.FieldAssociation = "Points" # or "Cells"
    writer.UpdatePipeline(t)
    del writer


def main():
    render_timestep()

if __name__ == "__main__":
    main()
