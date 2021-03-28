#!/bin/python

import os,sys,glob

def main():
    os.system("sed -i \"s/\\\"alpha/#\\\"alpha/g\" contour/bla*csv")
    l=[]
    for i in [1,2,3,4,5,6,7,8,9]:
        l.extend(glob.glob("contour/bla{}.*.csv".format(i)))
    
    for i in l:
        with open(i,'r') as f:
            lines = f.readlines()
        bla0 = "contour/bla0{}".format(i[12:])
        with open(bla0,'a') as u:
            u.write("\n")
            for l in lines[1:] :
                u.write(l)

if __name__=='__main__':
    main()
