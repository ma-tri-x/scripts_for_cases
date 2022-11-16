#!/bin/python

import os, sys #, argparse, glob, time
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    #parser = argparse.ArgumentParser()
    #parser.add_argument("-a", "--argument", help="some required string", type=str, required=True)
    #parser.add_argument("-b", "--secondarg", help="some default float", type=float, required=False, default=1.5)

    #args = parser.parse_args()
    
    thefile = sys.argv[1]
    
    with open(thefile, "r") as f:
        l = f.readlines()
    
    new_lines = []
    for i,line in enumerate(l):
        new_line_list = (line.split("\n")[0]).split(" ")
        new_line = ""
        for j,num in enumerate(new_line_list):
            if j > 0 and not new_line_list[0] == "f" and not new_line_list[0] == "#":
                new_line_list[j] = "{}e-3".format(num)
            new_line = " ".join(new_line_list)
        #new_lines.append("{}\n".format(new_line))
        new_lines.append(new_line)
    
    with open("{}_meter.obj".format(thefile.split(".obj")[0]),"w") as g:
        for line in new_lines:
            g.write("{}\n".format(line))

if __name__=="__main__":
    main()
