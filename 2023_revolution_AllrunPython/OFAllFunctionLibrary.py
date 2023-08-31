#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import subprocess, json, shutil
#from meshespython import AbcMesh

class Case(object):
    def __init__(self,pVar="p_rgh",rho2tildeVar="rho_gTilde"):
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
        
        with open("conf_dict.json","r") as f:
            self.conf_dict = json.load(f)
        
        self.store_solver_commit_number()
        self.meshFile = "constant/polyMesh/{}".format(self.conf_dict["mesh"]["meshFile"])
        self.copy_0backup()
        self.bubble_center = self.determine_bubble_center()
        
        self.gamma = self.conf_dict["gas"]["gamma"]
        self.pV = self.conf_dict["transportProperties"]["pV"]
        self.pInf = self.conf_dict["liquid"]["pInf"]
        self.Rn = self.conf_dict["bubble"]["Rn"] * (101315./self.pInf)**(1./3.) 
        if self.conf_dict["bubble"]["dontCorrectRnToOneBar"]:
            self.Rn = self.conf_dict["bubble"]["Rn"]
        self.sigma = self.conf_dict["transportProperties"]["sigma"]
        #BVAN=0.0000364 # m^3/mol
        self.mu_l = self.conf_dict["liquid"]["mu"]
        self.Tref = self.conf_dict["transportProperties"]["Tref"]
        self.gasConstGeneral = self.conf_dict["transportProperties"]["gasConstGeneral"] # J/mol K
        self.specGasConst = self.conf_dict["gas"]["specGasConst"]
        self.beta = self.conf_dict["gas"]["beta"]

        self.pn = self.pInf + 2.* self.sigma / self.Rn - self.pV  
        self.Rmax = self.conf_dict["bubble"]["Rmax"]
        self.R0 = self.conf_dict["bubble"]["Rstart"]
        self.width = self.conf_dict["funkySetFields"]["widthOfInterface"]
        self.Uif = self.conf_dict["funkySetFields"]["U_interface"]

        self.rho_n = self.pn / (self.specGasConst * self.Tref * (1.- self.beta) )
        self.rho_min = self.rho_n * (self.Rn / self.Rmax)**3. 
        self.pBubble = self.pn * ((self.Rn**3. - self.beta*self.Rn**3.)/(self.R0**3. - self.beta*self.Rn**3.))**self.gamma 

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
    
    def Allclean(self):
        stdout,stderr = self._run_system_command("bash Allclean")
        print(stdout,stderr)
    
    def store_solver_commit_number(self):
        os.chdir(os.path.join(self.my_env["WM_PROJECT_USER_DIR"],"localMassCorr_working"))
        version_number,_ = self._run_system_command("git log")
        os.chdir(self.thisdir)
        with open("solver_version_number.info","w") as f:
            f.write(version_number.split("\n")[0])
            
    def _run_system_command(self,cmd):
        a = subprocess.run(cmd.split(" "),capture_output=True)
        stdout = a.stdout.decode('utf-8')
        stderr = a.stderr.decode('utf-8')
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
                os.mkdir("constant/triSurface")
                shutil.copy2("CAD/{}".format(self.conf_dict["CAD"]["object"]),"constant/triSurface/")
            except:
                pass
        
    def determine_bubble_center(self):
        offset = 0.0
        try:
            if self.conf_dict["bubble"]["doubleBubble"]:
                offset = - self.conf_dict["bubble"]["D_init"]
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
        os.remove("0/meshPhi*")
    
    def checkMesh(self):
        print("checkMesh-ing...")
        stdout,stderr = self._run_system_command("checkMesh")
        with open("log.checkMesh","w") as f:
            f.write(stdout)
            f.write(stderr)
        self.nCellsCM = self._grep("log.checkMesh","cells:")[0].replace("cells:","")
        print("cells now: ",self.nCellsCM)
        
    def snappyHexMesh(self):
        print("preparing snappyHexMesh...")
        os.remove("0/*.gz")
        os.removedirs("0/uniform")
        self.copy_0backup()
        print("snappyHexMesh-ing...")
        stdout,stderr = self._run_system_command("snappyHexMesh -overwrite")
        with open("log.snappyHexMesh","w") as f:
            f.write(stdout)
            f.write(stderr)
        self.copy_0backup()
        
    def run_funkySetFields_command(self,field,expression,condition):
        if not condition == "":
            a = subprocess.run(["funkySetFields","-case .",f"-field {field}",f"-expression \"{expression}\"",f"-condition \"{condition}\"",f"-time {self.startTime}"],capture_output=True)
        else:
            a = subprocess.run(["funkySetFields","-case .",f"-field {field}",f"-expression \"{expression}\"",f"-time {self.startTime}"],capture_output=True)
        stdout = a.stdout.decode('utf-8')
        stderr = a.stderr.decode('utf-8')
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
        print(f"---- setting alpha1 field for a bubble with R0 = {self.R0} at D_init = {self.D_init} ----")
        self.run_funkySetFields_command("alpha1",f"0.5*(tanh(({self.radial_distance}-{self.R0})*5.9/${self.widthOfInterface})+1)","",0.0)
        
    def set_alpha_field_ellipse(self):
        alpha = self.conf_dict["bubble"]["excentricity"]
        e_x = alpha
        Ry = self.R0 / e_x**(2/3)
        Rx = Ry * e_x
        expression=f"{sq_x} + {sq_y}*{e_x}*{e_x} < {Rx} * {Rx} ?0:1"
        self.run_funkySetFields_command("alpha1",expression,"")        
        
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
        return self.pInf*Rn_old**(3*self.gamma) + 2*self.sigma*Rn_old**(3*self.gamma-1.) - p0*Rdiscr**(3*self.gamma)

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
        p_init = self.pBubble
        Vn    = 4.*np.pi/3.* self.Rn**3  
        Vinit = 4.*np.pi/3.* self.R0**3 
        Einit = (p_init * Vinit - self.pn * Vn)/(self.gamma -1.) + self.pInf*(Vinit - Vn)
        
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
        p_initdiscr = ((self.gamma -1.)*(Einit - self.pInf*(Vinitdiscr-Vn)) + self.pn*Vn) / Vinitdiscr  
        print("adapting Rn...")
        Rndiscr = self._Newton_find_Rn(self,p_initdiscr,Rdiscr,self.Rn)
        pndiscr = self.pInf + 2.*self.sigma/Rndiscr - pV
        print("R_0new      = {}".format(self.R0))
        print("R_n_new     = {}".format(Rndiscr))
        print("pBubble_old = {}".format(pBubble))
        print("pBubble_new = {}".format(p_initdiscr))
        expression = f"{p_initdiscr}*(1.-alpha1)+${self.pVar}*alpha1"
        self.run_funkySetFields_command(self.pVar,expression,"")
        self.pBubble = p_initdiscr
        self.Rn = Rndiscr
        self.pn = pndiscr
        self.R0 = Rdiscr
        
    def adapt_pV(self):
        print("---- setting pressure with same adiabatic constant for discretization ----")
        print("-- reading real discretized alpha2-volume (0/alpha2_vol_t0)")
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
        print("R_0new      = {}".format(self.R0))
        print("R_n_new     = {}".format(Rndiscr))
        print("pBubble_old = {}".format(pBubble))
        print("pBubble_new = {}".format(p_initdiscr))
        expression = f"{p_initdiscr}*(1.-alpha1)+${self.pVar}*alpha1"
        self.run_funkySetFields_command(self.pVar,expression,"")
        self.pBubble = p_initdiscr
        self.R0 = Rdiscr
        
    def set_passiveScalar_layeredColors(self):
        Y = 1.5 * self.Rmax + self.bubble_center
        print(f"---- passiveScalar part till Y: {Y} ----")
        self.run_funkySetFields_command("passiveScalar","1.0","")
        self.run_funkySetFields_command("passiveScalar",f"{y_coord}/{Y}",f"{y_coord} < {Y} ")

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
                os.mkdir(os.path.join(coreDir,"constant"))
                shutil.move(os.path.join(coreDir,"0/polyMesh"),os.path.join(coreDir,"constant"))
                os.removedirs(os.path.join(coreDir,"0"))

        print(f"slots = {threads}, decomposed with {method}")
        
        if os.path.isfile("constant/dynamicMeshDict"):
            for coreDir in procDirs:
                shutil.copy2("constant/dynamicMeshDict",os.path.join(coreDir,"constant"))
        
        os.mkdir("constant/polyMesh/temp")
        shutil.move("constant/polyMesh/*.gz","constant/polyMesh/temp")
        shutil.move("constant/polyMesh/boundary","constant/polyMesh/temp")
        
        
        
        
        
        
        
        
class Mesh(Case):
    def __init__(self):
        super().__init__(pVar="p_rgh",rho2tildeVar="rho_gTilde")
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
        self.origin = self.bubble_center
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
    
        
        
        
        
