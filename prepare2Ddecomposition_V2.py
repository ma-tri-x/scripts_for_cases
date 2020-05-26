#!/bin/python

import json
import os,sys,argparse
import numpy as np

class Decomposer(object):
    def __init__(self,offset):
        with open("conf_dict.json",'r') as conf:
            self.case_dict = json.load(conf)
        self.start_time = self.case_dict["controlDict"]["startTime"]
        self.nprocs = self.read_nprocs_from_dec_dict()
        self.offset = offset
        self.degs = 90./self.nprocs

    def read_nprocs_from_dec_dict(self):
        with open("system/decomposeParDict",'r') as decPD:
            lines = decPD.readlines()
        nprocs = 0
        for line in lines:
            if (line.find("numberOfSubdomains") != -1):
                nprocs = int((line.split(" ")[-1]).split(";")[-2])
                break
        return nprocs
    
    def find_line_number(self,lines,somestring):
        for i, line in enumerate(lines):
            if (line.find(somestring) != -1):
                return i
    
    def funkySetFields(self):
        unit_vector="vector(pos().x,pos().y-{},pos().z)/\
                (sqrt(pos().x*pos().x +\
                    (pos().y-{})*(pos().y-{}) +\
                        pos().z*pos().z))".format(self.offset,self.offset,self.offset)
        distance_vector="vector(pos().x,pos().y-{},pos().z)".format(self.offset)
        radial_distance="sqrt(pos().x*pos().x + \
                        (pos().y-{})*(pos().y-{}) + pos().z*pos().z)".format(self.offset,self.offset)
        phi_num="atan((pos().y-{})/pos().x)/{}*180./{}".format(self.offset,np.pi,self.degs)
        
        print "... setting the processor fields into 0/cellDist"
        os.system("cp 0/backup/alpha1.org 0/cellDist")
        os.system("sed -i \"s#alpha1#cellDist#g\" 0/cellDist")
        os.system("funkySetFields  -case . -field cellDist \
                       -expression \"0\"\
                       -time 0 -keepPatches >> setFields.log")
        for proc in range(int(self.nprocs)):
            os.system("funkySetFields  -case . -field cellDist \
                       -expression \"({} < 0 ? -1*({}) : {}) > {} ? {} : cellDist\"\
                       -time 0 -keepPatches \
                       >> setFields.log".format(phi_num,phi_num,phi_num,proc,proc))
            #os.system("funkySetFields  -case . -field cellDist \
                       #-expression \"{} > {} ? {} : cellDist\"\
                       #-time 0 -keepPatches >> setFields.log".format(phi_num,
                                                                     #proc,proc))
        
        os.system("gunzip 0/cellDist.gz")

        ##read file
        print "... converting 0/cellDist to constant/cellDist ..."
        with open("0/cellDist", "r") as cdFile:
            lines = cdFile.readlines()

        #replace and delete unwanted lines
        volScLine = self.find_line_number(lines,"volScalarField")
        locLine   = self.find_line_number(lines,"0")
        lines[volScLine] = lines[volScLine].replace("volScalarField", "labelList")
        lines[locLine]   = lines[locLine].replace("0", "constant")
        delbegin = self.find_line_number(lines,"dimensions")
        delend   = self.find_line_number(lines,"internalField")
        del lines[delbegin:delend+1]
        i = self.find_line_number(lines,"boundaryField")
        del lines[i:]

        #write file
        with open("constant/cellDist", "w") as cdFile:
            for line in lines:
                cdFile.write(line)
        print "now you may run decomposePar ..."


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-o","--offset", help="float of bubble offset", default=0., type=float)
    args = parser.parse_args()
    
    decomp = Decomposer(args.offset)
    decomp.funkySetFields()
        


if __name__=="__main__":
    main()
    
    
    
    
