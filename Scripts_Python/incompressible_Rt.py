#!/bin/python

import os, sys, argparse, glob, time
import numpy as np

pinf=101315.
gamma=1.4

def mass(Rn):
    m=1.2041*4.*np.pi/3.*Rn**3
    return m

def pbubble(Rn,R):
    return pinf*(Rn/R)**(3.*gamma)

def bubble_surface_area(R):
    return 4.*np.pi*R*R

def Rdotdot(m,Rn,R):
    return (pbubble(Rn,R)-pinf)*bubble_surface_area(R)/m

def VerletStep(m,Rn,R,lastR,dt):
    return 2.*R-lastR + Rdotdot(m,Rn,R)*dt*dt

def DGL(Rn,R,Rdot):
    #Rayleigh-Plesset. Rdotdot=
    return (pbubble(Rn,R) - pinf)/R/998. -1.5*Rdot*Rdot/R

def RK3(Rn,R,Rdot,dt):
    old_r = R;
    old_v = Rdot;

    k1v = DGL(Rn,old_r,old_v);
    k1r = old_v;

    k2v = DGL(Rn,old_r+dt*k1r,old_v+dt*k1v);
    k2r = old_v + dt*k1v;

    k3v = DGL(Rn,old_r+dt/4.*(k1r + k2r), old_v+dt/4.*(k1v + k2v));
    k3r = old_v + dt/4.*(k1v+k2v);

    r = old_r + dt/6.*(k1r + 4.*k3r + k2r);
    v = old_v + dt/6.*(k1v + 4.*k3v + k2v);
    return r,v

def V(r):
    return 4.*np.pi/3.*r**3

def Energy(Rn,R,R0):
    Ebubble=pinf*V(Rn)/(gamma-1.)*((Rn/R)**(3*gamma-3.) - 1.)
    Eliquid=pinf*(V(R)-V(R0))
    return Ebubble + Eliquid

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-Rn", "--Rn", help="Rn", type=float, required=True)
    parser.add_argument("-R0", "--R0", help="R0", type=float, required=False, default=20e-6)
    parser.add_argument("-dt", "--dt", help="delta t", type=float, required=False, default=1e-8)
    parser.add_argument("-tend", "--tend", help="time to end", type=float, required=False, default=100e-6)

    args = parser.parse_args()
    
    t=0
    dt=args.dt
    R0=args.R0
    Rn=args.Rn
    m=mass(Rn)
    Etot=(pbubble(Rn,R0)*V(R0)-pinf*V(Rn))/(gamma-1)
    
    #with open("incompressible_Rt.dat","w") as out:
        #lastR=R0
        #R=R0
        #R = R0+0.5*Rdotdot(m,Rn,R)*dt*dt # +Rdot*dt but is zero
        #out.write("#time  R   E\n")
        #E=Energy(Rn,R0,R0)
        #out.write("{}    {}    {}\n".format(0,R0,E/Etot))
        #t=t+dt
        #while t<args.tend:
            #E=Energy(Rn,R,R0)
            #out.write("{}    {}    {}\n".format(t,R,E/Etot))
            #lastR = R
            #R = VerletStep(m,Rn,R,lastR,dt)
            #t=t+dt
    with open("incompressible_Rt.dat","w") as out:
        R=R0
        Rdot=0
        out.write("#time  R   E\n")
        while t<args.tend:
            E=Energy(Rn,R,R0)
            out.write("{}    {}    {}\n".format(t,R,E/Etot))
            R,Rdot = RK3(Rn,R,Rdot,dt)
            t=t+dt

if __name__=="__main__":
    main()
