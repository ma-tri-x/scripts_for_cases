#!/bin/python

import os, sys, argparse
import numpy as np

def func(R0,sigma,p0,pinf,gamma,Rn_old):
    return pinf*Rn_old**(3*gamma) + 2*sigma*Rn_old**(3*gamma-1.) - p0*R0**(3*gamma)

def Newton_find_Rn(R0,sigma,p0,pinf,gamma,Rn_old):
    if not sigma == 0.0:
        tol=1e-10
        temp_tol=10000.
        dR = 1e-6
        while temp_tol > tol:
            f = func(R0,sigma,p0,pinf,gamma,Rn_old)
            df = (func(R0,sigma,p0,pinf,gamma,Rn_old+dR) - func(R0,sigma,p0,pinf,gamma,Rn_old-dR))/(2*dR)
            Rn_new = Rn_old - f/df
            temp_tol = np.abs(1.-Rn_new/Rn_old)
            Rn_old = Rn_new
    else:
        Rn_new = (p0/pinf)**(1./(3.*gamma))*R0
    return Rn_new

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-R0", "--R0", help="true R_0 of bubble", type=float, required=True)
    parser.add_argument("-s", "--sigma", help="sigma", type=float, required=True)
    parser.add_argument("-p0", "--p0", help="true bubble p0 pressure", type=float, required=True)
    parser.add_argument("-pi", "--pinf", help="atmospheric pressure", type=float, required=False, default = 101315.)
    parser.add_argument("-g", "--gamma", help="polytropic exponent", type=float, required=False, default = 1.4)
    #parser.add_argument("-Rn", "--Rn_old", help="old value of R_n as initial guess", type=float, required=True)

    args = parser.parse_args()
    
    R0,sigma,p0,pinf,gamma,Rn_old = args.R0, args.sigma, args.p0, args.pinf,args.gamma, (args.p0/args.pinf)**(1./3.)*args.R0
    
    print(Newton_find_Rn(R0,sigma,p0,pinf,gamma,Rn_old))
    

if __name__=="__main__":
    main()
