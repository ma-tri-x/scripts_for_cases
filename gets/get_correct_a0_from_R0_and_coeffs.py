#!/bin/python

import os, sys, argparse, glob, time
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    #parser = argparse.ArgumentParser()
    #parser.add_argument("-a", "--argument", help="some required string", type=str, required=True)
    #parser.add_argument("-b", "--secondarg", help="some default float", type=float, required=False, default=1.5)

    #args = parser.parse_args()
    
    try:
        RE  = float(sys.argv[1])
        a1  = float(sys.argv[2])
        a2  = float(sys.argv[3])
        a3  = float(sys.argv[4])
        a4  = float(sys.argv[5])
        a5  = float(sys.argv[6])
        a6  = float(sys.argv[7])
        a7  = float(sys.argv[8])
        a8  = float(sys.argv[9])
    except:
        print("usage: python3 {} RE a1 a2 a3 a4 a5 a6 a7 a8".format(sys.argv[0]))
        print("RE = Rn")
        exit(1)
    
    
    # eq for a0 verified by CL with mathematica and documented in notes about a0 on overleaf:
    c1=(2*a1**2 + (6*a2**2)/5. + (6*a3**2)/7. + (2*a4**2)/3.)/2.
    c2=((4*a1**2*a2)/5. + (4*a2**3)/35. + (36*a1*a2*a3)/35. + (8*a2*a3**2)/35. + (12*a2**2*a4)/35. + (16*a1*a3*a4)/21. + (12*a3**2*a4)/77. + (40*a2*a4**2)/231. + (36*a4**3)/1001.)/2.

    a0= -((2**0.3333333333333333*c1)/(-27.0*c2 + 27.0*RE**3 + np.sqrt(108.0*c1**3. + (-27.0*c2 + 27.0*RE**3)**2))**0.3333333333333333) + (-27.0*c2 + 27.0*RE**3 + np.sqrt(108.0*c1**3 + (-27.0*c2 + 27.0*RE**3)**2))**0.3333333333333333/(3.*2.**0.3333333333333333) 
    print(a0)

if __name__=="__main__":
    main()
