#!/bin/python
import os
import sys
import argparse

def clear_dict_from_unwanted_chars(s):
    c = []
    for i in s: c.append((i.replace('\n','')).split(';')[0])
    return c

def extract_subdict(c, args):
    subdict=[]
    append=False
    if args.subdict:
        for i,j in enumerate(c):
            if c[i-2]==args.subdict: append=True
            if j=='}': append=False
            if append: subdict.append(j)
    else:
        return c
    return subdict

def return_line_of_interest(subdict, args):
    for i in subdict:
        if args.query in i:
            return i
        
def get_value(LOI):
    i = LOI.split(" ")
    while i[-1]==" ": i.pop()
    return i[-1]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--query", help="string to search the value from", type=str, required=True)
    parser.add_argument("--subdict", help="subdict to search query from", type=str)
    parser.add_argument("--file", help="file to search in", type=str, required=True)
    args = parser.parse_args()
    
    with open(args.file,'r') as f:
        s = f.readlines()
        
    c = clear_dict_from_unwanted_chars(s)
    
    subdict = extract_subdict(c, args)
    LOI = return_line_of_interest(subdict, args)
    print get_value(LOI)

if __name__ == "__main__":
    main()