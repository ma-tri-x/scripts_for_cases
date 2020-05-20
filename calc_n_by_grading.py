import numpy as np
import sys

if __name__ == '__main__':
    R = float(sys.argv[1]) # grading
    l = float(sys.argv[2]) # length
    xs = float(sys.argv[3]) # smallest cellsize
    
    length = 0.
    n = 2
    length = xs + xs*R
    while length < l:
        n+=1
        poly = 0.
        r = R**(1./(n-1))
        for i in range(n):
            poly += r**i
        length = xs*poly
    print n
    