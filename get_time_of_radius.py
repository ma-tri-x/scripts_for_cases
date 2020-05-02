import numpy as np
import os,sys,glob,argparse

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def radius(alpha_vol, thet):
    #Xi=80e-6
    #Anum=Xi/cellsize
    #Bnum90deg=2*Anum
    #thet=90./Bnum90deg/2.
    theta=thet/180.*np.pi
    return ((alpha_vol)*3./(4.*theta))**(1/3.)

def radius_old(alpha_vol, cellsize=1e-6):
    Xi=80e-6
    Anum=Xi/cellsize
    Bnum90deg=2*Anum
    thet=90./Bnum90deg/2.
    theta=thet/180.*np.pi
    return ((alpha_vol)*3./(4.*theta))**(1/3.)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--radius", help="radius in meters!", type=float, required=True)
    #parser.add_argument("-c", "--cellsize", help="cellsize", type=float, required=True)
    #parser.add_argument("-d", "--mesh_dimensions", help="dimensions of the mesh", type=int, choices=[2], required=False, 
                        #default=2)
    parser.add_argument("-t", "--begin_time", help="time to start scanning", type=float, required=True)
    
    # NOTE: "This script is written for cases which write theta (half opening angle in degrees)
    #        into THETA file in case dir"
    
    args = parser.parse_args()
    fpath = os.path.dirname(os.path.realpath(__file__))
    
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
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, alpha2path)
    
    a = np.loadtxt(dpath)
    times = a.T[0]
    start_index = np.argmin(np.abs(times - args.begin_time))
    radii = radius(a[start_index:].T[1],theta)
    calc_time_index = np.argmin(np.abs(radii - args.radius))
        
    print(times[calc_time_index + start_index])
    
if __name__=="__main__":
    main()
