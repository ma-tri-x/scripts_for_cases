#!/bin/bash

a_date=$(date)

python3 temps_to_case_files.py

python3 Allrun.py
# 
b_date=$(date)
# 
echo    "script ran from ($a_date) till ($b_date)"
echo -e "\n\n######################### end #########################"
