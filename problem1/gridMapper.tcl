package require Itcl

namespace eval ::mako {}

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