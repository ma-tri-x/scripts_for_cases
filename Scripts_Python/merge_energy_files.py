#!/bin/python

import os, sys, glob,json
import numpy as np

this_path = os.path.dirname(os.path.abspath( __file__ ))

def getparm(subdict,query,json_file=os.path.join(this_path,"conf_dict.json")):
    try:
        with open(json_file,'r') as f:
            conf_dict = json.load(f)
    except(ValueError,IOError):
        print "ERROR: parm not found"
        exit(1)
        
    if subdict:
        return conf_dict[subdict][query]
    else:
        return conf_dict[query]

def radius(al):
    Rs = (vol_convert(al.T[1])*3./4./np.pi)**(1./3.)
    return Rs

def get_time_of_Rn(al):
    Rn = getparm("bubble","Rn")
    Rs = radius(al)
    index = np.argmin(np.abs(Rs-Rn))
    timeOfRn = Rs[index]
    return index,timeOfRn

def vol_convert(energy):
    dims = getparm("mesh","meshDims")
    conv_fact = 1.0
    theta = 0.
    with open(os.path.join(this_path,"THETA"),'r') as g:
        t=g.readlines()
    theta = float(t[0].split('\n')[0])
    if dims == "1D":
        conv_fact = np.pi/np.tan(theta/180.*np.pi)**2
    if dims == "2D":
        conv_fact = 180./theta
    return conv_fact*energy

def PotEn(al,pg):
    V = vol_convert(al.T[1])
    V0= V[0]
    pstat = getparm("liquid","pInf")
    dV = []
    pdV = 0.0
    int_pdV = []
    for i,entry in enumerate(V):
        if i == 0: dV.append(0.0)
        else:
            dV.append(entry-V[i-1])
        pdV = pg[i][1]*dV[i]
        if i == 0: int_pdV.append(0.0)
        else: int_pdV.append(int_pdV[-1]+pdV)
    
    indexRn,timeRn = get_time_of_Rn(al)
    constant = int_pdV[indexRn]
    potEn = -1*np.array(int_pdV) + constant + pstat*(V-V0)
    Etot = potEn[0]
    if not len(potEn) == len(al.T[0]):
        print("coding error: len(potEn)={} len(al.T[0])={}".format(len(potEn),len(al.T[0])))
        exit(1)
    return potEn,Etot
    
    

def main():
    
    postProcessPath = os.path.join(this_path,"postProcessing/volumeIntegrate_volumeIntegral/0/")
    alpha2File = os.path.join(postProcessPath, "alpha2")
    AcousticEnergyFile = os.path.join(postProcessPath, "AcousticEnergy")
    AcousticEnergyGasFile = os.path.join(postProcessPath, "AcousticEnergyGas")
    KineticEnergyFile = os.path.join(postProcessPath, "KineticEnergy")
    PotentialEnergyFile = os.path.join(postProcessPath, "PotentialEnergy")
    
    workingPath=this_path
    if os.path.isdir(os.path.join(this_path,"processor0")): 
        workingPath = os.path.join(this_path,"processor0")
    AvgPgFile = os.path.join(workingPath, "avg_pg.dat")
    
    al = np.loadtxt(alpha2File)
    Ac = np.loadtxt(AcousticEnergyFile)
    AcG= np.loadtxt(AcousticEnergyGasFile)
    Ki = np.loadtxt(KineticEnergyFile)
    pg = np.loadtxt(AvgPgFile)
    
    alTime = al.T[0]
    AcTime = Ac.T[0]
    AcGTime= AcG.T[0]
    KiTime = Ki.T[0]
    pgTime = pg.T[0]
    
    if AcTime.all() == KiTime.all() \
       and AcTime.all() == alTime.all() \
       and AcTime.all() == AcGTime.all() \
       and AcTime.all() == pgTime.all():
        potEn,Etot = PotEn(al,pg)
        radii = radius(al)
        AC = vol_convert(Ac.T[1]) 
        ACG= vol_convert(AcG.T[1])
        KI = vol_convert(Ki.T[1]) 
        PG = vol_convert(pg.T[1]) 
        with open(os.path.join(this_path,"Etot"),"w") as f:
            f.write("{}".format(Etot))
        with open(os.path.join(postProcessPath,"Energies"),"w") as f:
            f.write("#time[mus]\t alpha2\t radius\t AcEnergy\t AcGasEnergy\t KinEnergy\t PotEnergy\n")
            for i,t in enumerate(AcTime):
                totEn = AC[i]+ACG[i]+KI[i]+potEn[i]
                f.write("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format(t*1e6,al[i][1],radii[i],AC[i],ACG[i],KI[i],potEn[i],totEn))
    else:
        print("ERROR: times didn\'t match")
        exit(1)
    
if __name__=="__main__":
    main()
