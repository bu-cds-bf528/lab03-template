#!/usr/bin/env python

# argparse is a library that allows you to make user-friendly command line interfaces
import argparse

# here we are initializing the argparse object that we will modify
parser = argparse.ArgumentParser()

# we are asking argparse to require a -i or --input flag on the command line when this
# script is invoked. It will store it in the "filenames" attribute of the object
# we will be passing it via snakemake, a list of all the outputs of verse so we can
# concatenate them into a single matrix using pandas 

parser.add_argument("-i", "--input", help='a GFF file', dest="input", required=True)
parser.add_argument("-o", "--output", help='Output file with region', dest="output", required=True)

# this method will run the parser and input the data into the namespace object
args = parser.parse_args()

# you can access the values on the command line by using `args.input` or 'args.output`

import random

entries = []
with open(args.input, 'rt') as f:
    for line in f:
        if line.startswith('##FASTA'):
            break
        elif line.startswith('#'):
            continue
        else:
            if line.strip().split('\t')[6] == '+':
                entries.append(line.strip().split('\t'))
            
region = entries[10]

with open(args.output, 'w') as w:
    w.write('{}:{}-{}'.format(region[0], region[3], region[4]))
