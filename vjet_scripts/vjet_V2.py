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
    try:
        pxm = servermanager.ProxyManager()
        pxm.UnRegisterProxies()
        del pxm
        Disconnect()
    except(AttributeError):
        pass

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

def prepare_render_timestep(fpath,cylinder_top_y_coord):
    #this_path = fpath #os.path.dirname(os.path.abspath( __file__ ))
    state_file = os.path.join(fpath, "states/vjet_analysis.pvsm")
    state_file_backup = os.path.join(fpath, "states/vjet_analysis.pvsm.backup")
    case_name = fpath.split("/")[-1]
    keyword = "Clip3"
    if not os.path.isfile(state_file_backup):
        print("error: {} file does not exist".format(state_file_backup))
        exit(1)
        
    copy2(state_file_backup,state_file)
        
    check_template_state = False
    try:
        with open(state_file,'r') as i:
            lines = i.readlines()
    except(UnicodeDecodeError):
        print("Somehow {} could not be loaded!".format(state_file))
        exit(1)
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
            l = l.replace("TEMPLATEYCUT",str(1.1*cylinder_top_y_coord))
            o.write(l)
        
    print("Loading state file...")
    servermanager.LoadState(state_file)
    sources = GetSources()
    #print(keyword)
    source_key = ""
    for item in sources:
        #print(item)
        if keyword in item[0]:
            #print("success finding {} in pvsm file".format(keyword))
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
    
def render_timestep(fpath,tw,reader,fname,time_steps):
    dpath = os.path.join(fpath, "processor0")
    #time_steps = get_timesteps(dpath)
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
    
def traverse_timesteps(path,U_arr,i,reader,time_steps,msg="formation"):
    comm = ""
    off = 0
    taken_time = 0.
    is_jet = True
    skip = False
    while not comm == "q" and not comm == "s" and not comm == "n":
        idx = i+off
        if i+off < 0: idx = 0
        elif i+off > len(U_arr) -1: idx = len(U_arr) -1
        tw = U_arr[idx][0]
        fname = "jet_{}.png".format(msg)
        taken_time = render_timestep(path,tw,reader,fname,time_steps)
        comm = input("Type in, how many steps to go left (e.g. -50) or right (e.g. 40)\nin time until meeting the instant of jet {}.\n(exit type q, skip type s, if there is no jet, type n): ".format(msg))
        try:
            off = int(comm)
        except(ValueError):
            if comm == "n": is_jet = False
            elif comm == "s": skip = True
            else: comm = "q"
    i = np.argmin(np.abs(U_arr.T[0] - taken_time))
    return i,taken_time,is_jet,skip

def scan_for_jet_type(path,U_arr,i,reader,time_steps,msg="type"):
    comm = ""
    off = 0
    taken_time = 0.
    is_jet = True
    skip = False
    is_fast = True
    while not comm == "f" and not comm == "s" and not comm == "n" and not comm == "sk":
        idx = i+off
        if i+off < 0: idx = 0
        elif i+off > len(U_arr) -1: idx = len(U_arr) -1
        tw = U_arr[idx][0]
        fname = "jet_{}.png".format(msg)
        taken_time = render_timestep(path,tw,reader,fname,time_steps)
        comm = input("Type in, how many steps to go left (e.g. -50) or right (e.g. 40)\nin time. WHAT TYPE OF JET? {}.\n(fast jet f, slow jet s, if there is no jet, type n, to skip type sk): ".format(msg))
        try:
            off = int(comm)
        except(ValueError):
            if comm == "n": is_jet = False
            elif comm == "sk": skip = True
            elif comm == "f": is_fast = True
            elif comm == "s": is_fast = False
    #i = np.argmin(np.abs(U_arr.T[0] - taken_time))
    return is_jet,skip,is_fast

def get_left_ts_fastjet(U_arr):
    i=0
    while U_arr[i][0] < 10e-6:
        i=i+1
    while i < len(U_arr) - 1 and U_arr[i][1] > -500.:
        i = i + 1
    i=i-10
    return i

