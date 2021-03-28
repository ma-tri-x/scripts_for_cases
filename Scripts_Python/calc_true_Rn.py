#!/bin/python

import os,sys
import numpy as np

with open("0/alpha2_vol_t0","r") as f:
    v = f.readlines()

vol = float(v[0].split("\n")[0])

R = pow(3.*vol/4./np.pi,1./3.)

with open("0/max_p_t0","r") as f:
    p = f.readlines()

p_rgh = float(p[0].split("\n")[0])

Rn = pow(p_rgh/101315.,1./(3.*1.4))*R

print(Rn)
