#!/bin/python

import sys

if __name__=='__main__':
    try:
        a = sys.argv[1]
        b = sys.argv[2]
        if a in b:
            print("a_is_in_b")
    except:
        pass
