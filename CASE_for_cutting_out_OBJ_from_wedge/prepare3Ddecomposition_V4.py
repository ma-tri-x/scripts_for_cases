#!/bin/python

import json
import os,sys,argparse
import numpy as np

class Decomposer(object):
    def __init__(self):
        with open("conf_dict.json",'r') as conf:
            self.case_dict = json.load(conf)
        self.start_time = self.case_dict["controlDict"]["startTime"]
        self.nprocs = self.read_nprocs_from_dec_dict()
        self.coresize = self.case_dict["mesh"]["meshCoreSize"]
        self.degs = 360./(self.nprocs-1)

    def read_nprocs_from_dec_dict(self):
        with open("system/decomposeParDict",'r') as decPD:
            lines = decPD.readlines()
        nprocs = 0
        for line in lines:
            if (line.find("numberOfSubdomains") != -1):
                nprocs = int((line.split(" ")[-1]).split(";")[-2])
                break
        return nprocs
    
    def funkySetFields(self):
        unit_vector="vector(pos().x,pos().y,pos().z)/\
                (sqrt(pos().x*pos().x +\
                    (pos().y)*(pos().y) +\
                        pos().z*pos().z))"
        distance_vector="vector(pos().x,pos().y,pos().z)"
        radial_distance="sqrt(pos().x*pos().x + (pos().y)*(pos().y) + pos().z*pos().z)"
        phi="(atan((pos().z)/pos().x)*180./{})".format(np.pi)
        phi_trans="(pos().x < 0 ? 180.+{} : (pos().z < 0 ? 360.+{} : {}))".format(phi,phi,phi)
        
        print("... setting the processor fields into 0/cellDist")
        os.system("cp 0/backup/alpha1.org 0/cellDist")
        os.system("sed -i \"s#alpha1#cellDist#g\" 0/cellDist")
        os.system("funkySetFields  -case . -field cellDist \
                       -expression \"0\"\
                       -time 0 -keepPatches >> setFields.log")
        for proc in range(int(self.nprocs-1)):
            os.system("funkySetFields  -case . -field cellDist \
                       -expression \"{}/{} > {} ? {} : cellDist\"\
                       -time 0 -keepPatches \
                       >> setFields.log".format(phi_trans,self.degs,proc,proc))
        os.system("funkySetFields  -case . -field cellDist \
                       -expression \"{}\" -time 0 -keepPatches \
                       -condition \"mag(pos().x) < {}/4. && mag(pos().y) < {}/2.\
                                    && mag(pos().z) < {}/4.\"\
                       >> setFields.log".format(self.nprocs-1,
                                                self.coresize,self.coresize,self.coresize))
        os.system("funkySetFields  -case . -field amrAllow \
                       -expression \"0\" -time 0 -keepPatches \
                       -condition \"mag(pos().x) < {}/4. && mag(pos().y) < {}/2.\
                                    && mag(pos().z) < {}/4.\"\
                       >> setFields.log".format(self.coresize,self.coresize,self.coresize))
        
        os.system("gunzip 0/cellDist.gz")

        ##read file
        print("... converting 0/cellDist to constant/cellDist ...")
        with open("0/cellDist", "r") as cdFile:
            lines = cdFile.readlines()

        #replace and delete unwanted lines
        lines[11] = lines[11].replace("volScalarField", "labelList")
        lines[12] = lines[12].replace("0", "constant")
        del lines[17:21]
        bfline = 0
        for i, line in enumerate(lines):
            if (line.find("boundaryField") != -1):
                bfline = i
                break
        del lines[i:]

        #write file
        with open("constant/cellDist", "w") as cdFile:
            for line in lines:
                cdFile.write(line)
        print("now you may run decomposePar ...")
        
    def funkySetFields_test(self):
        unit_vector="vector(pos().x,pos().y,pos().z)/\
                (sqrt(pos().x*pos().x +\
                    (pos().y)*(pos().y) +\
                        pos().z*pos().z))"
        distance_vector="vector(pos().x,pos().y,pos().z)"
        radial_distance="sqrt(pos().x*pos().x + (pos().y)*(pos().y) + pos().z*pos().z)"
        phi="(atan((pos().z)/pos().x)*180./{})".format(np.pi)
        phi_trans="(pos().x < 0 ? 180.+{} : (pos().z < 0 ? 360.+{} : {}))".format(phi,phi,phi)
        
        print("... setting the processor fields into 0/cellDist")
        os.system("cp 0/backup/alpha1.org 0/cellDist")
        os.system("sed -i \"s#alpha1#cellDist#g\" 0/cellDist")
        os.system("funkySetFields  -case . -field cellDist \
                       -expression \"0\"\
                       -time 0 -keepPatches >> setFields.log")
        os.system("funkySetFields  -case . -field cellDist \
                       -expression \"{}\"\
                       -time 0 -keepPatches \
                       >> setFields.log".format(phi_trans))
        os.system("gunzip 0/cellDist.gz")

        ##read file
        print("... converting 0/cellDist to constant/cellDist ...")
        with open("0/cellDist", "r") as cdFile:
            lines = cdFile.readlines()

        #replace and delete unwanted lines
        lines[11] = lines[11].replace("volScalarField", "labelList")
        lines[12] = lines[12].replace("0", "constant")
        del lines[17:21]
        bfline = 0
        for i, line in enumerate(lines):
            if (line.find("boundaryField") != -1):
                bfline = i
                break
        del lines[i:]

        #write file
        with open("constant/cellDist", "w") as cdFile:
            for line in lines:
                cdFile.write(line)
        print("now you may run decomposePar ...")


def main():
    #print("It's not yet done.")
    #exit(1)
    
    #parser = argparse.ArgumentParser()
    #parser.add_argument("-o","--offset", help="float of bubble offset", default=0., type=float)
    #args = parser.parse_args()
    
    decomp = Decomposer()
    decomp.funkySetFields()
        


if __name__=="__main__":
    main()
    
    
    
    
