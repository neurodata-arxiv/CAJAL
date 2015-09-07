#!/usr/bin/env python

## Template for a basic matlab wrapper for the LONI Pipeline##

## It is assumed that the matlab function that is being called does not create files internally and that any
## file that is output is specified by an input argument.  This allows LONI pipeline to generate/manage filenames.
## If you are creating files internally you must use the advanced wrapping scripts
##
## Your matlab function also should not have any outputs.  You can fprintf a string to the command window and
## using LONI extract the result as an output to pass to the next module.  This is much faster than writing files
## if you are only passing a few values between modules. Other than that all outputs
## should be files that are specified by an input filename argument.
##
## In the LONI module that calls this, the first argument should be your function name without the .m extension.
## It must be on the MATLAB search path (everything inside the framework directory structure is).
## Do NOT include a command line prefix.
## All other arguments should be entered into the LONI module in the same order they are in the matlab function call.
## You MUST include command line prefixes for all arguments indicating their type as described in matlabInit.m
##
## Make sure that you specify the environment variable MATLAB_EXE_LOCATION inside the LONI module.  This can be
## set under advanced options on the 'Execution' tab in the module set up.
#############################################################################
# Copyright 2015 The Johns Hopkins University / Applied Physics Laboratory 
# All Rights Reserved. 
# Contact the JHU/APL Office of Technology Transfer for any additional rights.  
# www.jhuapl.edu/ott
#  
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#  
#     http://www.apache.org/licenses/LICENSE-2.0
#  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#############################################################################

from sys import argv
from sys import exit
#import argv
import sys
import re
import os
from subprocess import Popen,PIPE

# read in command line args
params = list(argv)
del params[0]

# get matlab executible location
matLoc = os.getenv("MATLAB_EXE_LOCATION")

mfile = params[0]
if mfile[0] is os.sep:
    # absolute path
    mfile = params[0]
else:
    # relative path
    # get root directory of framework
    frameworkRoot = os.getenv("CAJAL3D_LOCATION")
    if frameworkRoot is None:
        raise Exception('You must set the CAJAL3D_LOCATION environment variable so the wrapper knows where the framework is!')
    mfile = frameworkRoot + os.sep + params[0]


# Parse arguments and build command string
cmdStr = '-nodesktop -nosplash -nodisplay -r "matlabInit(' + '\'' + mfile + '\''    + ','
del params[0]

for p in params:
    cmdStr = cmdStr + '\'' +  p + '\''	+ ','

cmdStr = cmdStr[:-1]
cmdStr = cmdStr + ')"'

# Make sure there aren't any crazy slashes quotes due to string manipulation for cells
slashes = [match.start() for match in re.finditer(re.escape('\\'), cmdStr)]
cmdStr=list(cmdStr)
for ind in slashes:
    cmdStr[ind]=''
cmdStr=''.join(cmdStr)

# Make sure there aren't any repeated single quotes due to LONI interpretation
doubleQuotes = [match.start() for match in re.finditer(re.escape('\'\''), cmdStr)]
cmdStr=list(cmdStr)
for ind in doubleQuotes:
    cmdStr[ind]=''
cmdStr=''.join(cmdStr)

# call matlab
process = Popen([matLoc, cmdStr], stdout=PIPE, stderr=PIPE)
output = process.communicate()
matError = output[1]
output = output[0]
exit_code = process.wait()

# Check to see if MATLAB itself errored (i.e. seg fault)
if exit_code != 0:
    # it bombed.  Write out matlab errors and return error code
    sys.stderr.write(matError)
    print output
    exit(exit_code)

# Check to see if there was an error message internally to MATLAB (i.e. bug in MATLAB code)
starts = [match.start() for match in re.finditer(re.escape('@@@ MATLAB ERROR'), output)]

if not starts:
    # There wasn't an error.  Print the matlab output to stdout directly
    # Return a zero valued exit code
    print output
else:
    # There was an error.  Extract the error message and write it to stderr.
    # Write the remaining output to stdout
    # Return non-zero exit code

    errorStr = output[starts[0]:starts[1]+43]
    output = output[:starts[0]] + output[starts[1]+44:]
    sys.stderr.write(errorStr)
    print output
    exit(-1)




