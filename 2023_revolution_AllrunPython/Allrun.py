#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import OFAllFunctionLibrary as OAFL
import subprocess

def main():
    case = OAFL.Case()
    case.m4Mesh()
    case.blockMesh()

if __name__=="__main__":
    main()
