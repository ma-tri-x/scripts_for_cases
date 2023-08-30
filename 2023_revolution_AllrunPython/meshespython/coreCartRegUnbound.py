#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import OFAllFunctionLibrary as OAFL

class MeshCalcer(OAFL.Mesh):
    def __init__(self):
        super().__init__()
        self.theta = self.conf_dict["mesh"]["theta"]
        self.Xi = self.conf_dict["mesh"]["meshCoreSize"]
        self.Xii = 2.0 * np.sqrt(2)*self.Xi
        self.X = self.conf_dict["mesh"]["factorBubbleDomainRmax"] * self.Rmax
        self.XF = self.conf_dict["mesh"]["domainSizeFactorRmax"] * self.Rmax
        self.cellSize = self.conf_dict["mesh"]["cellSize"]
        self.gradingFactor = self.conf_dict["mesh"]["gradingFactor"]
        with open("THETA","w") as f:
            f.write(str(self.theta))
            
        self.Anum = round(self.Xi/self.cellSize)
        self.Bnum45deg = self.Anum
        self.Bnum90deg = 2*self.Anum
        self.origin = 0.0 #self.bubble_center
        
    def get_grading_num_cw(self,cell_width_beginning,X_coord_beginning,X_coord_end):
        # length of domain
        length = X_coord_end - X_coord_beginning
        # grading of domain
        grd = X_coord_end/X_coord_beginning 
        # computing radial number of cells
        logarg = (cell_width_beginning/length-1.)/(cell_width_beginning/length*grd - 1.)
        num = round(1+np.log(Bgrd)/np.log(logarg))
        cell_width_end = cell_width_beginning*grd
        return grd,num,cell_width_end
        
    def GCPx(self,r,phi):
        return r * np.cos(phi/180.*np.pi) * np.cos(self.theta/180.*np.pi)
    
    def GCPy(self,r,phi):
        return r * np.sin(phi/180.*np.pi) + self.origin
    
    def GCPz(self,r,phi):
        return r * np.cos(phi/180.*np.pi) * np.sin(self.theta/180.*np.pi)
    
    def get_z(self,x):
        return x * np.tan(self.theta/180.*np.pi)
    
    def add_cartesian_block(self,name,ld,rt,nums_xy,gradings_xy,add_empty=True):
        #left-down-front  right-top-back (in xyz language)
        cell_amounts = [nums_xy[0],1,nums_xy[1]]
        gradings = [gradings_xy[0],1,gradings_xy[1]]
        l = ld[0]
        d = ld[1]
        r = rt[0]
        t = rt[1]
        vertex_1_name, vertex_1_xyz = f"{name}ldf", [l,d, self.get_z(l)]
        vertex_2_name, vertex_2_xyz = f"{name}rdf", [r,d, self.get_z(r)]
        vertex_3_name, vertex_3_xyz = f"{name}rdb", [r,d,-self.get_z(r)]
        vertex_4_name, vertex_4_xyz = f"{name}ldb", [l,d,-self.get_z(l)]
        vertex_5_name, vertex_5_xyz = f"{name}ltf", [l,t, self.get_z(l)]
        vertex_6_name, vertex_6_xyz = f"{name}rtf", [r,t, self.get_z(r)]
        vertex_7_name, vertex_7_xyz = f"{name}rtb", [r,t,-self.get_z(r)]
        vertex_8_name, vertex_8_xyz = f"{name}ltb", [l,t,-self.get_z(l)]
        self.add_vertex(vertex_1_name, vertex_1_xyz)
        self.add_vertex(vertex_2_name, vertex_2_xyz)
        self.add_vertex(vertex_3_name, vertex_3_xyz)
        self.add_vertex(vertex_4_name, vertex_4_xyz)
        self.add_vertex(vertex_5_name, vertex_5_xyz)
        self.add_vertex(vertex_6_name, vertex_6_xyz)
        self.add_vertex(vertex_7_name, vertex_7_xyz)
        self.add_vertex(vertex_8_name, vertex_8_xyz)
        
        self.add_block(name,[vertex_1_name,
                             vertex_2_name,
                             vertex_3_name,
                             vertex_4_name,
                             vertex_5_name,
                             vertex_6_name,
                             vertex_7_name,
                             vertex_8_name],cell_amounts,gradings)
        
        self.add_face_to_patch(f"{name}front","front",[vertex_1_name,
                                                       vertex_2_name,
                                                       vertex_6_name,
                                                       vertex_5_name])
        self.add_face_to_patch(f"{name}back","back",  [vertex_3_name,
                                                       vertex_4_name,
                                                       vertex_8_name,
                                                       vertex_7_name])
        if add_empty:
            self.add_face_to_patch(f"{name}left","axis",[vertex_1_name,
                                                         vertex_4_name,
                                                         vertex_8_name,
                                                         vertex_5_name])
        
    
    def add_core_unbound(self):
        #width = self.Xi
        ld = [    0.0,self.origin - self.Xi]
        rt = [self.Xi,self.origin + self.Xi]
        nums_xy = [self.Anum,2*self.Anum]
        gradings_xy = [1.0,1.0]
        self.add_cartesian_block("A",ld,rt,nums_xy,gradings_xy)
        
    def calc_mesh(self):
        print("calculating the mesh... (formerly m4ing)")
        
        self.add_patch("wedge","front")
        self.add_patch("wedge","back")
        self.add_patch("patch","side")
        self.add_patch("wedge","front")
        self.add_patch("empty","axis")
        
        self.add_core_unbound()
        
        
