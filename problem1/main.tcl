# Main Application 
# TODO Describe the application and its features
# 1. Grid Data Structure Implementation with Generic Definition ability
# 2. Grid Gui Implementation with adaptive Gui to different Grid Size handling

set scriptDir [file dir [info script]]
source [file join $scriptDir "grid.tcl"]
source [file join $scriptDir "gridGui.tcl"]

# namespace of application
namespace eval mako {
	variable gridObj ""
	variable guiObj ""
	variable top ""
}

proc mako::mainGui { } {
	# set mako::top .
	if { ![winfo exists .] } {
		toplevel $mako::top -width 700 -height 700
	} else {
		. configure -width 700 -height 700
	}
	wm title . "Mako Problem 1: Demo"
	set f [frame .mainFrm]
	pack $f
	return $f
}

proc mako::main { } {
	# create 10 X 10 grid of unit dimension  
	set ::mako::gridObj [namespace current]::[mako::Grid #auto 10 10 1 1]
	# initialize gui
	set frm [mako::mainGui]
	set ::mako::guiObj [namespace current]::[mako::GridGui #auto $::mako::gridObj]
	$mako::guiObj createGui $frm
}

# main call
if { $::argc eq 0 } {
	::mako::main
} else {
	puts "Incorrect argument passed..."
	puts "Usage: wish main.tcl"
}