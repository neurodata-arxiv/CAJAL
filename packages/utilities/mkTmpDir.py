#!/usr/bin/python

## Make a random named directory in a root directory ##

############################################################################################
## (c) 2012 The Johns Hopkins University / Applied Physics Laboratory.  All Rights Reserved.
## Proprietary Until Publicly Released
############################################################################################

from sys import argv
import string
import random
import os


# read in command line args
params = list(argv)

# Create dir name
directory = os.path.join(params[1],''.join(random.choice(string.ascii_uppercase) for x in range(15)))

# Create directory
os.makedirs(directory)
print "#@@# " + directory + " #@@#"
