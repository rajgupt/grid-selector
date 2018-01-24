## \file: gridGui.tcl
# Grid GUI implementation

package require Tk
package require Itcl

namespace eval mako {}

if { [itcl::is class ::mako::GridGui] } { itcl::delete class ::mako::GridGui }


itcl::class ::mako::GridGui {
	
	public variable cv; # canvaspath
	method createGui { parent }
	method onLeftClick { }
	method onMouseDrag { }
	method onLeftClickRelease { }

}


itcl::body ::mako::GridGui::createGui { parent } {
	set cv [canvas $parent.cv1 -relief raised -width 450 -height 300]
	pack $parent.cv1 -side top -fill x
	
	# just testing
	#set plotFont {Helvetica 18}
	#$cv create line 100 250 400 250 -width 2
	#$cv create line 100 250 100 50 -width 2
	#$cv create text 225 20 -text "A Simple Plot" -font $plotFont -fill brown

}

itcl::body mako::GridGui::onLeftClick { } {
	
}


itcl::body mako::GridGui::onMouseDrag { } {
	
}


itcl::body mako::GridGui::onLeftClickRelease { } {
	
}

