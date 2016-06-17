### Description

Collection of build recipes for various (scientific) software including
related patches, scripts, and config files.


### Usage

Build recipes are organised in separate directories for each software and may
also include alternative recipes e.g. for different compilers (cf. 'intel/').
For example, the build recipe for GPAW is located in the directory 'gpaw/'.

In addition to the actual build recipe (called 'kommand' [sic] or variations
of thereof) each directory also contains all other files needed to build the
software. These may include anything from patches to config files to
auxiliary scripts.

In order to build a software, simply follow the commands listed in 'kommand'
after editing install paths, module loads etc. to suit your target system.

Please note that the recipes *are not 100% cut-n-paste proof* (even though
that's the aim)! So, please keep your wits about and change directories,
untar packages etc. where needed. :)


### Examples

In each directory there are also actual working examples (in sub-directory
'examples/') that have been used (more or less) succesfully in different
systems. These are named according to the system and version installed.

