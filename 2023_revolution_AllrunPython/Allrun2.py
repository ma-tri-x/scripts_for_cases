#!/bin/python

import os, sys, argparse, glob, time,json,shutil
import numpy as np
import OFAllFunctionLibrary as OAFL
import subprocess
from meshespython import *

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def find_biggest_number():
    dpath = "processor0"
    time_files = [i for i in os.listdir(dpath) if path_is_num(i)]  
    time_steps = np.array([float(i) for i in time_files])
    #biggest_number = np.max(time_steps)
    index = np.argmax(time_steps)
    return time_files[index]

def main():
    """
    changed library so that Case and Mesh are independent and point(!)
    to the dictionary "conf_dict" loaded HERE in Allrun.py. So conf_dict can be prepared here:
    preparation:
    """
    conf_dict = {}
    with open("conf_dict.json","r") as f:
        conf_dict = json.load(f)
        
    """
    now setting up the case and mesh with the prepared conf_dict
    """
    case = OAFL.Case(conf_dict)

    dinit_avg = 0.5*(case.conf_dict["bubble"]["D_init"] + case.conf_dict["secondBubble"]["D_init"])
    
    print("remember: bubbleOne needs to sit in the positive PassiveScalar region!")
    print("remember: bubbleTwo needs to sit in the negative PassiveScalar region!")
    
    case.set_alpha_field_secondBubble_PS_range_PARALLEL_LATESTTIME(passiveScalar_range=[-10.0, 0.0],D_init=case.conf_dict["secondBubble"]["D_init"],R0=case.conf_dict["secondBubble"]["Rstart"])
    
    R02,Rn2,pBubble2 = case.get_correct_R0_Rn_pBubble_by_fitfunction_and_PS_PARALLEL_LATESTTIME(passiveScalar_range=[-10.0,0.0],outfilename="0/get_alpha2_vol_t0_bubble2",
                                                                         Rmax=case.conf_dict["secondBubble"]["Rmax"])
    
    case.write_Rn_and_aimedRn_to_OFdictionary(Rn2,dictionary="constant/BubblesProperties",
                                             replaceable_string_Rn="_OFALLFUNC-SECONDBUBBLERN",
                                             replaceable_string_aimedRn="_OFALLFUNC-SECONDBUBBLEAIMEDRN")
    
    case.set_bubble_pressure_PS_range_PARALLEL_LATESTTIME(passiveScalar_range=[-10.0,0.0],pBubble=pBubble2)
    # secondBubble will be put at maximum extension of first bubble in Allrun2.py
    
    #Tc1 = 0.91468*case.conf_dict["bubble"]["Rmax"]*np.sqrt(998./(case.pInf-case.pV))
    #Tc2 = 0.91468*case.conf_dict["secondBubble"]["Rmax"]*np.sqrt(998./(case.pInf-case.pV))
    
    case.replace_end_time_in_controlDict(120e-6)
    case.replace_direct_variable_in_OF_system_dict("system/controlDict","startFrom","latestTime")
    
    print("backing up post-processing files...")
    pp_list = glob.glob("postProcessing*")
    i = str(len(pp_list)).zfill(2)
    os.system(f"cp -r postProcessing postProcessing{i}")
    os.system(f"cp -r processor0/CoNum.dat processor0/CoNum.{i}.dat")
    
    print("modifying the stored deltaT...")
    latestTime = find_biggest_number()
    proc_list = glob.glob("processor*")
    for proc_dir in proc_list:
        stored_time_file = f"{proc_dir}/{latestTime}/uniform/time"
        if not os.path.isfile(f"{stored_time_file}_backup.gz"):
            shutil.copy2(f"{stored_time_file}.gz",f"{stored_time_file}_backup.gz")
        os.system(f"gunzip {stored_time_file}.gz")
        case.replace_direct_variable_in_OF_system_dict(stored_time_file,"deltaT",1e-11)
        case.replace_direct_variable_in_OF_system_dict(stored_time_file,"deltaT0",1e-11)
        os.system(f"gzip {stored_time_file}")
    
    #case.decompose()
    
    print("run now with localMassCorr_doubleBubble:")
    threads = case.conf_dict["decompose"]["threads"]
    print(f"mpirun -np {threads} localMassCorr_doubleBubble -parallel > run2.log 2>&1 &")

if __name__=="__main__":
    main()
