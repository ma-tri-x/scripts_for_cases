import numpy as np
import os,sys,glob,argparse

def radius_2d(alpha_vol, thet):
    #Xi=80e-6
    #Anum=Xi/cellsize
    #Bnum90deg=2*Anum
    #thet=90./Bnum90deg/2.
    theta=thet/180.*np.pi
    return ((alpha_vol)*3./(4.*theta))**(1/3.)

def radius_1d(alpha_vol, thet):
    theta=thet/180.*np.pi
    return ((alpha_vol)*3./(4.*np.tan(theta)**2))**(1/3.)

def radius_3d(alpha_vol, thet):
    return ((alpha_vol)*3./(4.*np.pi))**(1/3.)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--case", help="case dir.", type=str, required=False, default=".")
    parser.add_argument("-d", "--dim", help="dimension", type=str, choices=["1d","2d","3d"], required=False, default="2d")
    
    # NOTE: "This script is written for cases which write theta (half opening angle in degrees)
    #        into THETA file in case dir"
    
    args = parser.parse_args()
    thispath = os.path.dirname(os.path.realpath(__file__))
    fpath = os.path.join(thispath,args.case)
    try:
        with open(os.path.join(fpath,"THETA"),"r") as THETA:
            thet = THETA.readlines()
    except(IOError):
        print("alter your blockMesh-script such that theta is written to THETA file:")
        print("define(writeTheta, [esyscmd(echo '$1' > THETA)])")
        print("and then after theta calc:")
        print("writeTheta(theta)")
        exit(1)
    
    try:
        theta = float(thet[0].split("\n")[0])
        #print("theta = {}".format(theta))
    except(ValueError):
        print("THETA does not contain float content")
        exit(1)    
    
    alpha2path = "postProcessing/volumeIntegrate_volumeIntegral/0/alpha2"
    dpath = os.path.join(fpath, alpha2path)
    a = np.loadtxt(dpath)

    if args.dim == "2d":
        radii = radius_2d(a.T[1],theta)
    elif args.dim == "1d":
        radii = radius_1d(a.T[1],theta)
    else:
        radii = radius_3d(a.T[1],theta)
    print(np.max(radii))
    
if __name__=="__main__":
    main()
