#!/bin/python
import os, sys, argparse, glob, time, json
import numpy as np
import scipy.integrate as integrate
from shutil import copy2

import matplotlib.pyplot as plt
from paraview.simple import *
#paraview.simple._DisableFirstRenderCameraReset()
#_DisableFirstRenderCameraReset()

from vtkmodules.vtkCommonCore import vtkLogger

vtkLogger.SetStderrVerbosity(vtkLogger.VERBOSITY_OFF)

def getparm(path,subdict,query):
    try:
        with open(os.path.join(path,"conf_dict.json"),'r') as f:
            conf_dict = json.load(f)
    except(ValueError,IOError):
        return "nan"
        
    if subdict:
        return conf_dict[subdict][query]
    else:
        return conf_dict[query]

def KillSession():
    pxm = servermanager.ProxyManager()
    pxm.UnRegisterProxies()
    del pxm
    Disconnect()

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

def prepare_render_timestep(fpath):
    #this_path = fpath #os.path.dirname(os.path.abspath( __file__ ))
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
            l = l.replace("TEMPLATEDIR",os.path.join(fpath,case_name + ".foam"))
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
    
    return reader
    
def render_timestep(fpath,tw,reader,fname):
    dpath = os.path.join(fpath, "processor0")
    time_steps = get_timesteps(dpath)
    t = get_closest_timestep(time_steps,tw)
    print(t)
    SetActiveView(GetRenderView())
    ResetCamera()
    view = GetActiveView()
    view.ViewTime = t
    Render()
    SaveScreenshot(os.path.join(fpath,"contour/{}".format(fname)))
    #print(view)
    #Render()
    #print(reader.TimestepValues)
    #exit(0)
    #view.UseOffscreenRendering = 1
    #view.Background = [1,1,1]  ##set the background color white
    #writer = DataSetCSVWriter(FileName=os.path.join(fpath,"contour/bla.csv"),  Input=reader)
    #writer.WriteAllTimeSteps = 0
    #writer.TimePrecision = 10
    #writer.UseScientificNotation = 10
    #writer.FieldAssociation = "Points" # or "Cells"
    #writer.UpdatePipeline(t) 
    #del writer
    del view
    return t

