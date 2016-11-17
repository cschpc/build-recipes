#!/usr/bin/env python
"""gcc.py is a wrapper for the Cray compiler,
  converting/removing incompatible gcc args.   """

import sys
from subprocess import call
from glob import glob

args2change = {"-fno-strict-aliasing":"",
              "-fmessage-length=0":"",
              "-fstack-protector":"",
              "-funwind-tables":"",
              "-fasynchronous-unwind-tables":"",
              "-fwrapv":"",
              "-Wall":"",
              # "-std=c99":"",
              # "-fPIC":"",
              # "-g":"",
              "-D_FORTIFY_SOURCE=2":"",
              "-DNDEBUG":"",
              "-UNDEBUG":"",
              # "-pthread":"",
              # "-shared":":",
              # "-Xlinker":"",
              # "-export-dynamic":"",
              "-Wstrict-prototypes":"",
              "-dynamic":"-dynamic",
              "-O3":"",
              "-O3":"",
              "-O2":"",
              "-O1":""}

fragile_files = ['c/xc/tpss.c']

cmd = ""
fragile = False
opt = 1
for arg in sys.argv[1:]:
   cmd += " "
   t = arg.strip()
   if t in fragile_files:
       opt = 2
   if t in args2change:
       cmd += args2change[t]
   else:
       cmd += arg

flags_list = {1: "-O3 -funroll-loops -mavx",
             2: "-O2",
             }

flags = flags_list[opt]
cmd = "cc %s %s"%(flags, cmd)

call(cmd, shell=True)
