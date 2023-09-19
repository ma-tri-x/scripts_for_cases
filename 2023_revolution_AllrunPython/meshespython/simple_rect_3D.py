#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import OFAllFunctionLibrary as OAFL

class MeshCalcer(OAFL.Mesh):
    def __init__(self,conf_dict_json_loaded_as_dict):
        super().__init__(conf_dict_json_loaded_as_dict)
        self.cellSize = self.conf_dict["mesh"]["cellSize"]
        self.origin = 0.0 #self.bubble_center
        
        #self.calc_mesh() # could also happen here. So no activation needed in Allrun.py
        
    def calc_mesh(self):
        print("calculating the mesh... (formerly m4ing)")
        
        self.add_patch("patch","side")
        self.add_patch("patch","wall")
        
        X = self.conf_dict["mesh"]["xSize"]
        Y = self.conf_dict["mesh"]["ySize"]
        Z = self.conf_dict["mesh"]["zSize"]
        ycenter = self.conf_dict["mesh"]["ycenter"]
        center = (0.,ycenter,0.)
        startCellAmount = self.conf_dict["mesh"]["startCellAmount"]
        startCellSize = (X*Y*Z/startCellAmount)**(1./3.)
        nums = (round(X/startCellSize),round(Y/startCellSize/2)*2,round(Z/startCellSize))
        
        self.add_cube_sideBottom("A",X,Y,Z,center,nums)
        
    def add_cube_sideBottom(self,name,X,Y,Z,center,nums):
        vertex_1_name, vertex_1_xyz = f"{name}ldf", [(center[0]-X/2),(center[1]-Y/2),(center[2]+Z/2)]
        vertex_2_name, vertex_2_xyz = f"{name}rdf", [(center[0]+X/2),(center[1]-Y/2),(center[2]+Z/2)]
        vertex_3_name, vertex_3_xyz = f"{name}rdb", [(center[0]+X/2),(center[1]-Y/2),(center[2]-Z/2)]
        vertex_4_name, vertex_4_xyz = f"{name}ldb", [(center[0]-X/2),(center[1]-Y/2),(center[2]-Z/2)]
        vertex_5_name, vertex_5_xyz = f"{name}ltf", [(center[0]-X/2),(center[1]+Y/2),(center[2]+Z/2)]
        vertex_6_name, vertex_6_xyz = f"{name}rtf", [(center[0]+X/2),(center[1]+Y/2),(center[2]+Z/2)]
        vertex_7_name, vertex_7_xyz = f"{name}rtb", [(center[0]+X/2),(center[1]+Y/2),(center[2]-Z/2)]
        vertex_8_name, vertex_8_xyz = f"{name}ltb", [(center[0]-X/2),(center[1]+Y/2),(center[2]-Z/2)]
        self.add_vertex(vertex_1_name, vertex_1_xyz)
        self.add_vertex(vertex_2_name, vertex_2_xyz)
        self.add_vertex(vertex_3_name, vertex_3_xyz)
        self.add_vertex(vertex_4_name, vertex_4_xyz)
        self.add_vertex(vertex_5_name, vertex_5_xyz)
        self.add_vertex(vertex_6_name, vertex_6_xyz)
        self.add_vertex(vertex_7_name, vertex_7_xyz)
        self.add_vertex(vertex_8_name, vertex_8_xyz)
        
        cell_amounts = nums
        gradings = (1,1,1)
        
        self.add_block(name,[vertex_1_name,
                             vertex_2_name,
                             vertex_3_name,
                             vertex_4_name,
                             vertex_5_name,
                             vertex_6_name,
                             vertex_7_name,
                             vertex_8_name],cell_amounts,gradings)
        
        
        self.add_face_to_patch(f"{name}front","wall",[vertex_1_name,
                                                      vertex_2_name,
                                                      vertex_6_name,
                                                      vertex_5_name])
        self.add_face_to_patch(f"{name}back","wall", [vertex_3_name,
                                                      vertex_4_name,
                                                      vertex_8_name,
                                                      vertex_7_name])
        self.add_face_to_patch(f"{name}left","wall", [vertex_1_name,
                                                      vertex_5_name,
                                                      vertex_8_name,
                                                      vertex_4_name])
        self.add_face_to_patch(f"{name}right","wall",[vertex_2_name,
                                                      vertex_3_name,
                                                      vertex_7_name,
                                                      vertex_6_name])
        self.add_face_to_patch(f"{name}top", "wall", [vertex_5_name,
                                                      vertex_6_name,
                                                      vertex_7_name,
                                                      vertex_8_name])
        
        self.add_face_to_patch(f"{name}bottom","side",[vertex_4_name,
                                                       vertex_3_name,
                                                       vertex_2_name,
                                                       vertex_1_name])
    
        
        
