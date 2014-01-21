#!/bin/sh

# MATLAB can run scripts, but not functions from the command line. This is what I do:
# File matlab_batcher.sh:
# Call it by entering:
# ./matlab_batcher.sh myfunction myinput

matlab_exec=/opt/matlab2013a/bin/matlab 
X="${1}(${2})"
echo "cd('/home/scidb/zproject/neonDSR/code/matlab/');" >  matlab_command_${2}.m
echo "addpath('/home/scidb/zproject/neonDSR/code/matlab/');" >  matlab_command_${2}.m 
echo ${X} > matlab_command_${2}.m
cat matlab_command_${2}.m
${matlab_exec} -nojvm -nodisplay -nosplash < matlab_command_${2}.m
#rm matlab_command_${2}.m
