#!/bin/bash

rsync -v get_* scripts_repo/gets/
rsync -v make_* scripts_repo/makes/
rsync -v create_* scripts_repo/creates/
rsync -v fire_* scripts_repo/fires/
for i in plot_*; do
    if [ ! -e $i.backup ]
    then
        rsync -v $i scripts_repo/plots/
    fi
done
rsync -v get_* scripts_repo/gets/
rsync -v Allr* scripts_repo/different_Allruns/
rsync -v constant/polyMesh/*.m4.template scripts_repo/meshes/
rsync -v states scripts_repo/states
rsync -v system scripts_repo/system
rsync -v merge*py scripts_repo/
rsync -v *.backup scripts_repo/
rsync -v calc*py scripts_repo/calcs/
rsync -v check*py scripts_repo/checks/
rsync -v *.json scripts_repo/jsons/
rsync -v render* scripts_repo/renders/
rsync -v prepare* scripts_repo/prepares/
rsync -v produce* scripts_repo/produces/

echo "now please also execute:"
echo "rsync RSYNC_to_scripts_repo.sh scripts_repo/"
