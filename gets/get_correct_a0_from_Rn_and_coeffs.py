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
    
    
    ## eqs for a0 verified by CL with mathematica and documented in notes about a0 on overleaf:
    #c1=(2*a1**2 + (6*a2**2)/5. + (6*a3**2)/7. + (2*a4**2)/3.)/2.
    #c2=((4*a1**2*a2)/5. + (4*a2**3)/35. + (36*a1*a2*a3)/35. + (8*a2*a3**2)/35. + (12*a2**2*a4)/35. + (16*a1*a3*a4)/21. + (12*a3**2*a4)/77. + (40*a2*a4**2)/231. + (36*a4**3)/1001.)/2.
    
    c1=(2*a1**2 + (6*a2**2)/5. + (6*a3**2)/7. + (2*a4**2)/3. + (6*a5**2)/11. + (6*a6**2)/13. + (2*a7**2)/5. + (6*a8**2)/17.)/2.
    c2=((4*a1**2*a2)/5. + (4*a2**3)/35. + (36*a1*a2*a3)/35. + (8*a2*a3**2)/35. + (12*a2**2*a4)/35. + (16*a1*a3*a4)/21. + (12*a3**2*a4)/77. + (40*a2*a4**2)/231. + (36*a4**3)/1001. + (40*a2*a3*a5)/77. + (20*a1*a4*a5)/33. + (240*a3*a4*a5)/1001. + (20*a2*a5**2)/143. + (12*a4*a5**2)/143. + (200*a3**2*a6)/1001. + (60*a2*a4*a6)/143. + (40*a4**2*a6)/429. + (72*a1*a5*a6)/143. + (28*a3*a5*a6)/143. + (160*a5**2*a6)/2431. + (84*a2*a6**2)/715. + (168*a4*a6**2)/2431. + (800*a6**3)/46189. + (140*a3*a4*a7)/429. + (252*a2*a5*a7)/715. + (1120*a4*a5*a7)/7293. + (28*a1*a6*a7)/65. + (2016*a3*a6*a7)/12155. + (5040*a5*a6*a7)/46189. + (112*a2*a7**2)/1105. + (13608*a4*a7**2)/230945. + (2000*a6*a7**2)/46189. + (980*a4**2*a8)/7293. + (672*a3*a5*a8)/2431. + (2940*a5**2*a8)/46189. + (336*a2*a6*a8)/1105. + (6048*a4*a6*a8)/46189. + (2100*a6**2*a8)/46189. + (32*a1*a7*a8)/85. + (3024*a3*a7*a8)/20995. + (4320*a5*a7*a8)/46189. + (3500*a7**2*a8)/96577. + (144*a2*a8**2)/1615. + (216*a4*a8**2)/4199. + (3600*a6*a8**2)/96577. + (980*a8**3)/96577.)/2.

    a0= -((2**0.3333333333333333*c1)/(-27.0*c2 + 27.0*RE**3 + np.sqrt(108.0*c1**3. + (-27.0*c2 + 27.0*RE**3)**2))**0.3333333333333333) + (-27.0*c2 + 27.0*RE**3 + np.sqrt(108.0*c1**3 + (-27.0*c2 + 27.0*RE**3)**2))**0.3333333333333333/(3.*2.**0.3333333333333333) 
    print(a0)

if __name__=="__main__":
    main()
