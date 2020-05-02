#!/bin/python
#import os
#import sys
import argparse
import json

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--query", help="string to search the value from", type=str, required=True)
    parser.add_argument("-s", "--subdict", help="subdict to search query from", type=str)
    parser.add_argument("-f", "--file", help="file to search in", type=str, default="conf_dict.json")
    args = parser.parse_args()

    try:
        with open(args.file,'r') as f:
            conf_dict = json.load(f)
    except(ValueError,IOError):
        print ""
        exit(1)
        
    if args.subdict:
        print conf_dict[args.subdict][args.query]
    else:
        print conf_dict[query]
    

if __name__ == "__main__":
    main()