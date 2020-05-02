import os
import sys
import argparse
import natsort as na
import numpy as np
import matplotlib.pyplot as plt
from scipy import integrate

def path_is_num(path):
    try:
        float(path)
    except ValueError: 
        return False
    else:
        return True
    return False

def path_is_csv(path):
    return path.endswith(".csv")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-A", help="start_time", type=float, required=True)
    parser.add_argument('-B', help="end_time", type=float, required=True)
    parser.add_argument("-f", "--file", help="file with extremeP data", type=str, default="extremeP")
    parser.add_argument("-i", "--integrate_type", help="how to integrate: selfmade trapezoidal or built-in", type=str, default="selfmade", choices=['selfmade','builtin'])
    parser.add_argument("-cy", "--column_y", help="the y value column to integrate", type=int, default=2)
    parser.add_argument("-ct", "--column_t", help="the x value column to integrate", type=int, default=0)
    args = parser.parse_args()
    
    fpath = os.path.dirname(os.path.realpath(__file__))
    dpath = os.path.join(fpath, args.file)
    
    matrix = np.loadtxt(dpath, skiprows=1)
    col_matrix = matrix.T
    
    timeA_idx = np.argmin(np.abs(col_matrix[args.column_t] - args.A))
    timeB_idx = np.argmin(np.abs(col_matrix[args.column_t] - args.B))
    #print '--- integrating from {} till {} ---'.format(matrix[timeA_idx][0],matrix[timeB_idx][0])
    if args.integrate_type == 'selfmade':
        integralselfmade = 0
        for i in range(timeA_idx+1, timeB_idx+1):
            integralselfmade += (matrix[i][args.column_t] - matrix[i-1][args.column_t])*0.5*(matrix[i][args.column_y] + matrix[i-1][args.column_y])
            
        print integralselfmade
        
    else:
        integral = integrate.cumtrapz(col_matrix[args.column_y][timeA_idx:timeB_idx+1],col_matrix[args.column_t][timeA_idx:timeB_idx+1], initial=0)
        
        print integral[-1] # weil integral[0]=0 und int f_A,B = F(B)-F(A) ;-)
    
    
if __name__ == "__main__":
    main()