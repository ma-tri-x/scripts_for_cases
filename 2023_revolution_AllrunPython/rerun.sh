#!/bin/bash

a_date=$(date)

## the following is included now in OFAllFunctionLibrary:
# python3 temps_to_case_files.py

# this wrapper script is only necessary to be backwards compatible with the alias orun

python3 Allrun.py
# 
b_date=$(date)
# 
echo    "script ran from ($a_date) till ($b_date)"
echo -e "\n\n######################### end #########################"