def get_right_ts_fastjet(i,U_arr,minU_pos_arr,cylinder_top_y_coord):
    ycoord = 1000.
    passed_thres = False
    thres=-500.
    j = i
    while ycoord > cylinder_top_y_coord + 3e-6 and j < len(U_arr) - 1  and not (passed_thres == True and U_arr[j][1] > thres):
        if U_arr[j][1] < thres-50.: passed_thres = True
        ycoord = minU_pos_arr[j][1]
        j = j + 1
    return j

def _write_dat_file(path,Rn,dinit,vjet,vjet_absmax,distance,taken_time,taken_time2, interval, standard_or_fast):
    with open("{}.dat".format(path),'w') as out:
        out.write("#Rn    dinit    vjet_byDef    v_minmin    dist_from_solid_formation    interval_t1   t2  dt\n")
        out.write("{}    {}    {}    {}    {}    {}    {}    {}    {}\n".format(Rn,
                                                                          dinit,
                                                                          np.abs(vjet),
                                                                          np.abs(vjet_absmax),
                                                                          distance,
                                                                          taken_time,
                                                                          taken_time2, 
                                                                          interval,
                                                                          standard_or_fast)
        )

def plot_and_save_jet(path,
                      is_jet,
                      is_fast,
                      time_steps,
                      vjet_absmax,
                      U_arr,
                      minU_pos_arr,
                      minAlpha1_pos_arr,
                      i,
                      taken_time,
                      cylinder_top_y_coord,
                      j,
                      taken_time2):
    standard_or_fast = "1"
    if not is_fast: standard_or_fast = "0"
    Rn = getparm(path,"bubble","Rn")
    dinit = getparm(path,"bubble","D_init")
    if is_jet:
        if is_fast:
            impact_pos = _get_minAlpha1_pos(path,minAlpha1_pos_arr,time_steps,taken_time2)
            distance = minU_pos_arr.T[1][i] - impact_pos
            interval = taken_time2 -taken_time
            vjet = distance / interval
        else:
            vjet = U_arr[i][1]
            impact_pos = _get_minAlpha1_pos(path,minAlpha1_pos_arr,time_steps,taken_time)
        
        if is_fast:
            plt.plot(U_arr.T[0][i:j],U_arr.T[1][i:j])
            plt.plot([U_arr[i][0],U_arr[j][0]],[-vjet,-vjet])
            print("{} = vjet, dt = {}, dist = {}".format(np.abs(vjet),interval,distance))
        else:
            span=1000
            plt.plot(U_arr.T[0][i-span:i+span],U_arr.T[1][i-span:i+span])
            plt.plot([U_arr[i-span][0],U_arr[i+span][0]],[vjet,vjet])
            print("{} = vjet, dist = {}".format(np.abs(vjet),impact_pos))
        
        plt.savefig("{}.pdf".format(path))
        plt.show()
        
        if is_fast:
            _write_dat_file(path,Rn,dinit,vjet,vjet_absmax,distance,taken_time,taken_time2, interval, standard_or_fast)
        else:
            _write_dat_file(path,Rn,dinit,vjet,vjet_absmax,impact_pos,taken_time,taken_time, 0., standard_or_fast)
    else:
        distance = minU_pos_arr.T[1][i] - cylinder_top_y_coord
        vjet=0.
        _write_dat_file(path,Rn,dinit,vjet,vjet_absmax,distance,taken_time,taken_time, 0., standard_or_fast)
        
def get_ts_slow_jet(U_arr):
    index_of_max_jet_vel = np.argmin(U_arr.T[1])
    return index_of_max_jet_vel

