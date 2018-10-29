#!/usr/bin/env python
"""Wrapper for the GNU compiler that converts / removes incompatible
   compiler options and allows for file-specific tailoring."""

import sys
from subprocess import call

# Default compiler and options
compiler = 'gcc'
args2change = {}
fragile_files = ['c/xc/tpss.c']
# Default optimisation settings
default_level = 3
default_flags = ['-funroll-loops']
fragile_level = 2
fragile_flags = []

# Sisu (Cray XC40)
if True:
    compiler = 'cc'
    default_flags += ['-march=haswell -mtune=haswell -mavx2']
    fragile_files += ['c/xc/revtpss.c']

# Taito (HP cluster)
if not True:
    compiler = 'mpicc'
    default_flags += ['-ffast-math -march=sandybridge -mtune=haswell']

optimise = None  # optimisation level 0/1/2/3
debug = False    # use -g or not
fragile = False  # use special flags for current file?
sandwich = True  # use optimisation flag twice (= no override possible)

# process arguments
args = []
for arg in sys.argv[1:]:
    arg = arg.strip()
    if arg.startswith('-O'):
        level = int(arg.replace('-O',''))
        if not optimise or level > optimise:
            optimise = level
    elif arg == '-g':
        debug = True
    elif arg in args2change:
        if args2change[arg]:
            args.append(args2change[arg])
    else:
        if arg in fragile_files:
            fragile = True
        args.append(arg)

# set default optimisation level and flags
if fragile:
    optimise = min(fragile_level, optimise)
    flags = fragile_flags
else:
    optimise = max(default_level, optimise)
    flags = default_flags

# add optimisation level to flags
if optimise is not None:
    flags.insert(0, '-O{0}'.format(optimise))
    if sandwich:
        args.append('-O{0}'.format(optimise))
# make sure -g is always the _first_ flag, so it doesn't mess e.g. with the
# optimisation level
if debug:
    flags.insert(0, '-g')

# construct and execute the compile command
cmd = '{0} {1} {2}'.format(compiler, ' '.join(flags), ' '.join(args))
print(cmd)
call(cmd, shell=True)
