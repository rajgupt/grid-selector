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
	public variable width 420
	public variable height 420
	public variable gridMapper
	
	method createGui { parent }
	method onLeftClick { }
	method onMouseDrag { }
	method onLeftClickRelease { }
	method createGridOnCanvas { guiDataObj }
	
	
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
	$cv bind all <ButtonPress-1> "mako::getCenter $cv %x %y"
	$cv bind all <B1-Motion> "mako::createCircle $cv %x %y"

	
	# just testing
	#set plotFont {Helvetica 18}
	#$cv create line 100 250 400 250 -width 2
	#$cv create line 100 250 100 50 -width 2
	#$cv create text 225 20 -text "A Simple Plot" -font $plotFont -fill brown
	
	# create the ovals on convas using gridData
	# set item [$c create oval [expr {$x-6}] [expr {$y-6}] \
	    [expr {$x+6}] [expr {$y+6}] -width 1 -outline black \
	    -fill SkyBlue2]
		
	# create grid circles on canvas
	$this createGridOnCanvas $gridObj
}

itcl::body ::mako::GridGui::createGridOnCanvas { gridDataObj } {
	set gridPoints [$gridDataObj getGridData]
	foreach pt $gridPoints {
		# puts $pt
		set res [$gridMapper getPixelValues [lindex $pt 0] [lindex $pt 1]]
		set xc [lindex $res 0]
		set yc [lindex $res 1]
		set r [expr $width/([$gridObj cget -M]*10)]; # 1 percent ratio
		if { $r < 1 } { set r 1 } 
		# puts "center $xc , $yc and radius = $r"
		set item [$cv create oval [expr {$xc-$r}] [expr {$yc-$r}] \
	    [expr {$xc+$r}] [expr {$yc+$r}] -fill grey]
		$cv addtag point withtag $item
	}
}

itcl::body mako::GridGui::onLeftClick { } {
	
}


itcl::body mako::GridGui::onMouseDrag { } {
	
}


itcl::body mako::GridGui::onLeftClickRelease { } {
	
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
	}
	
	method getPixelValues { i j } {
		# i j from 0 to M-1 and 0 to N-1
		set xpixelVal [expr $margin + $i*$xpixelDist]
		set ypixelVal [expr $margin + $j*$ypixelDist]
		return [list $xpixelVal $ypixelVal]
	}
}

##
proc ::mako::getCenter { c x y } {
	set mako::circle(xc) $x
	set mako::circle(yc) $y
}

proc mako::createCircle { c x y } {
	set dx [expr abs($mako::circle(xc)-$x)]
	set dy [expr abs($mako::circle(yc)-$y)]
	set d [expr max($dx,$dy)]
	$c delete circle
	$c create oval [expr $mako::circle(xc)-$d] [expr $mako::circle(yc)-$d] \
				   [expr $mako::circle(xc)+$d] [expr $mako::circle(yc)+$d] -tags circle
}