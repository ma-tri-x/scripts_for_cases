import os
import sys
import numpy as np
import argparse
import paraview.simple as pv
from shutil import copy2

#def path_is_num(path):
    #try:
        #float(path)
    #except ValueError: 
        #return False
    #else:
        #return True
    #return False

#def get_timesteps(dpath):
    #time_files = [os.path.join(dpath, i) for i in os.listdir(dpath) if path_is_num(i)]  
    #time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
    #return time_steps

#def get_closest_timestep(time_steps, time):
    #return time_steps[np.argmin(np.abs(time_steps - time))]

#def find_biggest_timestep(time_steps):
    #return np.max(time_steps)

def render_timestep():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, "processor0")
    state_file = os.path.join(fpath, "states/contour_export.pvsm")
    state_file_backup = os.path.join(fpath, "states/contour_export.pvsm.backup")
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
    pv.LoadState(state_file)
    sources = pv.GetSources()
    print keyword
    source_key = ""
    for item in sources:
        print item
        if keyword in item[0]:
            print "success finding {} in pvsm file".format(keyword)
            source_key = item
    try:
        reader = sources[source_key]
    except(KeyError):
            print("ERROR: couldn't find {} source key".format(keyword))
            exit(1)
    
    contour_path = os.path.join(fpath,"contour")
    if not os.path.isdir(contour_path):
        os.system("mkdir -p {}".format(contour_path))
    
    view = pv.GetActiveView()
    view.UseOffscreenRendering = 1
    writer = pv.DataSetCSVWriter(FileName="contour/bla.csv",  Input=reader)
    writer.WriteAllTimeSteps = 1
    #writer.TimePrecision = 10
    writer.UseScientificNotation = 10
    #writer.FieldAssociation = "Points" # or "Cells"
    writer.UpdatePipeline()
    del writer


def main():
    render_timestep()

if __name__ == "__main__":
    main()
