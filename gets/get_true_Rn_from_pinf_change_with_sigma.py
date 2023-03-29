#!/bin/python

import os, sys, argparse
import numpy as np

def func(Rn,Rn_standard,sigma,pinf_new,pinf):
    return (pinf + 2*sigma/Rn_standard) * Rn_standard**3 - (pinf_new + 2*sigma/Rn)*Rn**3

def Newton_find_Rn(Rn_standard,sigma,pinf_new,pinf):
    Rn = Rn_standard # starting value
    if not sigma == 0.0:
        tol=1e-10
        temp_tol=10000.
        dR = 1e-6
        while temp_tol > tol:
            f = func(Rn,Rn_standard,sigma,pinf_new,pinf)
            df = (func(Rn+dR,Rn_standard,sigma,pinf_new,pinf) - func(Rn-dR,Rn_standard,sigma,pinf_new,pinf))/(2*dR)
            Rn_new = Rn - f/df
            temp_tol = np.abs(1.-Rn_new/Rn)
            Rn = Rn_new
    else:
        Rn_new = (pinf/pinf_new)**(1./3.) *Rn_standard
    return Rn_new

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-Rn", "--Rn", help="input Rn at 101315 Pa", type=float, required=True)
    parser.add_argument("-s", "--sigma", help="sigma", type=float, required=True)
    parser.add_argument("-pi", "--pinf", help="atmospheric pressure", type=float, required=True)

    args = parser.parse_args()
    
    Rn_standard = args.Rn
    sigma = args.sigma
    pinf_new = args.pinf
    pinf = 101315.
    
    if pinf_new == pinf:
        print(Rn_standard)
    else:
        print(Newton_find_Rn(Rn_standard,sigma,pinf_new,pinf))
    

if __name__=="__main__":
    main()
