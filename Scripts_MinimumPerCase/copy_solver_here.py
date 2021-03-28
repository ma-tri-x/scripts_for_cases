import os
import sys
import json
from distutils.spawn import find_executable

def load_configuration(filename):
    #return json.load(open("case_conf.json"))
    return json.load(open(filename))

def main():
    conf_dict = load_configuration("conf_dict.json")
    solverDir = conf_dict["solverControls"]["solverDir"]
    projDir = os.getenv('WM_PROJECT_DIR')
    if not projDir:
        print("first source bashrc of OF version!")
        exit(1)
    solverDirBase = "{}/applications/solvers/multiphase/".format(projDir)
    thisDir = os.path.dirname(os.path.realpath(__file__))
    cmd1 = "cp -r {}{} .".format(solverDirBase,solverDir) 
    cmd2 = "rm -rf {}/{}/Make/linux*".format(thisDir,solverDir)
    cmd3 = "rm -rf {}/{}/.git".format(thisDir,solverDir)
    print(cmd1)
    os.system(cmd1)
    print(cmd2)
    os.system(cmd2)
    print(cmd3)
    os.system(cmd3)
    
if __name__ == '__main__':
    main()