#!/bin/python

import os, sys, argparse, glob, time
import numpy as np

def main():
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", "--argument", help="some required string", type=str, required=True)
    parser.add_argument("-b", "--secondarg", help="some default float", type=float, required=False, default=1.5)

    args = parser.parse_args()
    
    print("use parenthesis for prints")

if __name__=="__main__":
    main()
