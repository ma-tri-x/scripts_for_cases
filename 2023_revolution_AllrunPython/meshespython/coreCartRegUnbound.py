#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import OFAllFunctionLibrary as OAFL

class MeshCalcer(OAFL.Mesh):
    def __init__(self,conf_dict_json_loaded_as_dict):
        super().__init__(conf_dict_json_loaded_as_dict)
        self.theta = self.conf_dict["mesh"]["theta"]
        self.Xi = self.conf_dict["mesh"]["meshCoreSize"]
        self.Xii = 1.6 * np.sqrt(2)*self.Xi
        self.X = self.conf_dict["mesh"]["factorBubbleDomainRmax"] * self.Rmax
        if self.X < self.Xii:
            print("bad mesh def. performing X=2*Xii")
            self.X = 2.*self.Xii
        self.XF = self.conf_dict["mesh"]["domainSizeFactorRmax"] * self.Rmax
        if self.XF < self.X:
            print("bad mesh def. performing XF=2*X")
            self.XF = 2.*self.X
        self.cellSize = self.conf_dict["mesh"]["cellSize"]
        self.gradingFactor = self.conf_dict["mesh"]["gradingFactor"]
        with open("THETA","w") as f:
            f.write(str(self.theta))
            
        self.Anum = round(self.Xi/self.cellSize)
        self.Bnum45deg = self.Anum
        self.Bnum90deg = 2*self.Anum
        self.origin = 0.0 #self.bubble_center
        
        #self.calc_mesh() # could also happen here. So no activation needed in Allrun.py
        
    def calc_mesh(self):
        print("calculating the mesh... (formerly m4ing)")
        
        self.add_patch("wedge","front")
        self.add_patch("wedge","back")
        self.add_patch("patch","side")
        self.add_patch("wedge","front")
        self.add_patch("empty","axis")
        
        self.add_core_unbound()
        
        diag_core = np.sqrt(2.)*self.Xi
        
        grd,num,cw = self.get_grading_num_cw(self.cellSize,diag_core,self.Xii)
        grading_transition_layer = grd
        cell_amount_r_transition_layer = num
        cell_width_end_transition_layer = cw
        cell_amounts_rphi_transition_layer = [cell_amount_r_transition_layer,self.Anum]
        
        self.add_layer_non_quadratic_core("B","A",grading_transition_layer,
                                          cell_amounts_rphi_transition_layer,self.Xii)
        
        grd,num,cw = self.get_grading_num_cw(cell_width_end_transition_layer,
                                             self.Xii,self.X)
        grading_bubble_layer = grd
        cell_amount_r_bubble_layer = num
        cell_width_end_bubble_layer = cw
        cell_amounts_rphi_bubble_layer = [cell_amount_r_bubble_layer,self.Anum]
        
        self.add_layer_non_quadratic_core("C","B",grading_bubble_layer,
                                          cell_amounts_rphi_bubble_layer,self.X)
        
        grd,num,cw = self.get_grading_num_cw(cell_width_end_bubble_layer,
                                             self.X,self.XF,
                                             exaggeration=self.conf_dict["mesh"]["gradingFactor"])
        grading_outer_layer = grd
        cell_amount_r_outer_layer = num
        cell_width_end_outer_layer = cw
        cell_amounts_rphi_outer_layer = [cell_amount_r_outer_layer,self.Anum]
        
        self.add_layer_non_quadratic_core("D","C",grading_outer_layer,
                                          cell_amounts_rphi_outer_layer,self.XF,add_side=True)
        
    def add_layer_non_quadratic_core(self,name,name_of_inner_layer,
                                     grading_layer,cell_amounts_rphi_layer,radius,add_side=False):
        A = name_of_inner_layer
        B = name
        grading_x = grading_layer
        num_r = cell_amounts_rphi_layer[0]
        num_phi = cell_amounts_rphi_layer[1]
        cell_amounts_xy = [num_phi,num_r]
        phi_left = -90.
        phi_right = -45.
        first_layer = True
        if not name_of_inner_layer == "A": 
            A = f"{name_of_inner_layer}1"
            first_layer = False
        self.attach_radial_block_to_the_bottom(f"{B}1",f"{A}",radius,
                                               cell_amounts_xy,
                                               grading_x,
                                               phi_left,phi_right,
                                               add_empty=True,add_side=add_side)
        
        cell_amounts_xy = [num_r,2*num_phi]
        phi_top = 45.
        phi_bottom = -45.0
        ThirdBlock = f"{name_of_inner_layer}1"
        if not name_of_inner_layer == "A": 
            A = f"{name_of_inner_layer}2"
            first_layer = False
        self.attach_radial_block_to_the_center_right(f"{B}2",f"{B}1",f"{A}",radius,
                                                  cell_amounts_xy,
                                                  grading_x,
                                                  phi_top,phi_bottom,
                                                  add_side=add_side,
                                                  first_layer=first_layer,
                                                  name_of_other_block_bottomleft=ThirdBlock)

        cell_amounts_xy = [num_phi,num_r]
        phi_left = 90.
        phi_right = 45.
        ThirdBlock = f"{name_of_inner_layer}2"
        if not name_of_inner_layer == "A": 
            A = f"{name_of_inner_layer}3"
            first_layer = False
        self.attach_radial_block_to_the_top_left(f"{B}3",f"{B}2",f"{A}",radius,
                                                 cell_amounts_xy,
                                                 grading_x,
                                                 phi_left,phi_right,
                                                 add_empty=True,add_side=add_side,
                                                 first_layer=first_layer,
                                                 name_of_other_block_bottomright=ThirdBlock)
        
        
    def add_core_unbound(self):
        #width = self.Xi
        ld = [    0.0,self.origin - self.Xi]
        rt = [self.Xi,self.origin + self.Xi]
        nums_xy = [self.Anum,2*self.Anum]
        gradings_xy = [1.0,1.0]
        self.add_cartesian_block("A",ld,rt,nums_xy,gradings_xy)
    
    def get_grading_num_cw(self,cell_width_beginning,X_coord_beginning,X_coord_end,
                           exaggeration=1.0):
        # length of domain
        length = X_coord_end - X_coord_beginning
        # grading of domain
        grd = exaggeration*X_coord_end/X_coord_beginning 
        # computing radial number of cells
        logarg = (cell_width_beginning/length-1.)/(cell_width_beginning/length*grd - 1.)
        num = round(1+np.log(grd)/np.log(logarg))
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
        
    
    def attach_radial_block_to_the_center_right(self,name,
                                         name_of_other_block_bottom,
                                         name_of_other_block_left,
                                         X_right_radius,
                                         cell_amounts_xy,
                                         grading_x,
                                         phi_top,
                                         phi_bottom,
                                         add_side=False,
                                         first_layer=True,
                                         name_of_other_block_bottomleft="B1"):
        #left-down-front  right-top-back (in xyz language)
        cell_amounts = [cell_amounts_xy[0],1,cell_amounts_xy[1]]
        gradings = [grading_x,1,1]
        leftname = name_of_other_block_left
        bottomname = name_of_other_block_bottom
        bottomleftname = name_of_other_block_bottomleft
        X = X_right_radius
        #
        if first_layer:
            vertex_1_name = f"{leftname}rdf"
            vertex_2_name = f"{bottomname}rdf"
            vertex_3_name = f"{bottomname}rdb"
            vertex_4_name = f"{leftname}rdb"
            vertex_5_name = f"{leftname}rtf"
            vertex_6_name, vertex_6_xyz = f"{name}rtf", [self.GCPx(X,phi_top),self.GCPy(X,phi_top), self.GCPz(X,phi_top)]
            vertex_7_name, vertex_7_xyz = f"{name}rtb", [self.GCPx(X,phi_top),self.GCPy(X,phi_top),-self.GCPz(X,phi_top)]
            vertex_8_name = f"{leftname}rtb"
            self.add_vertex(vertex_6_name, vertex_6_xyz)
            self.add_vertex(vertex_7_name, vertex_7_xyz)
        else:
            vertex_1_name = f"{bottomleftname}rdf"
            vertex_2_name = f"{bottomname}rdf"
            vertex_3_name = f"{bottomname}rdb"
            vertex_4_name = f"{bottomleftname}rdb"
            vertex_5_name = f"{leftname}rtf"
            vertex_6_name, vertex_6_xyz = f"{name}rtf", [self.GCPx(X,phi_top),self.GCPy(X,phi_top), self.GCPz(X,phi_top)]
            vertex_7_name, vertex_7_xyz = f"{name}rtb", [self.GCPx(X,phi_top),self.GCPy(X,phi_top),-self.GCPz(X,phi_top)]
            vertex_8_name = f"{leftname}rtb"
            self.add_vertex(vertex_6_name, vertex_6_xyz)
            self.add_vertex(vertex_7_name, vertex_7_xyz)
        
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
        edge_phi=(phi_top+phi_bottom)/2.
        edge_1_coords = [self.GCPx(X,edge_phi),self.GCPy(X,edge_phi), self.GCPz(X,edge_phi)]
        edge_2_coords = [self.GCPx(X,edge_phi),self.GCPy(X,edge_phi),-self.GCPz(X,edge_phi)]
        self.add_edge(f"{name}front","arc",vertex_2_name,vertex_6_name,edge_1_coords)
        self.add_edge(f"{name}back" ,"arc",vertex_3_name,vertex_7_name,edge_2_coords)
        
        ## not applicable when put to the right:
        #if add_empty:
            #self.add_face_to_patch(f"{name}left","axis",[vertex_1_name,
                                                         #vertex_4_name,
                                                         #vertex_8_name,
                                                         #vertex_5_name])
        if add_side:
            self.add_face_to_patch(f"{name}right","side",[vertex_2_name,
                                                          vertex_3_name,
                                                          vertex_7_name,
                                                          vertex_6_name])
                                                    
    def attach_radial_block_to_the_top_left(self,name,
                                         name_of_other_block_right,
                                         name_of_other_block_bottom,
                                         X_top_radius,
                                         cell_amounts_xy,
                                         grading_x,
                                         phi_left,
                                         phi_right,
                                         add_empty=True,
                                         add_side=False,
                                         first_layer=True,
                                         name_of_other_block_bottomright="B2"):
        #left-down-front  right-top-back (in xyz language)
        cell_amounts = [cell_amounts_xy[0],1,cell_amounts_xy[1]]
        gradings = [1,1,grading_x]
        rightname = name_of_other_block_right
        bottomname = name_of_other_block_bottom
        bottomrightname = name_of_other_block_bottomright
        X = X_top_radius
        #
        if first_layer:
            vertex_1_name = f"{bottomname}ltf"
            vertex_2_name = f"{bottomname}rtf"
            vertex_3_name = f"{bottomname}rtb"
            vertex_4_name = f"{bottomname}ltb"
            vertex_5_name, vertex_5_xyz = f"{name}ltf", [self.GCPx(X, phi_left),self.GCPy(X, phi_left), self.GCPz(X, phi_left)]  
            vertex_6_name = f"{rightname}rtf"
            vertex_7_name = f"{rightname}rtb"
            vertex_8_name, vertex_8_xyz = f"{name}ltb", [self.GCPx(X, phi_left),self.GCPy(X, phi_left),-self.GCPz(X, phi_left)]
            self.add_vertex(vertex_5_name, vertex_5_xyz)
            self.add_vertex(vertex_8_name, vertex_8_xyz)
        else:
            vertex_1_name = f"{bottomname}ltf"
            vertex_2_name = f"{bottomrightname}rtf"
            vertex_3_name = f"{bottomrightname}rtb"
            vertex_4_name = f"{bottomname}ltb"
            vertex_5_name, vertex_5_xyz = f"{name}ltf", [self.GCPx(X, phi_left),self.GCPy(X, phi_left), self.GCPz(X, phi_left)]  
            vertex_6_name = f"{rightname}rtf"
            vertex_7_name = f"{rightname}rtb"
            vertex_8_name, vertex_8_xyz = f"{name}ltb", [self.GCPx(X, phi_left),self.GCPy(X, phi_left),-self.GCPz(X, phi_left)]
            self.add_vertex(vertex_5_name, vertex_5_xyz)
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
        edge_phi=(phi_left+phi_right)/2.
        edge_1_coords = [self.GCPx(X,edge_phi),self.GCPy(X,edge_phi), self.GCPz(X,edge_phi)]
        edge_2_coords = [self.GCPx(X,edge_phi),self.GCPy(X,edge_phi),-self.GCPz(X,edge_phi)]
        self.add_edge(f"{name}front","arc",vertex_5_name,vertex_6_name,edge_1_coords)
        self.add_edge(f"{name}back" ,"arc",vertex_8_name,vertex_7_name,edge_2_coords)
        
        if add_empty:
            self.add_face_to_patch(f"{name}left","axis",[vertex_1_name,
                                                         vertex_4_name,
                                                         vertex_8_name,
                                                         vertex_5_name])
        if add_side:
            self.add_face_to_patch(f"{name}top","side",[vertex_5_name,
                                                        vertex_6_name,
                                                        vertex_7_name,
                                                        vertex_8_name])
            
    def attach_radial_block_to_the_bottom(self,name,
                                          name_of_other_block,
                                          X_bottom_radius,
                                          cell_amounts_xy,
                                          grading_x,
                                          phi_left,
                                          phi_right,
                                          add_empty=True,
                                          add_side=False):
        #left-down-front  right-top-back (in xyz language)
        cell_amounts = [cell_amounts_xy[0],1,cell_amounts_xy[1]]
        gradings = [1,1,1./grading_x]
        topname = name_of_other_block
        X = X_bottom_radius
        #
        vertex_1_name, vertex_1_xyz = f"{name}ldf", [self.GCPx(X, phi_left),self.GCPy(X, phi_left), self.GCPz(X, phi_left)]  
        vertex_2_name, vertex_2_xyz = f"{name}rdf", [self.GCPx(X,phi_right),self.GCPy(X,phi_right), self.GCPz(X,phi_right)]
        vertex_3_name, vertex_3_xyz = f"{name}rdb", [self.GCPx(X,phi_right),self.GCPy(X,phi_right),-self.GCPz(X,phi_right)]
        vertex_4_name, vertex_4_xyz = f"{name}ldb", [self.GCPx(X, phi_left),self.GCPy(X, phi_left),-self.GCPz(X, phi_left)]
        vertex_5_name = f"{topname}ldf"
        vertex_6_name = f"{topname}rdf"
        vertex_7_name = f"{topname}rdb"
        vertex_8_name = f"{topname}ldb"
        self.add_vertex(vertex_1_name, vertex_1_xyz)
        self.add_vertex(vertex_2_name, vertex_2_xyz)
        self.add_vertex(vertex_3_name, vertex_3_xyz)
        self.add_vertex(vertex_4_name, vertex_4_xyz)
        
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
        edge_phi=(phi_left+phi_right)/2.
        edge_1_coords = [self.GCPx(X,edge_phi),self.GCPy(X,edge_phi), self.GCPz(X,edge_phi)]
        edge_2_coords = [self.GCPx(X,edge_phi),self.GCPy(X,edge_phi),-self.GCPz(X,edge_phi)]
        self.add_edge(f"{name}front","arc",vertex_1_name,vertex_2_name,edge_1_coords)
        self.add_edge(f"{name}back" ,"arc",vertex_3_name,vertex_4_name,edge_2_coords)
        
        if add_empty:
            self.add_face_to_patch(f"{name}left","axis",[vertex_1_name,
                                                         vertex_4_name,
                                                         vertex_8_name,
                                                         vertex_5_name])
        if add_side:
            self.add_face_to_patch(f"{name}bottom","side",[vertex_1_name,
                                                           vertex_2_name,
                                                           vertex_3_name,
                                                           vertex_4_name])
    
        
        
