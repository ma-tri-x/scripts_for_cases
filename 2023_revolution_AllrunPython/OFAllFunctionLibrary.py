#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import subprocess, json, shutil, re
#from meshespython import AbcMesh

class Case(object):
    def __init__(self,conf_dict_loaded_as_dict,pVar="p_rgh",rho2tildeVar="rho_gTilde"):
        self.my_env = os.environ.copy()
        #if my_env["WM_PROJECT_DIR"]:
        try:
            proj_dir = self.my_env["WM_PROJECT_DIR"]
        except(KeyError):
            print("please source the foam bashrc!")
            exit(1)
        
        ##my_env["PATH"] = f"/usr/sbin:/sbin:{my_env['PATH']}"
        #subprocess.Popen(my_command, env=my_env)
        ## returns output as byte string
        #returned_output = subprocess.run(cmd,capture_output=True)
        ## using decode() function to convert byte string to string
        #print(returned_output)
        
        self.pVar = pVar
        self.rho2tildeVar  = rho2tildeVar
        self.thisdir = os.path.dirname(os.path.abspath( __file__ ))
        
        #with open("conf_dict.json","r") as f:
            #self.conf_dict = json.load(f)
        self.conf_dict = conf_dict_loaded_as_dict
        
        self.store_solver_commit_number()
        try:
            self.meshFile = "constant/polyMesh/{}".format(self.conf_dict["mesh"]["meshFile"])
        except(KeyError):
            print("Warning: no meshFile given for m4... but probably taking python mesh?")
            self.meshFile = "constant/polyMesh/dontUseThisOne"
        self.copy_0backup()
        self.bubble_center = self.determine_bubble_center()
        
        self.gamma = self.conf_dict["gas"]["gamma"]
        self.pV = self.conf_dict["gas"]["pV"]
        self.pInf = self.conf_dict["liquid"]["pInf"]
        self.Rn = self.conf_dict["bubble"]["Rn"] * (101315./self.pInf)**(1./3.)
        try:
            if self.conf_dict["bubble"]["dontCorrectRnToOneBar"]:
                self.Rn = self.conf_dict["bubble"]["Rn"]
        except(KeyError):
            print("if pInf != 101315: Rn corrected for pInf")
        self.sigma = self.conf_dict["transportProperties"]["sigma"]
        #BVAN=0.0000364 # m^3/mol
        self.mu_l = self.conf_dict["liquid"]["mu"]
        self.Tref = self.conf_dict["transportProperties"]["Tref"]
        self.gasConstGeneral = self.conf_dict["transportProperties"]["gasConstGeneral"] # J/mol K
        self.specGasConst = self.conf_dict["gas"]["specGasConst"]
        self.beta = 0.0 #self.conf_dict["gas"]["beta"]

        self.pn = self.pInf + 2.* self.sigma / self.Rn - self.pV  
        self.Rmax = self.conf_dict["bubble"]["Rmax"]
        self.R0 = self.conf_dict["bubble"]["Rstart"]
        self.widthOfInterface = self.conf_dict["funkySetFields"]["widthOfInterface"]
        self.Uif = self.conf_dict["funkySetFields"]["U_interface"]

        self.rho_n = self.pn / (self.specGasConst * self.Tref * (1.- self.beta) )
        self.rho_min = self.rho_n * (self.Rn / self.Rmax)**3. 
        self.pBubble = self.pn * ((self.Rn**3. - self.beta*self.Rn**3.)/(self.R0**3. - self.beta*self.Rn**3.))**self.gamma + self.pV 

        self.x_coord = "pos().x"
        self.y_coord = "pos().y"
        self.z_coord = "pos().z"
        self.sq_x = f"({self.x_coord}*{self.x_coord})"
        self.sq_y = f"(({self.y_coord}-{self.bubble_center})*({self.y_coord}-{self.bubble_center}))"
        self.sq_z = f"({self.z_coord}*{self.z_coord})"

        self.distance_vector = f"vector({self.z_coord}, {self.y_coord}, {self.z_coord})"
        self.radial_distance = f"sqrt({self.sq_x} + {self.sq_y} + {self.sq_z})"
        self.unit_vector = f"{self.distance_vector} / {self.radial_distance}"

        self.funkySetFieldsLog = "log.funkySetFields"
        with open(self.funkySetFieldsLog,"w") as f:
            f.write("")

        self.startTime = self.conf_dict["controlDict"]["startTime"]

        print("R0      = {} ".format(self.R0))
        print("Rn      = {} ".format(self.Rn))
        print("pn      = {} ".format(self.pn))
        print("pBubble = {} ".format(self.pBubble))
        
        self.copied_snappyHexMeshDict_already = False
        try:
            snappyScript = self.conf_dict["snappy"]["snappyScript"]
            if snappyScript == "snappyHexMeshDict":
                self.copied_snappyHexMeshDict_already = True
        except(KeyError):
            self.copied_snappyHexMeshDict_already = True
            
    def Allclean(self):
        #stdout,stderr = self._run_system_command("bash Allclean")
        #print(stdout,stderr)
        print("cleaning case ...")
        geofile = glob.glob("*.geo")
        if geofile:
            self._mkdir_if_not_exists("geo")
            for i in geofile:
                shutil.move(i,"geo/")
        
        to_be_removed = glob.glob("processor*")
        to_be_removed.extend(glob.glob("sets/"))
        to_be_removed.extend(glob.glob("postProcessing/"))
        to_be_removed.extend(glob.glob("0/p_rgh"))
        to_be_removed.extend(glob.glob("0/alpha*"))
        to_be_removed.extend(glob.glob("0/rho*"))
        to_be_removed.extend(glob.glob("0/passiveScalar"))
        to_be_removed.extend(glob.glob("0/U*"))
        to_be_removed.extend(glob.glob("0/constant*"))
        to_be_removed.extend(glob.glob("0/polyMesh*"))
        to_be_removed.extend(glob.glob("0/*.gz"))
        to_be_removed.extend(glob.glob("0/uniform"))
        to_be_removed.extend(glob.glob("log.*"))
        to_be_removed.extend(glob.glob("constant/polyMesh/sets"))
        to_be_removed.extend(glob.glob("constant/triSurface"))
        if self.conf_dict["mesh"]["execute_blockMesh"]:
            to_be_removed.extend(glob.glob("constant/polyMesh/*.gz"))
            to_be_removed.extend(glob.glob("constant/polyMesh/boundary"))
        for item in to_be_removed:
            if os.path.isdir(item):
                shutil.rmtree(item)
            if os.path.isfile(item):
                os.remove(item)
                
    
    def store_solver_commit_number(self):
        os.chdir(os.path.join(self.my_env["WM_PROJECT_USER_DIR"],"localMassCorr_working"))
        version_number,_ = self._run_system_command("git log")
        os.chdir(self.thisdir)
        with open("solver_version_number.info","w") as f:
            f.write(version_number.split("\n")[0])
            
    def _run_system_command(self,cmd):
        a = subprocess.run(cmd.split(" "),capture_output=True, universal_newlines=True)
        stdout = a.stdout
        stderr = a.stderr
        if not a.returncode == 0:
            print("Error in subprocess {}".format(cmd))
            print(a.stdout)
            print(a.stderr)
            exit(a.returncode)
        return stdout,stderr
    
    def _grep(self,filename,search_string):
        containing_lines = []
        with open(filename, "r") as f:
            lines = f.readlines()
        for l in lines:
            if search_string in l:
                containing_lines.append(l.split("\n")[0])
        return containing_lines
    
    def copy_0backup(self):
        shutil.copy2("0/backup/alpha1.org","0/alpha1")
        shutil.copy2(f"0/backup/{self.pVar}.org",f"0/{self.pVar}")
        shutil.copy2(f"0/backup/{self.rho2tildeVar}.org",f"0/{self.rho2tildeVar}")
        shutil.copy2("0/backup/U","0/U")
        shutil.copy2("0/backup/passiveScalar.org","0/passiveScalar")
        if os.path.isdir("CAD"):
            try:
                self._mkdir_if_not_exists("constant/triSurface")
                for obj in self.conf_dict["CAD"]["objects"]:
                    shutil.copy2("CAD/{}".format(obj),"constant/triSurface/")
                    self.change_obj_file_to_meter(obj)
            except:
                print("WARNING: couldn't copy CAD/{}".format(self.conf_dict["CAD"]["objects"]))
    
    def clear_polyMesh_for_Snappy(self):
        content = glob.glob("constant/polyMesh/sets")
        if content:
            shutil.rmtree(content[0])
        content = glob.glob("constant/polyMesh/cellLevel.gz")
        if content:
            os.remove(content[0])
        content = glob.glob("constant/polyMesh/pointLevel.gz")
        if content:
            os.remove(content[0])
        
    def determine_bubble_center(self,secondBubble=False):
        offset = self.conf_dict["bubble"]["D_init"]
        try:
            if self.conf_dict["bubble"]["doubleBubble"]:
                if secondBubble:
                    offset = - self.conf_dict["bubble"]["D_init"]
        except(KeyError):
            try:
                if self.conf_dict["bubble"]["ycenter"]:
                    offset = self.conf_dict["bubble"]["ycenter"]
            except(KeyError):
                pass
        return offset
    
    def m4Mesh(self):
        print("m4-ing ...")
        blockMeshDict,_ = self._run_system_command(f"m4 {self.meshFile}")
        with open("constant/polyMesh/blockMeshDict","w") as f:
            f.write(blockMeshDict)
    
    def blockMesh(self):
        print("blockMesh-ing...")
        stdout,stderr = self._run_system_command("blockMesh")
        with open("log.blockMesh","w") as f:
            f.write(stdout)
            f.write(stderr)
        self.nCells = self._grep("log.blockMesh","nCells")[0]
        print(self.nCells) # in nCells there is already in: "nCells: "
        
    def stitchMesh(self):
        stdout, stderr = self._run_system_command("stitchMesh wall wall2 -perfect -overwrite")
        with open("log.stitchMesh","w") as f:
            f.write(stdout)
            f.write(stderr)
        # rm -f constant/polyMesh/faceZones.gz
        redundant_files = glob.glob("0/meshPhi*")
        if redundant_files:
            for i in redundant_files:
                os.remove(i)
    
    def checkMesh(self):
        print("checkMesh-ing...")
        stdout,stderr = self._run_system_command("checkMesh")
        with open("log.checkMesh","w") as f:
            f.write(stdout)
            f.write(stderr)
        self.nCellsCM = self._grep("log.checkMesh","cells:")[0].replace("cells:","")
        print("cells now: ",self.nCellsCM)
        
    def change_obj_file_to_meter(self,geometry):
        geometry = geometry
        thefile = os.path.join("constant/triSurface",geometry)
        print(f"changing {thefile} to meter instead of mm")
        with open(thefile,"r") as f:
            l = f.readlines()
        for i,line in enumerate(l):
            if "v " in line:
                vals_str = line.split("\n")[0].split(" ")
                x = float(vals_str[1])/1000
                y = float(vals_str[2])/1000
                z = float(vals_str[3])/1000
                vals = "v {} {} {}\n".format(x,y,z)
                l[i] = vals
        with open(thefile,"w") as f:
            f.writelines(l)
        
    def snappyHexMesh(self,debug=False):
        self.clear_polyMesh_for_Snappy()
        if not self.copied_snappyHexMeshDict_already:
            shutil.copy2("system/{}".format(self.conf_dict["snappy"]["snappyScript"]),"system/snappyHexMeshDict")
            self.copied_snappyHexMeshDict_already = True
        print("preparing snappyHexMesh...")
        content = glob.glob("0/*.gz")
        if content:
            for i in content:
                os.remove(i)
        content = glob.glob("0/uniform")
        if content:
            os.removedirs("0/uniform")
        #self.copy_0backup()
        print("snappyHexMesh-ing...")
        if debug:
            stdout,stderr = self._run_system_command("snappyHexMesh")
        else:
            stdout,stderr = self._run_system_command("snappyHexMesh -overwrite")
        with open("log.snappyHexMesh","w") as f:
            f.write(stdout)
            f.write(stderr)
        self.copy_0backup()
        
    def run_funkySetFields_command(self,field,expression,condition):
        cmd = ["funkySetFields","-case", ".","-field", f"{field}","-expression", expression,"-condition",condition,"-time" ,f"{self.startTime}","-keepPatches"]
        if condition == "":
            cmd = ["funkySetFields","-case", ".","-field", f"{field}","-expression", expression,"-time" ,f"{self.startTime}","-keepPatches"]
        a = subprocess.run(cmd,capture_output=True, universal_newlines=True)
        #stdout = str(a.stdout.decode('utf-8')).replace("\\n","\n")
        #stderr = str(a.stderr.decode('utf-8')).replace("\\n","\n")
        stdout = a.stdout
        stderr = a.stderr
        if not a.returncode == 0:
            print("Error in subprocess {}".format(cmd))
            print(a.stdout)
            print(a.stderr)
            exit(a.returncode)
        else:
            with open(self.funkySetFieldsLog,"a") as f:
                f.write(stdout)
                f.write(stderr)
        
    def set_U_field_zero(self):
        print("---- setting field U to zero ----")
        self.run_funkySetFields_command("U","0.0 * vector(0,1,0)","")
    
    def set_alpha_field_bubble(self):
        print(f"---- setting alpha1 field for a bubble with R0 = {self.R0} at D_init = {self.bubble_center} ----")
        self.run_funkySetFields_command("alpha1",f"0.5*(tanh(({self.radial_distance}-{self.R0})*5.9/{self.widthOfInterface})+1)","")
        
    def set_alpha_field_ellipse(self):
        print("----- setting alpha1 field ellipse ------")
        alpha = self.conf_dict["bubble"]["excentricity"]
        e_x = alpha
        Ry = self.R0 / e_x**(2/3)
        Rx = Ry * e_x
        expression=f"{self.sq_x} + {self.sq_y}*{e_x}*{e_x} < {Rx} * {Rx} ?0:1"
        self.run_funkySetFields_command("alpha1",expression,"")
        
    def set_alpha_field_Vogel(self):
        print("--- setting alpha1 to Vogel guide tip bubble")
        heightOfVogelBubble = self.conf_dict["bubble"]["heightOfVogelBubble"]
        RadiusOfVogelBubble = self.conf_dict["bubble"]["radiusOfVogelBubble"]
        sq_RadiusOfVogelBubble = RadiusOfVogelBubble**2
        capRadiusOfVogelBubble = self.conf_dict["bubble"]["capRadiusOfVogelBubble"]
        self.run_funkySetFields_command("alpha1",f"{self.sq_x} + {self.sq_z} < {sq_RadiusOfVogelBubble} && \
                                                   {self.y_coord} < {self.bubble_center} + {heightOfVogelBubble} && \
                                                   {self.y_coord} > {self.bubble_center} ? 0 : 1","")
        
        temp_origin = heightOfVogelBubble - np.sqrt( capRadiusOfVogelBubble**2 - RadiusOfVogelBubble**2 ) + self.bubble_center
        t_sq_x = self.sq_x
        t_sq_y = f"({self.y_coord}-{temp_origin})*({self.y_coord}-{temp_origin})"
        t_sq_z = self.sq_z
        t_radial_distance = f"sqrt({t_sq_x} + {t_sq_y} + {t_sq_z})"
        self.run_funkySetFields_command("alpha1",f"{t_sq_x} + {t_sq_z} < {sq_RadiusOfVogelBubble} && \
                                                   {t_radial_distance} < {capRadiusOfVogelBubble} ? 0 : 1","")
        
    def get_correct_a0_from_Rn_and_coeffs(self):
        RE  = self.Rn
        a1  = 0.0
        a2  = self.conf_dict["legendre"]["modeTwo"]
        a3  = self.conf_dict["legendre"]["modeThree"]
        a4  = self.conf_dict["legendre"]["modeFour"]
        a5  = self.conf_dict["legendre"]["modeFive"]
        a6  = self.conf_dict["legendre"]["modeSix"]
        a7  = self.conf_dict["legendre"]["modeSeven"]
        a8  = self.conf_dict["legendre"]["modeEight"]
    
        ## eqs for a0 verified by CL with mathematica and documented in notes about a0 on overleaf:
        #c1=(2*a1**2 + (6*a2**2)/5. + (6*a3**2)/7. + (2*a4**2)/3.)/2.
        #c2=((4*a1**2*a2)/5. + (4*a2**3)/35. + (36*a1*a2*a3)/35. + (8*a2*a3**2)/35. + (12*a2**2*a4)/35. + (16*a1*a3*a4)/21. + (12*a3**2*a4)/77. + (40*a2*a4**2)/231. + (36*a4**3)/1001.)/2.
        
        c1=(2*a1**2 + (6*a2**2)/5. + (6*a3**2)/7. + (2*a4**2)/3. + (6*a5**2)/11. + (6*a6**2)/13. + (2*a7**2)/5. + (6*a8**2)/17.)/2.
        c2=((4*a1**2*a2)/5. + (4*a2**3)/35. + (36*a1*a2*a3)/35. + (8*a2*a3**2)/35. + (12*a2**2*a4)/35. + (16*a1*a3*a4)/21. + (12*a3**2*a4)/77. + (40*a2*a4**2)/231. + (36*a4**3)/1001. + (40*a2*a3*a5)/77. + (20*a1*a4*a5)/33. + (240*a3*a4*a5)/1001. + (20*a2*a5**2)/143. + (12*a4*a5**2)/143. + (200*a3**2*a6)/1001. + (60*a2*a4*a6)/143. + (40*a4**2*a6)/429. + (72*a1*a5*a6)/143. + (28*a3*a5*a6)/143. + (160*a5**2*a6)/2431. + (84*a2*a6**2)/715. + (168*a4*a6**2)/2431. + (800*a6**3)/46189. + (140*a3*a4*a7)/429. + (252*a2*a5*a7)/715. + (1120*a4*a5*a7)/7293. + (28*a1*a6*a7)/65. + (2016*a3*a6*a7)/12155. + (5040*a5*a6*a7)/46189. + (112*a2*a7**2)/1105. + (13608*a4*a7**2)/230945. + (2000*a6*a7**2)/46189. + (980*a4**2*a8)/7293. + (672*a3*a5*a8)/2431. + (2940*a5**2*a8)/46189. + (336*a2*a6*a8)/1105. + (6048*a4*a6*a8)/46189. + (2100*a6**2*a8)/46189. + (32*a1*a7*a8)/85. + (3024*a3*a7*a8)/20995. + (4320*a5*a7*a8)/46189. + (3500*a7**2*a8)/96577. + (144*a2*a8**2)/1615. + (216*a4*a8**2)/4199. + (3600*a6*a8**2)/96577. + (980*a8**3)/96577.)/2.

        a0= -((2**0.3333333333333333*c1)/(-27.0*c2 + 27.0*RE**3 + np.sqrt(108.0*c1**3. + (-27.0*c2 + 27.0*RE**3)**2))**0.3333333333333333) + (-27.0*c2 + 27.0*RE**3 + np.sqrt(108.0*c1**3 + (-27.0*c2 + 27.0*RE**3)**2))**0.3333333333333333/(3.*2.**0.3333333333333333) 
        return a0
        
    def set_alpha_field_legendre(self):
        print(f"---- setting mode amplitudes for alpha1 field for a bubble with R0 = {self.R0} at D_init = 0.0 ----")
        theta = "atan2(pos().x,pos().y)"  
        a0 = self.get_correct_a0_from_Rn_and_coeffs()
        print(f"a0 = {a0}")
        a1  = 0.0
        a2  = self.conf_dict["legendre"]["modeTwo"]
        a3  = self.conf_dict["legendre"]["modeThree"]
        a4  = self.conf_dict["legendre"]["modeFour"]
        a5  = self.conf_dict["legendre"]["modeFive"]
        a6  = self.conf_dict["legendre"]["modeSix"]
        a7  = self.conf_dict["legendre"]["modeSeven"]
        a8  = self.conf_dict["legendre"]["modeEight"]
        L2 = f"{a2}*0.5*(3*pow(cos({theta}),2)-1)"
        L3 = f"{a3}*0.5*(5*pow(cos({theta}),3)-3*cos({theta}))"
        L4 = f"{a4}*0.125*(35*pow(cos({theta}),4)-30*pow(cos({theta}),2)+3)"
        L5 = f"{a5}*0.125*(63*pow(cos({theta}),5)-70*pow(cos({theta}),3)+15*cos({theta}))"
        L6 = f"{a6}*0.0625*(231*pow(cos({theta}),6)-315*pow(cos({theta}),4)+105*pow(cos({theta}),2)-5)"
        L7 = f"{a7}*0.0625*(429*pow(cos({theta}),7)-693*pow(cos({theta}),5)+315*pow(cos({theta}),3)-35*cos({theta}))"
        L8 = f"{a8}*0.0078125*(6435*pow(cos({theta}),8)-12012*pow(cos({theta}),6)+6930*pow(cos({theta}),4)-1260*pow(cos({theta}),2)+35)"
        expression = f"{sq_x} + {sq_y} < ({L0}+{L2}+{L3}+{L4}+{L5}+{L6}+{L7}+{L8})*({L0}+{L2}+{L3}+{L4}+{L5}+{L6}+{L7}+{L8})?0:1"
        self.run_funkySetFields_command("alpha1",expression,"")
        
    def get_alpha2_vol_t0(self):
        print("-- reading real discretized alpha2-volume from mesh to 0/alpha2_vol_t0")
        stdout,stderr = self._run_system_command("get_alpha2_vol_t0")
        with open("log.get_alpha2_vol_t0","w") as f:
            f.write(stdout)
            f.write(stderr)
        true_alpha2_vol_str,_ = self._run_system_command("cat 0/alpha2_vol_t0")
        true_alpha2_vol = float(true_alpha2_vol_str.split("\n")[0])
        return true_alpha2_vol
    
    def read_theta(self):
        if not os.path.isfile("THETA"):
            print("ERROR: alter your meshDict.m4 such that it writes theta into THETA")
            exit(1)
        with open("THETA","r") as f:
            theta_str = f.readline().split("\n")[0]
        return float(theta_str)
    
    def _func(self,p0,Rdiscr,Rn_old):
        #return self.pInf*Rn_old**(3*self.gamma) + 2*self.sigma*Rn_old**(3*self.gamma-1.) - p0*Rdiscr**(3*self.gamma)
        return (self.pInf + 2.*self.sigma/Rn_old -self.pV)*(Rn_old/Rdiscr)**(3*self.gamma) + self.pV - p0

    def _Newton_find_Rn(self,p0,Rdiscr,Rn_old):
        if not self.sigma == 0.0:
            tol=1e-10
            temp_tol=10000.
            dR = 1e-6
            while temp_tol > tol:
                f = self._func(p0,Rdiscr,Rn_old)
                df = (self._func(p0,Rdiscr,Rn_old+dR) - self._func(p0,Rdiscr,Rn_old-dR))/(2*dR)
                Rn_new = Rn_old - f/df
                temp_tol = np.abs(1.-Rn_new/Rn_old)
                Rn_old = Rn_new
        else:
            Rn_new = (p0/self.pInf)**(1./(3.*self.gamma))*Rdiscr
        return Rn_new    
    
    def adapt_energy(self):
        print("---- setting pressure with same energy for discretization ----")
        p_init = self.pBubble # pBubble includes pV, pn doesn't
        Vn    = 4.*np.pi/3.* self.Rn**3  
        Vinit = 4.*np.pi/3.* self.R0**3 
        #Einit = (p_init * Vinit - (self.pn + self.pV) * Vn)/(self.gamma -1.) + self.pInf*(Vinit - Vn)
        Einit = (p_init * Vinit - (self.pn + self.pV) * Vn)/(self.gamma -1.) + self.pInf*(Vinit - Vn)
        
        true_alpha2_vol = self.get_alpha2_vol_t0()
        Vinitdiscr = true_alpha2_vol
        
        if self.conf_dict["mesh"]["meshDims"] == "2D":
            print("... adapt_energy: calculating 2D volume")
            theta = self.read_theta()
            Vinitdiscr = true_alpha2_vol * 180. / theta
        elif self.conf_dict["mesh"]["meshDims"] == "1D":
            print("... adapt_energy: calculating 1D volume")
            theta = self.read_theta()
            theta_rad = theta * np.pi /180.
            Vinitdiscr = true_alpha2_vol * np.pi / (np.tan(theta_rad))**2  
        
        Rdiscr = (Vinitdiscr / (4.*np.pi)*3)**(1./3.)
        print("... adapt_energy: R0_input = {}".format(self.R0))
        print("... adapt_energy: Rdiscr   = {}".format(Rdiscr))
        #p_initdiscr = ((self.gamma -1.)*(Einit - self.pInf*(Vinitdiscr-Vn)) + self.pn * Vn) / Vinitdiscr  
        p_initdiscr = ((self.gamma -1.)*(Einit - self.pInf*(Vinitdiscr-Vn)) + (self.pn + self.pV) * Vn) / Vinitdiscr
        print("... adapt_energy: adapting Rn...")
        Rndiscr = self._Newton_find_Rn(p_initdiscr,Rdiscr,self.Rn)
        pndiscr = self.pInf + 2.*self.sigma/Rndiscr - self.pV
        print("R_0new      = {}".format(Rdiscr))
        print("R_n_new     = {}".format(Rndiscr))
        print("pBubble_old = {}".format(self.pBubble))
        print("pBubble_new = {}".format(p_initdiscr))
        print(" --- consistency test: ---")
        print("p_initdiscr={}".format(p_initdiscr))
        print("p_directnew={}".format((self.pInf + 2.*self.sigma/Rndiscr -self.pV)*(Rndiscr/Rdiscr)**(3.*self.gamma)+self.pV))
        print("with pInf={}, R_n_new={}, sigma={}, pV={}, R_0new={}".format(self.pInf,Rndiscr,self.sigma,self.pV,Rdiscr))
        expression = f"{p_initdiscr}*(1.-alpha1)+{self.pVar}*alpha1"
        self.run_funkySetFields_command(self.pVar,expression,"")
        self.pBubble = p_initdiscr
        self.Rn = Rndiscr
        self.pn = pndiscr
        self.R0 = Rdiscr
        
    def adapt_pV(self):
        print("---- setting pressure with same adiabatic constant for discretization ----")
        true_alpha2_vol = self.get_alpha2_vol_t0()
        Vinitdiscr = true_alpha2_vol
        
        if self.conf_dict["mesh"]["meshDims"] == "2D":
            theta = self.read_theta()
            Vinitdiscr = true_alpha2_vol * 180. / theta
        elif self.conf_dict["mesh"]["meshDims"] == "1D":
            theta = self.read_theta()
            theta_rad = theta * np.pi /180.
            Vinitdiscr = true_alpha2_vol * np.pi / (np.tan(theta_rad))**2  
        
        Rdiscr = (Vinitdiscr / (4.*np.pi)*3)**(1./3.)
        adiabaticConstant = self.pBubble * self.R0**(3.*self.gamma)
        p_initdiscr = adiabaticConstant / (Rdiscr**(3.*self.gamma))
        print("R_0new      = {}".format(Rdiscr))
        print("pBubble_old = {}".format(self.pBubble))
        print("pBubble_new = {}".format(p_initdiscr))
        expression = f"{p_initdiscr}*(1.-alpha1)+{self.pVar}*alpha1"
        self.run_funkySetFields_command(self.pVar,expression,"")
        self.pBubble = p_initdiscr
        self.R0 = Rdiscr
        
    def set_passiveScalar_layeredColors(self):
        Y = 1.5 * self.Rmax + self.bubble_center
        print(f"---- passiveScalar part till Y: {Y} ----")
        self.run_funkySetFields_command("passiveScalar","1.0","")
        self.run_funkySetFields_command("passiveScalar",f"{self.y_coord}/{Y}",f"{self.y_coord} < {Y} ")
        
    def set_passiveScalar_sinus_schlieren(self,radius_of_PS,ycenter_of_PS,num_per_180_deg):
        print("---- setting PS to sinus schlieren 3D")
        t_sq_y = f"({self.y_coord}-{ycenter_of_PS})*({self.y_coord}-{ycenter_of_PS})"
        r = f"sqrt({self.sq_x} + {t_sq_y} + {self.sq_z})"
        theta = f"acos({self.z_coord}/{r})"
        phi = f"(sign({self.y_coord})*acos({self.x_coord}/sqrt({self.sq_x} + {t_sq_y})))"
        arg = f"2*{np.pi}*2*{num_per_180_deg}"
        self.run_funkySetFields_command("passiveScalar",f"{r} < {radius_of_PS} ? alpha1*sin({arg}*{phi})*sin({arg}*{theta}) : 0","")

    def decompose(self):
        method = self.conf_dict["decompose"]["method"]
        threads = self.conf_dict["decompose"]["threads"]
        xyz = self.conf_dict["decompose"]["xyz"]
        
        print(f"decomposing with xyz: {xyz} by method: {method}")
        
        stdout,stderr = self._run_system_command("decomposePar")
        with open("log.decomposePar","w") as f:
            f.write(stdout)
            f.write(stderr)

        procDirs = glob.glob("processor*")
        
        if not os.path.isdir("processor0/constant/polyMesh"):
            print("writing mesh to processor*/constant because it wasn't created...")
            for coreDir in procDirs:
                self._mkdir_if_not_exists(os.path.join(coreDir,"constant"))
                self._move_file_if_exists(os.path.join(coreDir,"0/polyMesh"),os.path.join(coreDir,"constant"))
                os.removedirs(os.path.join(coreDir,"0"))

        print(f"slots = {threads}, decomposed with {method}")
        
        if os.path.isfile("constant/dynamicMeshDict"):
            for coreDir in procDirs:
                self._copy_file_if_exists("constant/dynamicMeshDict",os.path.join(coreDir,"constant"))
        
        self._mkdir_if_not_exists("constant/polyMesh/temp")
        self._move_file_if_exists("constant/polyMesh/*.gz","constant/polyMesh/temp")
        self._move_file_if_exists("constant/polyMesh/boundary","constant/polyMesh/temp")
        
    def _move_file_if_exists(self,afile,bdir):
        l = glob.glob(afile)
        if not os.path.isdir(bdir):
            os.mkdir(bdir)
        if l: 
            for i in l:
                filename = i.split("/")[-1]
                shutil.move(i,os.path.join(bdir,filename)) # without filename in dest, not overwritten 
        
    def _mkdir_if_not_exists(self,thedir):
        if not os.path.isdir(thedir):
            os.mkdir(thedir)
    
    def _copy_file_if_exists(self,thefile,destdir):
        if os.path.isfile(thefile):
            self._mkdir_if_not_exists(destdir)
            shutil.copy2(thefile,destdir)
            
    
    """
    including here the former rerun.py and later temps_to_case_files.py:
    (*.template --> OF files)
    """
    def only_keep_template_paths(self, l):
        c = []
        for i in l:
            if '.template' in i: c.append(i)
        return c
                
    def find_all_variables_in_template(self, temp):
        p = re.compile('_[A-Z0-9]+[-A-Z0-9_]+')
        matches = []
        with open(temp,'r') as f:
            text = f.readlines()
            for k in text:
                matches.extend(p.findall(k))
        self.remove_duplicates_from_list(matches)
        return matches

    def remove_duplicates_from_list(self, matches):
        s = set([x for x in matches if matches.count(x) > 1])
        for i in s:
            j = matches.count(i)
            for k in range(j-1):
                matches.remove(i)
                
    def compare_found_to_dest(self, dest, var_list):
        for i in var_list:
            if dest.upper() == i[1:]:
                return i

    def replace_found_to_value(self, var_list):
        for i,placeholder in enumerate(var_list):
            if len(placeholder.split('-')) == 1:
                for first_level_item in self.conf_dict:
                    if first_level_item.upper() == placeholder[1:]:
                        var_list[i] = self.conf_dict[first_level_item]
            else:
                for first_level_item in self.conf_dict:
                    if first_level_item.upper() == placeholder.split('-')[0][1:]:
                        for second_level_item in self.conf_dict[first_level_item]:
                            if second_level_item.upper() == placeholder.split('-')[1]:
                                var_list[i] = self.conf_dict[first_level_item][second_level_item]
                                
    def find_and_replace_variables_in_copied_templates(self, tree_less):
        for copied_template in tree_less:
            the_vars = self.find_all_variables_in_template(copied_template)
            #print the_vars 
            transl_vars = list(the_vars)
            self.replace_found_to_value(transl_vars)
            #print transl_vars 
            with open(copied_template, 'r') as f:
                content = f.read()
            for i,var in enumerate(the_vars):
                if transl_vars[i] is not None: content = content.replace(var, str(transl_vars[i]))
            with open(copied_template, 'w') as f:
                f.write(content)

    def write_template_files_to_OF_files(self):        
        tree1 = self.only_keep_template_paths(os.listdir('.'))
        tree2 = self.only_keep_template_paths(os.listdir('./constant'))
        tree2 = ['./constant/{}'.format(i) for i in tree2]
        tree3 = self.only_keep_template_paths(os.listdir('./constant/polyMesh'))
        tree3 = ['./constant/polyMesh/{}'.format(i) for i in tree3]
        tree4 = self.only_keep_template_paths(os.listdir('./system'))
        tree4 = ['./system/{}'.format(i) for i in tree4]
        tree5 = self.only_keep_template_paths(os.listdir('./0'))
        tree5 = ['./0/{}'.format(i) for i in tree5]
        tree6 = self.only_keep_template_paths(os.listdir('./0/backup'))
        tree6 = ['./0/backup/{}'.format(i) for i in tree6]
        tree = tree1
        tree.extend(tree2)
        tree.extend(tree3)
        tree.extend(tree4)
        tree.extend(tree5)
        tree.extend(tree6)
        
        tree_less = []
        for i in tree: tree_less.append(i.split('.template')[0])
        for i,j in enumerate(tree): shutil.copy2(j, tree_less[i])
        
        self.find_and_replace_variables_in_copied_templates(tree_less)
        
    def _sed(self,filename,string_to_replace,replace_string):
        with open(filename,"r") as f:
            l = f.readlines()
        for n,k in enumerate(l):
            l[n] = k.replace(string_to_replace,replace_string)
        with open(filename,"w") as f:
            f.writelines(l)
            
    def prepare_snappyHexMeshDict_CAD_and_bubble(self,*args, **kwargs):
        print("--- prepare snappyHexMeshDict for CAD object and bubble region refinement...")
        script = "system/{}".format(self.conf_dict["snappy"]["snappyScript"])
        print(f".. using {script} as basis ..")
        shutil.copy2(script,"system/snappyHexMeshDict")
        self.copied_snappyHexMeshDict_already = True
        refinementCenter = kwargs.get('refinementCenter',None)
        if not refinementCenter:
            refinementCenter = self.bubble_center
        
        ### --- objects part
        objects_str = ""
        surfaces_refinement_str = ""
        for i,obj in enumerate(self.conf_dict["CAD"]["objects"]):
            obj_str = "{}\n\
            {{\n\
                type triSurfaceMesh;\n\
                regions\n\
                {{\n\
                    patch0\n\
                    {{\n\
                        name box1x1x1_region0;\n\
                    }}\n\
                }}\n\
            }}\n".format(obj)
            objects_str = "{}{}".format(objects_str,obj_str)
            
            surface_ref_str = "{}\n\
            {{\n\
                // Surface-wise min and max refinement level\n\
                level {};\n\
            }}\n".format(obj,self.conf_dict["snappy"]["refineObjectsLevels"][i])
            surfaces_refinement_str = "{}{}".format(surfaces_refinement_str,surface_ref_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-OBJECTS",objects_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-REFINESURFACES",surfaces_refinement_str)
        
        ### --- bubble part 
        refineBubblePart = kwargs.get('refineBubblePart',None)
        spheres_geometry_str = ""
        regions_refine_str = ""
        if not refineBubblePart == False:
            n0 = self.conf_dict["mesh"]["startCellAmount"]
            csgoal = self.conf_dict["mesh"]["cellSize"]
            xSize = self.conf_dict["mesh"]["xSize"]
            ySize = self.conf_dict["mesh"]["ySize"]
            zSize = self.conf_dict["mesh"]["zSize"]
            Vc = xSize*ySize*zSize/n0
            edge_length = Vc**(1./3.)
            iterations = round(np.log(edge_length/csgoal)/np.log(2.))
            print(f"number of iterations: {iterations}")
            
            if iterations > 13:
                print(f"Error in refineMesh prep.: impossible number of iterations: {iterations} > 13")
                exit(1)
            refineUntil = self.conf_dict["refine"]["refineUntil"]
            refineFrom = self.conf_dict["refine"]["refineFrom"]
                
            
            j=1
            while j < iterations + 1:
                print("--- preparing snappyHexMeshDict for refinement instead of refineMesh")
                cellSetCenter = refinementCenter #self.bubble_center
                refDist = (refineUntil-refineFrom)/(1.-iterations)**2 * (j - iterations)**2 + refineFrom
                ec_curr = edge_length/2**j 
                print(f"refine (snappy) radius: {refDist}, edge_length approx: {ec_curr}")
                sphere_str = "sphere{}\n\
                {{\n\
                    type searchableSphere;\n\
                    centre  (0 {} 0);\n\
                    radius  {};\n\
                }}\n".format(j,cellSetCenter,refDist)
                region_str = "sphere{}\n\
                {{\n\
                    mode inside;\n\
                    levels ((1E15 {}));\n\
                }}\n".format(j,j)
                
                spheres_geometry_str = "{}{}".format(spheres_geometry_str,sphere_str)
                regions_refine_str = "{}{}".format(regions_refine_str,region_str)
                j = j + 1
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-REFINESNAPPYSPHERES",spheres_geometry_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-REFINEMENTREGIONS",regions_refine_str)
        
        ### -- extra objects part:
        extraObjGeos_str = ""
        extraObjRefs_str = ""
        if self.conf_dict["snappy"]["addExtraObjects"]:
            for extra_obj in self.conf_dict["snappy"]["extraObjects"]:
                eOg_str = "{}\n{{\n".format(extra_obj)
                for prop in self.conf_dict["snappy"]["extraObjects"][f"{extra_obj}"]:
                    #print(f"self.conf_dict[\"snappy\"][\"extraObjects\"][{extra_obj}][{prop}] =")
                    val = self.conf_dict["snappy"]["extraObjects"][f"{extra_obj}"][f"{prop}"]
                    #print(val)
                    if not prop == "level":
                        eOg_str = "{}{}   {};\n".format(eOg_str,prop,val)
                eOg_str = "{}\n}}\n".format(eOg_str)
                extraObjGeos_str = "{}{}".format(extraObjGeos_str,eOg_str)
                ref_str = "{}\n\
                {{\n\
                    level {};\n\
                }}\n".format(extra_obj,self.conf_dict["snappy"]["extraObjects"][extra_obj]["level"])
                extraObjRefs_str = "{}{}".format(extraObjRefs_str,ref_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-EXTRAOBJECTSGEOMETRY",extraObjGeos_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-EXTRAOBJECTSREFINE",extraObjRefs_str)
        
        ### -- extra regions part:
        extraRegAllGeos_str = ""
        extraRegAllRefs_str = ""
        if self.conf_dict["snappy"]["addExtraRegions"]:
            for extra_reg in self.conf_dict["snappy"]["extraRegions"]:
                eRg_str = "{}\n{{\n".format(extra_reg)
                for prop in self.conf_dict["snappy"]["extraRegions"][f"{extra_reg}"]:
                    #print(f"self.conf_dict[\"snappy\"][\"extraObjects\"][{extra_obj}][{prop}] =")
                    val = self.conf_dict["snappy"]["extraRegions"][f"{extra_reg}"][f"{prop}"]
                    #print(val)
                    if not prop == "level":
                        eRg_str = "{}{}   {};\n".format(eRg_str,prop,val)
                eRg_str = "{}\n}}\n".format(eRg_str)
                extraRegAllGeos_str = "{}{}".format(extraRegAllGeos_str,eRg_str)
                ref_str = "{}\n\
                {{\n\
                    mode {};\n\
                    levels {};\n\
                }}\n".format(extra_reg,
                             self.conf_dict["snappy"]["extraRegions"][extra_reg]["mode"],
                             self.conf_dict["snappy"]["extraRegions"][extra_reg]["levels"])
                extraRegAllRefs_str = "{}{}".format(extraRegAllRefs_str,ref_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-EXTRAREGIONSGEOMETRY",extraRegAllGeos_str)
        self._sed("system/snappyHexMeshDict","_ALLRUNPY-EXTRAREGIONSREFINE",extraRegAllRefs_str)
            
    def refineMesh3D(self):
        print("prepare refining mesh...")
        n0 = self.conf_dict["mesh"]["startCellAmount"]
        csgoal = self.conf_dict["mesh"]["cellSize"]
        xSize = self.conf_dict["mesh"]["xSize"]
        ySize = self.conf_dict["mesh"]["ySize"]
        zSize = self.conf_dict["mesh"]["zSize"]
        Vc = xSize*ySize*zSize/n0
        edge_length = Vc**(1./3.)
        iterations = round(np.log(edge_length/csgoal)/np.log(2.))
        print(f"number of iterations: {iterations}")
        shutil.copy2("system/refineMeshDict.3D","system/refineMeshDict")
        if iterations > 13:
            print(f"Error in refineMesh prep.: impossible number of iterations: {iterations} > 13")
            exit(1)
        refineUntil = self.conf_dict["refine"]["refineUntil"]
        refineFrom = self.conf_dict["refine"]["refineFrom"]
            
        j=1
        while j < iterations + 1:
            print(f"cp system cellSetDict.1.backup system/cellSetDict.{j}")
            shutil.copy2("system/cellSetDict.1.backup",f"system/cellSetDict.{j}")
            cellSetCenter = self.bubble_center
            self._sed(f"system/cellSetDict.{j}","dinit","{}".format(cellSetCenter))
            refDist = (refineUntil-refineFrom)/(1.-iterations)**2 * (j - iterations)**2 + refineFrom
            ec_curr = edge_length/2**j 
            print(f"refine radius: {refDist}, edge_length approx: {ec_curr}")
            self._sed(f"system/cellSetDict.{j}","rrradius","{}".format(refDist))
            j = j + 1
        j=1
        while j < iterations + 1:
            print(f"cellSetting {j}...")
            shutil.copy2(f"system/cellSetDict.{j}","system/cellSetDict")
            stdout,stderr = self._run_system_command("cellSet")
            with open(f"log.cellSet.{j}","w") as f:
                f.write(stdout)
                f.write(stderr)
            print("refining mesh...")
            stdout,stderr = self._run_system_command("refineMesh -dict")
            with open(f"log.refineMesh.{j}","w") as f:
                f.write(stdout)
                f.write(stderr)
            latestRefineFolder = self.find_biggestNumber(proc_path=".")
            content = glob.glob(f"{latestRefineFolder}/polyMesh/*")
            for i in content:
                stdout,stderr = self._run_system_command(f"cp -r {i} constant/polyMesh/")
            print(f"rm -rf {latestRefineFolder}")
            self._run_system_command(f"rm -rf {latestRefineFolder}")
            j = j + 1
            
        
    def _path_is_num(self,path):
        try:
            float(path)
        except ValueError: 
            return False
        else:
            return True
        return False

    def find_biggestNumber(self,proc_path="processor0"):
        time_files = [os.path.join(proc_path, i) for i in os.listdir(proc_path) if self._path_is_num(i)]  
        time_steps = np.array([float(i.split('/')[-1]) for i in time_files])
        return(np.max(time_steps))
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
        
        
        
        
        
        
        
class Mesh(Case):
    def __init__(self,conf_dict_loaded_as_dict):
        super().__init__(conf_dict_loaded_as_dict,pVar="p_rgh",rho2tildeVar="rho_gTilde")
        self.header = """
        /*--------------------------------*- C++ -*----------------------------------*\
        | =========                 |                                                 |
        | \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
        |  \\    /   O peration     | Version:  2.0.0                                 |
        |   \\  /    A nd           | Web:      www.OpenFOAM.com                      |
        |    \\/     M anipulation  |                                                 |
        \*---------------------------------------------------------------------------*/

        FoamFile
        {
            version         2.0;
            format          ascii;
        
            root            "";
            case            "";
            instance        "";
            local           "";
        
            class           dictionary;
            object          blockMeshDict;
        }
        
        // * * * * * * * * Max Koch Mesh made with Python  * * * * * * * * * * * * * //
        """
        self.sketch = ""
        self.vertices = {}
        self.blocks = {}
        self.edges = {}
        self.patches = {}
        self.mergePatchPairs = {}
        self.vertexNumber = 0
        self.mesh_python = [] # list will/should contain only one entry, the instance of AbcMesh
        
    def add_mesh_python(self, mesh_python):
        if not isinstance(mesh_python, AbcMesh):
            raise TypeError('mesh_python doesn\'t match AbcMesh class.')
        else:
            self.mesh_python.append(mesh_python)
    
    def write_blockMeshDict(self):
        self.write_header()
        self.write_sketch()
        self.write_vertices()
        self.write_blocks()
        self.write_edges()
        self.write_patches()
        self.write_mergePatchPairs()
        
        
    def add_vertex(self,name,xyz):
        self.vertices[name] = {}
        self.vertices[name]["number"] = self.vertexNumber
        self.vertices[name]["coords"] = "({} {} {})  //# {} {}".format(xyz[0],xyz[1],xyz[2],self.vertexNumber,name)
        self.vertexNumber = self.vertexNumber + 1
    
    def add_block(self,name,vertices_names,cell_amounts,gradings):
        self.blocks[name] = {}
        self.blocks[name]["coords"] = "hex ({} {} {} {}   {} {} {} {})".format(self.vertices[vertices_names[0]]["number"],
                                                                               self.vertices[vertices_names[1]]["number"],
                                                                               self.vertices[vertices_names[2]]["number"],
                                                                               self.vertices[vertices_names[3]]["number"],
                                                                               self.vertices[vertices_names[4]]["number"],
                                                                               self.vertices[vertices_names[5]]["number"],
                                                                               self.vertices[vertices_names[6]]["number"],
                                                                               self.vertices[vertices_names[7]]["number"])
        self.blocks[name]["cell_amounts"] = " ({} {} {})".format(cell_amounts[0],
                                                                 cell_amounts[1],
                                                                 cell_amounts[2])
        self.blocks[name]["gradings"] = "simpleGrading ({} {} {}) //# {}".format(gradings[0],
                                                                                 gradings[1],
                                                                                 gradings[2],
                                                                                 name)
        
    def add_edge(self,name,edge_type,name_point1,name_point2,xyz):
        self.edges[name] = {}
        self.edges[name]["edge_type"] = edge_type
        self.edges[name]["name_point1"] = name_point1
        self.edges[name]["name_point2"] = name_point2
        self.edges[name]["coords"] = "({} {} {})  //# {}".format(xyz[0],xyz[1],xyz[2],name)
    
    def add_patch(self,patch_type,name):
        self.patches[name] = {}
        self.patches[name]["patch_type"] = patch_type
        self.patches[name]["faces"] = {}
        
    def add_face_to_patch(self,name,patch_name,names_points):
        self.patches[patch_name]["faces"][name] = "({} {} {} {}) //# {}".format(self.vertices[names_points[0]]["number"],
                                                                                self.vertices[names_points[1]]["number"],
                                                                                self.vertices[names_points[2]]["number"],
                                                                                self.vertices[names_points[3]]["number"],
                                                                                name)
    
    def write_header(self):
        with open("constant/polyMesh/blockMeshDict","w") as f:
            f.write(self.header)
    
    def write_sketch(self):
        with open("constant/polyMesh/blockMeshDict","a") as f:
            f.write(self.sketch)
            
    def write_vertices(self):
        with open("constant/polyMesh/blockMeshDict","a") as f:
            f.write("\nvertices\n(\n")
            for vertex in self.vertices:
                f.write("    {}\n".format(self.vertices[vertex]["coords"]))
            f.write(");\n\n")
    
    def write_blocks(self):
        with open("constant/polyMesh/blockMeshDict","a") as f:
            f.write("\nblocks\n(\n")
            for block in self.blocks:
                f.write("    {} {} {}\n".format(self.blocks[block]["coords"],
                                                self.blocks[block]["cell_amounts"],
                                                self.blocks[block]["gradings"]))
            f.write(");\n\n")
            
    def write_edges(self):
        with open("constant/polyMesh/blockMeshDict","a") as f:
            f.write("\nedges\n(\n")
            for edge in self.edges:
                f.write("    {} {} {} {}\n".format(self.edges[edge]["edge_type"],
                                                   self.vertices[self.edges[edge]["name_point1"]]["number"],
                                                   self.vertices[self.edges[edge]["name_point2"]]["number"],
                                                   self.edges[edge]["coords"]))
            f.write(");\n\n")
    
    def write_patches(self):
        with open("constant/polyMesh/blockMeshDict","a") as f:
            f.write("\npatches\n(\n")
            for patch in self.patches:
                f.write("    {} {}\n    (\n".format(self.patches[patch]["patch_type"],
                                                    patch))
                for face in self.patches[patch]["faces"]:
                    f.write("        {}\n".format(self.patches[patch]["faces"][face]))
                f.write("    )\n\n")
            f.write(");\n\n")
            
    def write_mergePatchPairs(self):
        with open("constant/polyMesh/blockMeshDict","a") as f:
            f.write("\nmergePatchPairs\n(\n);\n")
    
        
        
        
        
