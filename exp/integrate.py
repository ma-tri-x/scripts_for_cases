#!/bin/python

import numpy as np
import argparse

def func(x,y):
    return (np.exp(-(x-9.94261)**2/(4.88536))*1.04863e-05 + np.exp(-(x-16.0116)**2/(6.36906))*1.09307e-05)*(np.exp(-y**2)/(5.97806))

#def func(x,y):
#    return x**2*y**3

def get_simple_vol(x,y,xstep,ystep):
    p1 = func(x,y)
    p2 = func(x+xstep,y)
    p3 = func(x+xstep,y+ystep)
    p4 = func(x,y+ystep)
    l = [p1,p2,p3,p4]
    minmax = [np.min(l),np.max(l)]
    middle = 0.5*(minmax[0]+minmax[1])
    return xstep*ystep*middle

def integrate(a,b,c,d, xsamples, ysamples):
    xstep = (b-a)/float(xsamples)
    ystep = (d-c)/float(ysamples)
    x=a
    y=c
    integral=0.0
    while x <= b:
        while y <= d:
            integral += get_simple_vol(x,y,xstep,ystep)
            y+=ystep
        y = c
        x+=xstep
    return integral

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", help="lower x border", type=float, required=True)
    parser.add_argument("-b", help="higher x border", type=float, required=True)
    parser.add_argument("-c", help="lower y border", type=float, required=True)
    parser.add_argument("-d", help="higher y border", type=float, required=True)
    parser.add_argument("-s", help="start-samples", type=int, required=True)
    parser.add_argument("-e", help="end-samples", type=int, required=True)
    parser.add_argument("-t", help="tolerance of result", type=float, required=True)
    args = parser.parse_args()
    
    startsamples=args.s
    endsamples=args.e
    a=args.a
    b=args.b
    c=args.c
    d=args.d
    result1 = integrate(a,b,c,d,startsamples,startsamples)
    calc=True
    samples = startsamples
    while calc:
        samples += np.round((endsamples - startsamples)/100.)
        result2 = integrate(a,b,c,d,samples,samples)
        print result2,np.abs(1.-result2/result1)
        if np.abs(1.-result2/result1) <= args.t:
            calc = False
            print result2
        else:
            result1 = result2
    
    
    

if __name__=="__main__":
    main()