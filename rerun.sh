#!/bin/bash

a_date=$(date)

python rerun.py && bash Allrun
# 
b_date=$(date)
# 
echo    "script ran from ($a_date) till ($b_date)"
echo -e "\n\n######################### end #########################"
