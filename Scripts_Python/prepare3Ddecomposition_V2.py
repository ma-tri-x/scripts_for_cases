#!/bin/python

import json
import os,sys,argparse
import numpy as np

class Decomposer(object):
    def __init__(self,max_iters,tolerance):
        self.max_iters = max_iters
        self.tolerance = tolerance
        with open("the3Dmesh.json",'r') as dic:
            self.mesh_nums = json.load(dic)
        with open("conf_dict.json",'r') as conf:
            self.case_dict = json.load(conf)
        self.L   = self.mesh_nums["L"]
        self.H   = self.mesh_nums["H"]
        self.Xii = self.mesh_nums["Xii"]
        self.X   = self.mesh_nums["Xlen"]
        self.Y   = self.mesh_nums["Y"]
        self.XF  = self.mesh_nums["XF"]
        self.bnum = self.mesh_nums["B"]
        self.cnum = self.mesh_nums["C"]
        self.dnum = self.mesh_nums["D"]
        self.cgrd = self.mesh_nums["Cgrd"]
        self.dgrd = self.mesh_nums["Dgrd"]
        self.cellsize = self.mesh_nums["cellsize"]
        self.step = 0.2*self.cellsize
        
        self.filename = "prepared_distances.dat"

        self.Anum =  self.mesh_nums["X"]*self.mesh_nums["Y"]*self.mesh_nums["Z"]
        self.Bnum = (self.mesh_nums["X"]*self.mesh_nums["Y"]*4. + self.mesh_nums["X"]*self.mesh_nums["Z"])*self.bnum
        self.Cnum = (self.mesh_nums["X"]*self.mesh_nums["Y"]*4. + self.mesh_nums["X"]*self.mesh_nums["Z"])*self.cnum
        self.Dnum = (self.mesh_nums["X"]*self.mesh_nums["Y"]*4. + self.mesh_nums["X"]*self.mesh_nums["Z"])*self.dnum
        self.Total = self.Anum + self.Bnum + self.Cnum + self.Dnum
        
        self.Astep = self.Anum/self.mesh_nums["Y"]
        self.Bstep = self.Bnum/self.bnum
        self.Cstep = self.Cnum/self.cnum
        self.Dstep = self.Dnum/self.dnum
        
        self.maxnprocs     =   self.case_dict["decompose"]["threads"]
        self.nprocs = self.maxnprocs
        self.start_time =   self.case_dict["controlDict"]["startTime"]
        self.dists = []     #always defined from bottom to top
        self.Ns = []
        self.criterion = []
        self.attractor = self.Total/self.nprocs
        
        self.attractor_vs_step = [ self.attractor/i for i in [self.Astep,self.Bstep,self.Cstep,self.Dstep] ]
        print "attractor / smallest amount of cells per step in A: {}".format(self.attractor_vs_step[0])
        print "attractor / smallest amount of cells per step in A: {}".format(self.attractor_vs_step[1])
        print "attractor / smallest amount of cells per step in A: {}".format(self.attractor_vs_step[2])
        print "attractor / smallest amount of cells per step in A: {}".format(self.attractor_vs_step[3])
        self.maxnumnprocs = int(np.sum(np.array(self.attractor_vs_step)))
        print "therefore maximum number of processors: {} with {} cells each".format(self.maxnumnprocs,self.Total/self.maxnumnprocs)
        if self.maxnumnprocs < self.nprocs: 
            print "therefore changing nprocs to maximumnprocs value and adapt attractor value"
            self.change_nprocs(self.maxnumnprocs)
            self.attractor = self.Total/self.maxnumnprocs
    
    def save_dists(self):
        np.savetxt(self.filename,np.array([self.dists,self.Ns,(np.array(self.Ns) - self.attractor)/self.attractor]).T)
    
    def start_setFields_dict(self):
        os.system("cp system/setFieldsDict.template system/setFieldsDict")
        with open("system/setFieldsDict","a") as sfd:
            sfd.write("regions \n       ( \n ")

    def write_box_to_setFields_dict(self,Y,Hpc,i):
        with open("system/setFieldsDict","a") as sfd:
            sfd.write("\n\
                        boxToCell\n\
                        {{\n\
                            box ({} {} {}) ({} {} {});\n\
                            fieldValues\n\
                            (\n\
                                volScalarFieldValue cellDist {}\n\
                            );\n\
                        }}\n".format(-self.L/2.,Y,-self.L/2.,self.L/2.,Y+Hpc,self.L/2.,i))

    def write_sphere_to_setFields_dict(self,R,i):
        with open("system/setFieldsDict","a") as sfd:
            sfd.write("\n\
                        sphereToCell\n\
                        {{\n\
                            centre (0.0 0.0 0.0);\n\
                            radius {};\n\
                            fieldValues\n\
                            (\n\
                                volScalarFieldValue cellDist {}\n\
                            );\n\
                        }}\n".format(R,i))

    def end_setFields_dict(self):
        with open("system/setFieldsDict","a") as sfd:
            sfd.write(");")

    #def distribute_core(self):
        #core_amount = self.Anum
        #if float(self.Total)/self.nprocs < core_amount:
            #core_procs = int(core_amount/(float(self.Total)/self.nprocs))
            #Hpc = self.H/core_procs
            #Y=0.
            #for i in range(core_procs): 
                #self.boxes.append(Y)
                #Y+=Hpc
        #else:
            #self.boxes.append(self.H)

    def iter_over_cells(self,grd,nums, smallest, startx, R):
        x = startx
        size = smallest
        n = 0
        while x < R:
            n += 1
            size = size* grd**(1./(nums-1.))
            x += size
        return n

    def cells_funcR(self,R):
        if R <= self.H:
            #print "A"
            #print int(R/self.H*self.Anum)
            return int(R/self.H*self.Anum)
        elif R < self.Xii:
            vol_of_B = 2./3.*np.pi*R**3        - self.L**2*self.H
            vol_B    = 2./3.*np.pi*self.Xii**3 - self.L**2*self.H
            #print "B"
            #print int(vol_of_B/vol_B*self.Bnum)
            return int(vol_of_B/vol_B*self.Bnum)
        elif R < self.X:
            result = self.Anum + self.Bnum + round(self.iter_over_cells(self.cgrd,self.cnum,self.cellsize,self.Xii,R)/float(self.cnum)*float(self.Cnum))
            #fromC = round(self.iter_over_cells(self.cgrd,self.cnum,self.cellsize,self.Xii,R)/float(self.cnum)*float(self.Cnum))
            #print "C","result:",result,"from C:",fromC,"Cnum=",self.Cnum
            return result
        elif R < self.XF:
            result = self.Anum + self.Bnum + self.Cnum + round(self.iter_over_cells(self.dgrd,self.dnum,self.cellsize*self.cgrd,self.X,R)/float(self.dnum)*self.Dnum)
            #fromD = round(self.iter_over_cells(self.dgrd,self.dnum,self.cellsize*self.cgrd,self.X,R)/float(self.dnum)*self.Dnum)
            #print "D","result:",result,"from D:",fromD,"Dnum=",self.Dnum
            return result
        else:
            return self.Total
        
    def nonlinear_distribute(self):
        prefactor = 1.1
        iterate=True
        while iterate:
            self.dists = []
            self.criterion = [] 
            self.Ns = []
            iterate = False
            R = 0.
            lastN=0
            for proc in range(self.nprocs):
                N=0
                while N < prefactor*self.attractor:
                    R += self.step
                    if R > self.XF: 
                        prefactor *= 0.93
                        iterate = True
                        break
                    N = self.cells_funcR(R) - lastN
                if R > self.XF: 
                    iterate = True
                    break
                self.dists.append(R)
                self.Ns.append(N)
                lastN += N
                print proc, R, N, self.nprocs, prefactor*self.attractor
            self.dists[-1]=self.XF
        #exit(0)
    
    def linear_distribute(self):
        self.dists = []
        self.criterion = [] 
        self.Ns = []
        self.dists = [ (i+1)*self.XF/self.nprocs for i in range(self.nprocs) ]
        self._estimate_cell_amounts()
        for i,j in enumerate(self.dists):
            print i,j,self.Ns[i]
        print "XF = {}".format(self.XF)
        print self.Total, np.sum(np.array(self.Ns))
        #exit(0)
        
    def qubic_distribute(self):
        self.dists = []
        self.criterion = [] 
        self.Ns = []
        a = 10.* self.cellsize
        self.dists = [ ((1.-a)*(float(i+1)/self.nprocs)**self.cgrd + a)*self.XF for i in range(self.nprocs) ]
        self._estimate_cell_amounts()
        for i,j in enumerate(self.dists):
            print i,j,self.Ns[i]
        print "XF = {}".format(self.XF)
        print self.Total, np.sum(np.array(self.Ns))
        #exit(0)
            
    def _estimate_cell_amounts(self):
        self.Ns = []
        N = self.cells_funcR(self.dists[0])
        self.Ns.append(N)
        print self.dists[0],N
        #print self.dists[0],self.Ns[-1]
        #exit(0)
        for i,dist in enumerate(self.dists[1:]): #i starts from 0
            N = self.cells_funcR(self.dists[i+1]) - self.cells_funcR(self.dists[i])
            print i,dist,N
            self.Ns.append(N)
        
    def update_attractor_closeness(self,printout):
        self.criterion = (np.abs((np.array(self.Ns) - self.attractor)/self.attractor ) > float(self.tolerance))
        self.criterion[0] = (np.abs((np.array(self.Ns[0]) - self.attractor)/self.attractor ) > 2.*self.Astep/self.Anum)
        self.criterion[-1] = (np.abs((np.array(self.Ns[-1]) - self.attractor)/self.attractor ) > 2.*self.Dstep/self.Dnum)
        #if self.criterion[-1]: 
            #self.criterion[-1] = False
            #self.criterion[-2] = True
        if printout:
            for i,j in enumerate(self.criterion):
                print "{}, {:.0f}/{} -> {:.0f}\% deviation --> \
                       {} to be altered. Nprocs={}".format(
                           i,
                           self.Ns[i],
                           self.attractor,
                           (self.Ns[i] - self.attractor)/(self.attractor)*100.,
                           j,
                           self.nprocs
                           )

    def read_real_cell_amounts(self):
        os.system('grep \"Number of cells\" log.decomposePar | sed \"s#Number of cells = ##g\" > tmp')
        with open('tmp','r') as temp:
            actual_nums = temp.readlines()
        act_Ns = []
        for i in actual_nums:
            act_Ns.append(float(i.split('\n')[0]))
        act_Ns.reverse()
        self.Ns = list(act_Ns)
    
    def read_nprocs_from_dec_dict(self):
        with open("system/decomposeParDict",'r') as decPD:
            lines = decPD.readlines()
        nprocs = 0
        for line in lines:
            if (line.find("numberOfSubdomains") != -1):
                nprocs = int((line.split(" ")[-1]).split(";")[-2])
                break
        return nprocs
    
    def change_nprocs(self,nprocs): 
        self.nprocs = np.min([nprocs,self.maxnprocs])
        self.attractor = self.Total/self.nprocs
        if not self.read_nprocs_from_dec_dict() == self.nprocs:
            ## change nprocs in decomposeParDict:
            with open("system/decomposeParDict",'r') as decPD:
                lines = decPD.readlines()
            bfline = 0
            for i, line in enumerate(lines):
                if (line.find("numberOfSubdomains") != -1):
                    bfline = i
                    break
            lines[bfline] = "numberOfSubdomains       {};\n".format(self.nprocs) 
            with open("system/decomposeParDict",'w') as decPD:
                for line in lines:
                    decPD.write(line)
            ###----------------------------------
        else:
            print "nprocs hasn't changed in decomposeParDict..."

    def adjust_real_cell_amounts(self):
        #weight = np.abs((np.array(self.Ns) - self.attractor))/self.attractor *np.array(self.criterion)
        #n=2
        #print self.dists
        iterate = False
        #while n>0:
            #index = np.argmax(np.array(weight))
            #if index < len(self.criterion)-1 and index > 0:
                #self.dists[index] = self.dists[index-1] + (self.attractor/self.Ns[index])**(1./3.)*(self.dists[index]-self.dists[index-1])
                #self.criterion[index]=False
            #elif index == 0:
                #self.dists[0] += np.sign(self.attractor-self.Ns[0])*self.step
                #self.criterion[0]=False
            #else:
                #self.dists[-2] = self.dists[-2] + (self.Ns[-1]/self.attractor)**(1./3.)*(self.dists[-1]-self.dists[-2])
                #self.criterion[-1]=False
            #weight = np.abs((np.array(self.Ns) - self.attractor))/self.attractor *np.array(self.criterion)
            #n-=1
        for i,adj in enumerate(self.criterion):
            if adj:
                iterate = True
                if i == 0: 
                    print "dists[0] altered from {}".format(self.dists[0])
                    self.dists[0] -= np.sign(self.Ns[0]/self.attractor-1.)*self.H/self.Y #(self.attractor/self.Ns[0])**(1./3.)*
                    print "to {}".format(self.dists[0])
                elif i == len(self.criterion) - 1 and self.Ns[-1]/self.attractor > 1.:
                    new_interval = (self.XF - self.dists[-2])*self.attractor/self.Ns[-1]
                    x = self.dists[-2]
                    self.dists.pop()
                    while x < self.XF:
                        x += new_interval
                        if len(self.dists) < self.maxnprocs: self.dists.append(x)
                elif i == len(self.criterion) - 1 and self.Ns[-1]/self.attractor < 1.:
                    self.dists.pop()
                else: # i < len(self.criterion)-1: 
                    self.dists[i] = self.dists[i-1] + (self.attractor/self.Ns[i])**(1./3.)*(self.dists[i]-self.dists[i-1])
                    if i < len(self.criterion)-1: self.criterion[i+1] = False
        self.dists.sort()
        self.dists[-1] = self.XF
        return iterate
    
    def sort_dists(self):
        for i in range(self.nprocs-1):
            if self.dists[i+1] < self.dists[i]: self.dists[i+1] = self.dists[i]+self.step

    def setFields(self):
        self.start_setFields_dict()
        reverse_dists = list(self.dists)
        reverse_dists.reverse()
        for i,dist in enumerate(reverse_dists):
            if dist > self.H: self.write_sphere_to_setFields_dict(dist,i)
            elif dist < self.H and i == len(reverse_dists)-1: self.write_box_to_setFields_dict(Y=0.,Hpc=dist,i=i)
            else: self.write_box_to_setFields_dict(Y=reverse_dists[i+1],Hpc=dist,i=i)
        self.end_setFields_dict()
        
        t0 = ""
        if self.start_time == 0.0: t0 = "0"
        else: t0 = "{}".format(self.start_time)

        os.system("cp 0/backup/alpha1.org {}/cellDist".format(t0))
        os.system("sed -i \"s#alpha1#cellDist#g\" {}/cellDist".format(t0))
        
        print "... setting the processor fields into {}/cellDist".format(t0)
        os.system("setFields > log.setFields")
        os.system("gunzip {}/cellDist.gz".format(t0))

        ##read file
        print "... converting {}/cellDist to constant/cellDist ...".format(t0)
        with open("{}/cellDist".format(t0), "r") as cdFile:
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
        print "now you may run decomposePar ..."
        
    def decompose(self):
        os.system('decomposePar > log.decomposePar')
        
    def clean_up(self):
        os.system('rm -rf proc*')
        
    def read_dists_from_file(self):
        print (np.loadtxt(self.filename).T)[0]
        self.dists = (np.loadtxt(self.filename).T)[0]



