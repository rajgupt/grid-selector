## \file: gridGui.tcl
# Grid GUI implementation

package require Tk
package require Itcl

namespace eval mako {
	array unset circle
	array unset marked
	array set circle {}
	array set marked {}
}

if { [itcl::is class ::mako::GridGuiBase] } { itcl::delete class ::mako::GridGuiBase }

itcl::class ::mako::GridGuiBase {
	public variable cv; # canvaspath
	public variable gridObj; # grid data
	public variable width 620
	public variable height 620
	public variable gridMapper
	public variable  gridCenters {}
	
	constructor { gridDataObj } {
		set gridObj $gridDataObj
		set gridMapper [namespace current]::[mako::GridMapper #auto [$gridObj cget -M] [$gridObj cget -N] $width $height]
	}
	
	method createGridOnCanvas { gridDataObj } {
		set gridPoints [$gridDataObj getGridData]
		foreach pt $gridPoints {
			# puts $pt
			set res [$gridMapper getPixelValues [lindex $pt 0] [lindex $pt 1]]
			lappend gridCenters $res
			set xc [lindex $res 0]
			set yc [lindex $res 1]
			
			set r [expr $width/([$gridObj cget -M]*5)]; # 2 percent ratio
			if { $r < 1 } { set r 1 } 
			# puts "center $xc , $yc and radius = $r"
			set item [$cv create oval [expr {$xc-$r}] [expr {$yc-$r}] \
			[expr {$xc+$r}] [expr {$yc+$r}] -fill grey -tags c_[join $res "_"]]
			$cv addtag gridpt withtag $item
		}
	}
	method createGui { parent } {
		# create canvas
		set cv [canvas $parent.cv1 -relief raised -width $width -height $height]
		pack $parent.cv1 -side top -fill x
		
		# $cv bind point <ButtonPress-1> "$c dtag selected"
		$cv create rect 0 0 $width $height -tags base
		
		# create grid circles on canvas
		$this createGridOnCanvas $gridObj
		
		$this addBindings
	}

	method addBindings { } {
		# to be implemented by derived
	}
}

if { [itcl::is class ::mako::GridGuiProblem1] } { itcl::delete class ::mako::GridGuiProblem1 }
itcl::class ::mako::GridGuiProblem1 {

	inherit ::mako::GridGuiBase
	
	constructor { gridDataObj } { ::mako::GridGuiBase::constructor $gridDataObj } { }
	
	# add bindings as per problem 1
	method addBindings { } {
		$cv bind all <ButtonPress-1> "$this onLeftClick $cv %x %y"
		$cv bind all <B1-Motion> "mako::createCircle $cv %x %y"
		$cv bind all <ButtonRelease-1> "$this onMouseRelease"
	}

	
	# algo: one nearest point in radial direction
	method onMouseRelease { } {
		# radius range = avg. of pixel dist as we need only one nearest point in radial direction
		set delta_r [expr 0.5*([$gridMapper cget -xpixelDist]+[$gridMapper cget -ypixelDist])]
		set r_inner [expr ($mako::circle(r) - $delta_r/2)]
		set r_outer [expr ($mako::circle(r) + $delta_r/2)]
		set r_inner_square [expr $r_inner**2]
		set r_outer_square [expr $r_outer**2]
		
		# inner and outer circle and remove blue circle
		$cv create oval [expr $mako::circle(xc)-$r_inner] [expr $mako::circle(yc)-$r_inner] \
						[expr $mako::circle(xc)+$r_inner] [expr $mako::circle(yc)+$r_inner] -tags inner -outline red
		$cv create oval [expr $mako::circle(xc)-$r_outer] [expr $mako::circle(yc)-$r_outer] \
						[expr $mako::circle(xc)+$r_outer] [expr $mako::circle(yc)+$r_outer] -tags outer -outline red
		$cv delete circle

		# mark nearest grid points as blue
		foreach center $gridCenters {
			set d_square [expr ($mako::circle(xc)-[lindex $center 0])**2 + ($mako::circle(yc)-[lindex $center 1])**2]
			# center lies between inner and outer
			if { $d_square < $r_outer_square && $d_square > $r_inner_square } {
				$cv itemconfig c_[join $center "_"] -fill blue
			}
		}
	}
	
	##
	method onLeftClick { c x y } {
		mako::getCenter $c $x $y
		
		# clean up
		$c itemconfig gridpt -fill grey
		$c delete inner
		$c delete outer
		$c delete circle
	}
}


if { [itcl::is class ::mako::GridGuiProblem2] } { itcl::delete class ::mako::GridGuiProblem2 }
itcl::class ::mako::GridGuiProblem2 {

	inherit ::mako::GridGuiBase
	
	constructor { gridDataObj } { ::mako::GridGuiBase::constructor $gridDataObj } { }
	
	# add bindings as per problem 1
	method addBindings { } {
		# $cv bind gridpt <ButtonPress-1> "$this onLeftClick $cv"
		# TODO toggle
		$cv bind gridpt <ButtonPress-1> "
			$cv itemconfig current -fill blue;
			$cv addtag marked withtag current;
		"
	}
	
	method addButtons { } {
		set frm [winfo parent $cv]
		set btnFrm [frame $frm.btnFrm]
		button $btnFrm.btn_generate -text "Generate" -command "$this generate" -width 10
		button $btnFrm.btn_clear -text "Clear" -command "$this clear" -width 10
		pack $btnFrm
		pack $btnFrm.btn_generate $btnFrm.btn_clear -side left -padx 20 -fill x
	}
	
	method generate { } {
		set items [$cv find withtag marked]
		foreach item $items {
			set coords [$cv coords $item]
			set ::mako::marked($item) [list [expr ([lindex $coords 0]+[lindex $coords 2])/2] \
											[expr ([lindex $coords 1]+[lindex $coords 3])/2]]
		}
		$this fitCircle
	}
	
	method clear { } {
		$cv itemconfig marked -fill grey
		$cv dtag marked
		$cv delete fitCircle
		$cv dtag fitCircle
		array unset ::mako::marked
		array set ::mako::marked {}
	}
	
	method fitCircle { } {
		set dict_marked [dict create {*}[array get ::mako::marked]]
		set ret [::mako::circleFitting [dict values $dict_marked]]
		if { [llength $ret] eq 3 } {	
			lassign $ret cx cy r
			$cv create oval [expr $cx-$r] [expr $cy-$r] [expr $cx+$r] [expr $cy+$r]\
						-tags fitCircle -outline red
		} else {
			$this clear
		}
	}
}

## utility procedures

##
#
proc ::mako::getCenter { c x y } {
	set mako::circle(xc) $x
	set mako::circle(yc) $y
}

##
#
proc mako::createCircle { c x y } {
	set dx [expr abs($mako::circle(xc)-$x)]
	set dy [expr abs($mako::circle(yc)-$y)]
	set mako::circle(r) [expr max($dx,$dy)]
	$c delete circle
	set r $mako::circle(r)
	$c create oval [expr $mako::circle(xc)-$r] [expr $mako::circle(yc)-$r] \
				   [expr $mako::circle(xc)+$r] [expr $mako::circle(yc)+$r] \
				   -tags circle -outline blue -width 3
}


