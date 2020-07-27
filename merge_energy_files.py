#!/bin/python

import os, sys, glob
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    postProcessPath = os.path.join(this_path,"postProcessing/volumeIntegrate_volumeIntegral/0/")
    AcousticEnergyFile = os.path.join(postProcessPath, "AcousticEnergy")
    KineticEnergyFile = os.path.join(postProcessPath, "KineticEnergy")
    
    Ac = np.loadtxt(AcousticEnergyFile)
    Ki = np.loadtxt(KineticEnergyFile)
    
    AcTime = Ac.T[0]
    KiTime = Ki.T[0]
    
    if AcTime.all() == KiTime.all():
        with open(os.path.join(postProcessPath,"Energies"),"w") as f:
            f.write("#time\t AcEnergy\t KinEnergy\n")
            for i,t in enumerate(AcTime):
                f.write("{}\t{}\t{}\n".format(t,Ac[i][1],Ki[i][1]))
    else:
        print("ERROR: times didn\'t match")
        exit(1)
    
if __name__=="__main__":
    main()
