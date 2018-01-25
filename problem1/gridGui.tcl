## \file: gridGui.tcl
# Grid GUI implementation

package require Tk
package require Itcl

namespace eval mako {
	array set circle {}
}

if { [itcl::is class ::mako::GridGui] } { itcl::delete class ::mako::GridGui }


itcl::class ::mako::GridGui {
	
	public variable cv; # canvaspath
	public variable gridObj; # grid data
	public variable width 620
	public variable height 620
	public variable gridMapper
	public variable  gridCenters {}
	method createGui { parent }
	method createGridOnCanvas { guiDataObj }
	method onMouseRelease { }
	
	
	constructor { gridDataObj } {
		set gridObj $gridDataObj
		set gridMapper [namespace current]::[mako::GridMapper #auto [$gridObj cget -M] [$gridObj cget -N] $width $height]
	}
	
}


itcl::body ::mako::GridGui::createGui { parent } {

	# create canvas
	set cv [canvas $parent.cv1 -relief raised -width $width -height $height]
	pack $parent.cv1 -side top -fill x
	
	# $cv bind point <ButtonPress-1> "$c dtag selected"
	$cv create rect 0 0 $width $height -fill yellow
	$cv bind all <ButtonPress-1> "mako::onLeftClick $cv %x %y"
	$cv bind all <B1-Motion> "mako::createCircle $cv %x %y"
	$cv bind all <ButtonRelease-1> "$this onMouseRelease"

	# create grid circles on canvas
	$this createGridOnCanvas $gridObj
}

itcl::body ::mako::GridGui::createGridOnCanvas { gridDataObj } {
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


# algo: one nearest point in radial direction
itcl::body mako::GridGui::onMouseRelease { } {

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

if { [itcl::is class ::mako::GridMapper] } { itcl::delete class ::mako::GridMapper }

##
# Grid mapper from data value to pixel values
itcl::class mako::GridMapper {

	public variable M
	public variable N
	public variable width; # pixels
	public variable height; # pixels
	public variable margin 10; # pixels
	public variable xpixelDist 0; # x dist between adjacent grid point in pixels
	public variable ypixelDist 0; # y dist between adjacent grid point in pixels
	
	constructor { M N width height } {
		set M $M
		set N $N
		set width $width
		set height $height
		set xpixelDist [expr ($width - 2*$margin)/($M-1)]
		set ypixelDist [expr ($height -2*$margin)/($N-1)]
		# correct the margin due to approx pixeldist
		set margin [expr ($width - ($M-1)*$xpixelDist)/2]
	}
	
	# from grid to pixel
	method getPixelValues { i j } {
		# i j from 0 to M-1 and 0 to N-1
		set xpixelVal [expr $margin + $i*$xpixelDist]
		set ypixelVal [expr $margin + $j*$ypixelDist]
		return [list $xpixelVal $ypixelVal]
	}
	
	# from pixel to grid
	method getGridValues { x y } {
		set xgridVal [expr ($x - $margin)/$xpixelDist]
		set ygridVal [expr ($y - $margin)/$ypixelDist]
		return [list $xgridVal $ygridVal]
	}
}


##
proc ::mako::onLeftClick { c x y } {
	mako::getCenter $c $x $y
	
	# clean up
	$c itemconfig gridpt -fill grey
	$c delete inner
	$c delete outer
	$c delete circle
}

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