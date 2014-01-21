#!/bin/sh

# MATLAB can run scripts, but not functions from the command line. This is what I do:
# File matlab_batcher.sh:
# Call it by entering:
# ./matlab_batcher.sh myfunction myinput
# in neonDSR example call like:
# ./matlab_batcher.sh importLAS_SciDB "'/home/scidb/neon/f100910t01p00r02rdn/lidar/lidar/DL20100901_osbs_FL10_discrete_lidar_NEON-L1B.las',2" 

matlab_exec=/opt/matlab2013a/bin/matlab 
X="${1}(${2})"
echo "cd('/home/scidb/zproject/neonDSR/code/matlab/');" >>  matlab_command.m
echo "addpath('/home/scidb/zproject/neonDSR/code/matlab/');" >>  matlab_command.m 
echo ${X} >> matlab_command.m
cat matlab_command.m
${matlab_exec} -nojvm -nodisplay -nosplash < matlab_command.m
rm matlab_command.m