def main():
    parser = argparse.ArgumentParser()
    #parser.add_argument("-i","--iterate", help="iterate over decomposing with OF", default=False, type=lambda x: (str(x).lower() == 'true'))
    #parser.add_argument("-s","--setFields", help="execute setFields", default=True, type=lambda x: (str(x).lower() == 'true'))
    parser.add_argument("-m","--max_iters", type=int, help="maximum_number of iterations", default=3)
    parser.add_argument("-t","--tolerance", type=float, help="around 0.1", default=0.2)
    parser.add_argument("-F","--fromFile", help="read dists from existing file", default="", type=str)
    args = parser.parse_args()
    
    decomp = Decomposer(args.max_iters,args.tolerance)
    
    if args.fromFile == "":
        decomp.nonlinear_distribute()
        #decomp.linear_distribute()
        #decomp.qubic_distribute()
        #decomp.update_attractor_closeness(printout=False) #not real because calculated

        iterate = True
        n = 0
        while iterate and (n < decomp.max_iters):
            print "----------- iterating over OpenFoam-decompositions"
            print "removing processor dirs..."
            decomp.clean_up()
            print "setting cellDist field..."
            decomp.setFields()
            print "redefining nprocs if necessary..."
            decomp.change_nprocs(len(decomp.dists))
            print "decomposing..."
            decomp.decompose()
            print "reading actual numbers of cells per processor..."
            decomp.read_real_cell_amounts()
            print "saving distances to {}...".format(decomp.filename)
            decomp.save_dists()
            decomp.update_attractor_closeness(printout=True) #real because read-in. printing results
            
            iterate = decomp.adjust_real_cell_amounts()
            n +=1
    else:
        infile = args.fromFile
        if not os.path.isfile(infile):
            print "ERROR dists file not existing!"
            exit(1)
        decomp.filename = infile
        print "reading dists from file..."
        decomp.read_dists_from_file()
        print "removing processor dirs..."
        decomp.clean_up()
        print "setting cellDist field..."
        decomp.setFields()
        print "redefining nprocs if necessary..."
        decomp.change_nprocs(len(decomp.dists))
        print "decomposing..."
        decomp.decompose()
        print "reading actual numbers of cells per processor..."
        decomp.read_real_cell_amounts()
        decomp.update_attractor_closeness(printout=True)

        
        


if __name__=="__main__":
    main()
    
    
    
    
