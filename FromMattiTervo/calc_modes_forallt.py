import numpy as np
import csv
import matplotlib.pyplot as plt
import scipy
from scipy import integrate
import os
import time

time1=time.time()

def L(n,x):
    if n==0:
        return 1
    elif n==1:
        return x
    else:
        return (((2 * n)-1)*x * L(n-1, x)-(n-1)*L(n-2, x))/n

def calc_an(n,r,theta): 
    return (2*n+1)/2 *np.trapz(get_integral(r,theta,n),theta)
    
def get_integral(r,theta,n):
    return r*L(n,np.cos(theta))*np.sin(theta)

filenames=[]
for thefile in os.listdir("contour"):
    if thefile.endswith(".csv") and thefile.startswith("bla0"):
        filenames.append(int(thefile.split(".")[1]))
filenames=sorted(filenames)

n=8
for thefile in filenames:
    with open("contour/bla0." + str(thefile) + ".csv") as csvfile:
        theta=[]
        r=[]
        a=[]
        reader = csv.reader(csvfile, delimiter=',', quotechar='\"')
        j=0        
        
        for i,row in enumerate(reader):
            if i == 0:
                for index,item in enumerate(row):
                    if "Points:0" in item:
                        j=index
                        break
            else:
                try:
                    x = float(row[j])
                except(IndexError):
                    print("there is now row[{}] in {} in row number {} of bla0.{}.csv".format(j,row,i,thefile))
                    exit(1)
                y = float(row[j+1])
                theta_temp=np.arctan2(x,y)
                r.append(np.sqrt(x**2+y**2))    
                theta.append(theta_temp)
        r = [x for _,x in sorted(zip(theta,r))]
        theta=np.sort(theta)
        for i in range(n):
            a.append(calc_an(i,r,theta))
        with open("modes.txt", 'a') as modes:
            for i,_ in enumerate(a):
                modes.write(str(a[i]) + " ")
            modes.write("\n")
            
