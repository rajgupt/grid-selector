## \file: gridGui.tcl
# Grid GUI implementation

package require Tk
package require Itcl

namespace eval mako::GridGui {}

if { [itcl::is class ::mako::GridGui] } { itcl::delete class ::mako::GridGui }


itcl::class GridGui {
	
	
	method createGui { parent }
	method onLeftClick { }
	method onMouseDrag { }
	method onLeftClickRelease { }

}
