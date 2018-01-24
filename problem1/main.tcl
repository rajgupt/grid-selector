# Main Application 

namespace eval mako {
	# namespace variables
	
}

proc mako::mainGui { } {
	set w .top
	catch {destroy $w}
	toplevel $w
	wm title $w "Mako Problem 1: Demo"
}

proc mako::main { } {
	# initialize data 
	
	
	
	# initialize gui
	mako::mainGui
	
}
