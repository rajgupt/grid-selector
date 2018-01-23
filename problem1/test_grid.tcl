# test_grid.tcl

# test script for grid.tcl
#! /usr/bin/env tclsh

source "grid.tcl"

#TODO implement as unittest

# main
mako::Grid gridObj 3 3 10 10

set p11 [gridObj getPoint 1 1]
puts $p11; # 10 10

set p21 [gridObj getPoint 2 1]
puts $p21; # 10 20