def get_slope(arr,i):
    slope = (arr[i+1][1]-arr[i][1])/(arr[i+1][0]-arr[i][0])
    if arr[i][0] < 2e-6:
        return 0.
    else:
        return slope

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    print(this_path)
    #parser = argparse.ArgumentParser()
    #parser.add_argument("-a", "--argument", help="some required string", type=str, required=True)
    #parser.add_argument("-b", "--secondarg", help="some default float", type=float, required=False, default=1.5)

    #args = parser.parse_args()
    
    path_glob = sys.argv[1]
    pathes = glob.glob(path_glob)
    for path in pathes:
        if not os.path.isdir(path):
            print("ERROR: path not existing")
            exit(1)
        
        postpr_U_path = "postProcessing/swakExpression_extremeUy/0/extremeUy"
        postpr_minU_pos_path = "postProcessing/swakExpression_minUyPosition/0/minUyPosition"

        U_arr = np.loadtxt(os.path.join(path,postpr_U_path),usecols=[0,1])
        minU_pos_arr = np.loadtxt(os.path.join(path,postpr_minU_pos_path),usecols=[0,2])
        
        vjet_absmax = np.min(U_arr.T[1])
        cylinder_top_y_coord = np.min(minU_pos_arr.T[1])
        
        if vjet_absmax < -500.:
            i=0
            #slope=0.
            #while i < len(U_arr) - 1 and np.abs(slope) < 100./40e-9:
                #slope = get_slope(U_arr,i)
                #i = i + 1
            slope=0.
            while i < len(U_arr) - 1 and U_arr[i][1] > -500.:
                i = i + 1
            i=i-10
            
            comm = ""
            off = 0
            taken_time = 0.
            reader = prepare_render_timestep(path)
            while not comm == "q":
                tw = U_arr[i+off][0]
                taken_time = render_timestep(path,tw,reader,"jet_formation.png")
                comm = input("Type in, how many steps to go left (e.g. -5) or right (e.g. 4) in time until meeting the instant of jet formation. (exit type q): ")
                try:
                    off = int(comm)
                except(ValueError):
                    comm = "q"
            i=i+off
            
            ###
                
            #minU = np.min(U_arr.T[1])
            ycoord = 1000.
            passed_thres = False
            thres=-500.
            j = i
            while ycoord > cylinder_top_y_coord + 3e-6 and j < len(U_arr) - 1  and not (passed_thres == True and U_arr[j][1] > thres):
                if U_arr[j][1] < thres-50.: passed_thres = True
                ycoord = minU_pos_arr[j][1]
                j = j + 1
                
            comm = ""
            off = 0
            taken_time2 = 0.
            while not comm == "q":
                tw = U_arr[j+off][0]
                taken_time2 =           render_timestep(path,tw,reader,"jet_impact.png")
                comm = input("Type in, how many steps to go left (e.g. -50) or right (e.g. 400) in time until meeting the instant of jet impact. (exit type q): ")
                try:
                    off = int(comm)
                except(ValueError):
                    comm = "q"
            j=j+off
            
            ###
            
            del reader
            KillSession()
            
            plt.plot(U_arr.T[0][i:j],U_arr.T[1][i:j])
            #plt.plot(minU_pos_arr.T[0][i:j],minU_pos_arr.T[1][i:j])
            interval = taken_time2 -taken_time
            #vjet = np.trapz(x=U_arr.T[0][i:j], y=U_arr.T[1][i:j])/interval
            distance = minU_pos_arr.T[1][i] - cylinder_top_y_coord
            vjet = distance / interval
            plt.plot([U_arr[i][0],U_arr[j][0]],[-vjet,-vjet])
            print("{} = vjet, dt = {}, dist = {}".format(vjet,interval,distance))
            plt.savefig("{}.pdf".format(path))
            plt.show()
            Rn = getparm(path,"bubble","Rn")
            dinit = getparm(path,"bubble","D_init")
            with open("{}.dat".format(path),'w') as out:
                out.write("#Rn    dinit    vjet_byDef    v_minmin                     dist_from_solid_formation    interval_t1   t2  dt\n")
                out.write("{}    {}    {}    {}    {}    {}    {}    {}\n".format(Rn,dinit,vjet,vjet_absmax,distance,taken_time,taken_time2, interval))
        else:
            print("-------------- slow jet1")
            print("-------------- slow jet2")
            print("-------------- slow jet3!")
            index_of_max_jet_vel = np.argmin(U_arr.T[1])
            i = index_of_max_jet_vel
            comm = ""
            is_jet = True
            off = 0
            taken_time = 0.
            reader = prepare_render_timestep(path)
            while not comm == "q":
                tw = U_arr[i+off][0]
                taken_time = render_timestep(path,tw,reader,"jet_impact.png")
                comm = input("Type in, how many steps to go left (e.g. -5) or right (e.g. 4) in time until meeting the instant of jet impact. (exit type q -- no jet type n): ")
                try:
                    off = int(comm)
                except(ValueError):
                    if comm == "n": is_jet = False
                    comm = "q"
            i = np.argmin(np.abs(U_arr.T[0] - taken_time))
            del reader
            KillSession()
            
            
            plt.plot(U_arr.T[0][i-200:i+200],U_arr.T[1][i-200:i+200])
            vjet = U_arr[i][1]
            distance = minU_pos_arr.T[1][i] - cylinder_top_y_coord
            plt.plot([U_arr[i-200][0],U_arr[i+200][0]],[vjet,vjet])
            print("{} = vjet, dist = {}".format(vjet,distance))
            plt.savefig("{}.pdf".format(path))
            plt.show()
            Rn = getparm(path,"bubble","Rn")
            dinit = getparm(path,"bubble","D_init")
            if not is_jet: vjet = 0
            with open("{}.dat".format(path),'w') as out:
                out.write("#Rn    dinit    vjet_byDef    v_minmin                     dist_from_solid_formation   t_impact\n")
                out.write("{}    {}    {}    {}    {}    {}\n".format(Rn, dinit, np.abs(vjet), np.abs(vjet_absmax), distance, taken_time))

if __name__=="__main__":
    main()
