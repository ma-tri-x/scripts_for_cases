# scripts_for_cases
All the neccessary scripts for setting up a single cavitation bubble case with foam extend.
Meshes are also included.
PostProcessing render scripts are included.
Standard conf_dict.json included
# Minimum scripts for a case to run
The minimum amount of scripts to run a case are included in the folders
"case_sample" and
"Scripts_MinimumPerCase".
# Usage for getting started
Make shure that the foam-extend variables of your installation are sourced, e.g.:
```
source ~/foam/foam-extend-4.0/etc/bashrc
```
then do
```
case_dir=$WM_PROJECT_USER_DIR/01_cavitation_bubble_case
mkdir -p $case_dir
cd $case_dir
git clone https://github.com/ma-tri-x/scripts_for_cases.git
cp -r scripts_repo/case_sample/* .
cp scripts_repo/Scripts_MinimumPerCase/* .
echo "this should be enough to get started. More scripts are found in scripts_repo\n--- Max Shir Koch ---"
```