def _get_minAlpha1_pos(path,minAlpha1_pos_arr,time_steps,taken_time):
    impact_time_idx = np.argmin(np.abs(time_steps - taken_time))
    impact_pos = minAlpha1_pos_arr[impact_time_idx]
    dinit = getparm(path,"bubble","D_init")
    if impact_pos < -dinit: impact_pos = -dinit
    print("impact time: {}  impact pos: {}".format(taken_time,impact_pos))
    return impact_pos

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    print(this_path)
    
    path = sys.argv[1]
    
    postpr_U_path = "postProcessing/swakExpression_extremeUy/0/extremeUy"
    postpr_minU_pos_path = "postProcessing/swakExpression_minUyPosition/0/minUyPosition"
    minAlpha1_path = "processor0/bubble_y_distance_min.dat"
    
    if not os.path.isdir(path):
        print("ERROR: path not existing")
        exit(1)
    
    if not os.path.isfile(os.path.join(path,"processor0/bubble_y_distance_min.dat")):
        print("ERROR: processor0/bubble_y_distance_min.dat not existing.\nPlease first execute get_all_bubble_y_distances.sh!")
        exit(1)

    U_arr = np.loadtxt(os.path.join(path,postpr_U_path),usecols=[0,1])
    minU_pos_arr = np.loadtxt(os.path.join(path,postpr_minU_pos_path),usecols=[0,2])
    dinit = getparm(path,"bubble","D_init")
    # "- dinit" is necessary bec the utility transforms coordinates to
    # ypos = 0 for solid boundary if solid boundary is in x<80e-6 !
    minAlpha1_pos_arr = np.loadtxt(os.path.join(path,minAlpha1_path)) - dinit
    time_steps = np.sort(get_timesteps(os.path.join(path,"processor0")))
    #minAlpha1_plus_time_arr = np.array([time_steps,minAlpha1_pos_arr]).T
    #np.savetxt(os.path.join(path,"minAlpha1.dat"),minAlpha1_plus_time_arr)
    #exit(0)
    if not len(minAlpha1_pos_arr) == len(time_steps):
        print("ERROR: len(minAlpha1_pos_arr) != len(time_steps)!")
        exit(1)
    
    vjet_absmax = np.min(U_arr.T[1])
    cylinder_top_y_coord = np.min(minU_pos_arr.T[1])
    
    KillSession()
    Connect()
    reader = prepare_render_timestep(path,cylinder_top_y_coord)
    
    if not os.path.isfile("{}.dat".format(path)):
        is_jet, skip, is_fast = scan_for_jet_type(path,U_arr,5000,reader,time_steps,msg="type")
        if is_jet and is_fast and not skip:
            #KillSession()
            #Connect()
            print("-------------- {}".format(path))
            
            i = get_left_ts_fastjet(U_arr)
            
            #reader = prepare_render_timestep(path,cylinder_top_y_coord)
            
            i,taken_time,is_jet,skip = traverse_timesteps(path,U_arr,i,reader,time_steps,msg="formation")
            
            j = get_right_ts_fastjet(i,U_arr,minU_pos_arr,cylinder_top_y_coord)
                
            j,taken_time2,is_jet,skip = traverse_timesteps(path,U_arr,j,reader,time_steps,msg="impact")
            
            del reader
            KillSession()
            
            plot_and_save_jet(path,
                                is_jet,
                                is_fast,
                                time_steps,
                                vjet_absmax,
                                U_arr,
                                minU_pos_arr,
                                minAlpha1_pos_arr,
                                i,
                                taken_time,
                                cylinder_top_y_coord,
                                j,
                                taken_time2)
        elif is_jet and not is_fast and not skip:
            #KillSession()
            #Connect()
            print("-------------- {}".format(path))
            print("-------------- slow jet1")
            print("-------------- slow jet2")
            print("-------------- slow jet3!")
            
            i = get_ts_slow_jet(U_arr)
            #reader = prepare_render_timestep(path,cylinder_top_y_coord)
            
            i,taken_time,is_jet,skip = traverse_timesteps(path,U_arr,i,reader,time_steps,msg="impact")
            
            del reader
            KillSession()
            
            plot_and_save_jet(path,
                              is_jet,
                              is_fast,
                              time_steps,
                              vjet_absmax,
                              U_arr,
                              minU_pos_arr,
                              minAlpha1_pos_arr,
                              i,
                              taken_time,
                              cylinder_top_y_coord,
                              i,
                              taken_time)
        else:
            del reader
            KillSession()
    
    #if reader:
        #del reader
        #KillSession()
                
if __name__=="__main__":
    main()
