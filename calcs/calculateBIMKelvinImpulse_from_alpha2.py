#!/bin/python

import os
import sys
import numpy as np
import argparse
import matplotlib.pyplot as plt
import json

def func(R,theta_rad):
    return (R*3./(4.*theta_rad))**(1/3.)

def trapezoid(t,R,Rdot,k):
    return   (t[k+1]-t[k])*0.5*((R[k+1]**2*Rdot[k+1])**2+(R[k]**2*Rdot[k])**2)

def main():
    with open("conf_dict.json",'r') as d:
        the_dict = json.load(d)
    parser = argparse.ArgumentParser()
    parser.add_argument('-m','--method',help="which type of resolution(int)? 1 - deg90num; \
                        2 - cellsize and distance; \
                        3 - mesh core size and cellsize", \
                        choices=[1,2,3],type=int,required=True)
    args = parser.parse_args()

    pathalpha = "./postProcessing/volumeIntegrate_volumeIntegral/0/"
    
    theta = 0.
    if args.method == 1:
        deg90num = the_dict["mesh"]["numPer90deg"]
        theta = 90./deg90num/2./180.*np.pi
    elif args.method == 2:
        cellsize = the_dict["mesh"]["cellSize"]
        X = the_dict["mesh"]["FactorBubbleDomainRmax"] * the_dict["bubble"]["Rmax"]
        theta = np.arctan(0.5*cellsize/X)
    elif args.method == 3:
        cellsize = the_dict["mesh"]["cellSize"]
        Xi  = the_dict["mesh"]["meshCoreSize"]
        deg90num = 2.*Xi/cellsize
        theta = 90./deg90num/2./180.*np.pi
    else:
        print("no output written")
        exit(1)
        
    D_init = the_dict["bubble"]["D_init"]
    
    alpha2 = np.loadtxt(os.path.join(pathalpha,"alpha2"))
    t = alpha2.T[0]
    R = func(alpha2.T[1],theta)
    Rdot = np.array([ (R[i+1]-R[i])/(t[i+1]-t[i]) for i in np.arange(len(R)-1) ])
    
    fig, ax1 = plt.subplots()
    ax1.plot(t,R)
    ax2 = ax1.twinx()
    #plt.plot(t[:len(Rdot)],Rdot)
    prefac = -998./(16.*np.pi*D_init**2)
    the_sum = 0.
    I = [0.]
    for i in np.arange(1,len(t)-2):
        the_sum += prefac *trapezoid(t,R,Rdot,i)
        I.append(the_sum )
    I_s = np.array(I)
    
    ax2.plot(t[:len(I_s)],I_s,'r-')
    fig.tight_layout()
    plt.show()
    
    np.savetxt(os.path.join(pathalpha,"KelvinBIM"),np.array([t[:len(I_s)],I_s]).T, \
               delimiter='    ',header="#time    KelvinImpulse_from_BlakeFormula")
        
        
    
    
    
if __name__ == "__main__":
    main()