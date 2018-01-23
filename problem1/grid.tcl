## \file: grid.tcl
# Grid data structure implementation

package require Itcl

namespace eval mako {}

if { [itcl::is class ::mako::Grid] } { itcl::delete class ::mako::Grid }

##
# \brief Grid class to store the grid data structure
# \description Nested list is used to store for performance 1000X1000 case
# Row major storage followed for point retrieval
# https://en.wikipedia.org/wiki/Row-_and_column-major_order
# index from 0 to M-1 and 0 to N-1 where M and N is size of Grid
itcl::class mako::Grid {
    
	# data members
	public variable M 0
	public variable N 0
	private variable xstep 10
	private variable ystep 10
	private variable lst_gridData {}; # must be private for data integrity
	
	constructor {m n xstep ystep} {
		set M $m
		set N $n
		set xstep $xstep
		set ystep $ystep
		initGridData
	}
	
	destructor {} {}
	
	protected method initGridData {}
	
	public method getPoint {i j}
	public method getPointX {i j}
	public method getPointY {i j}
	public method getGridData { } { return $lst_gridData }
	
	# for debugging only
	# public method printGrid {} { puts $lst_gridData }
}

##
# \brief getPoint list {x y} from lst_gridData using i, j index
# i ranges from 0 to M-1 and j ranges from 0 to N-1
itcl::body mako::Grid::getPoint {i j} {
	# assuming row major storage
	if { $i < $M && $j < $N } {
		set idx [expr ($N*$i + $j)]
		if {$idx >= [llength $lst_gridData]} {
			puts "Warning: Out of bounds..."
			return
		}
		return [lindex $lst_gridData $idx]
	} else {
		puts "Warning: Out of bounds..."
		return
	}
}

# initialize the grid for given xstep and ystep
itcl::body mako::Grid::initGridData { } {
	set xval 0
	set yval 0
	set lst_gridData {}
	
	# generate the gridData using M, N, xstep and ystep
	for {set j 0} {$j < $N} {incr j} {
		# i loop is inside as list is stored in row major
		for { set i 0 } { $i < $M } { incr i } {
			lappend lst_gridData [list $xval $yval]
			incr xval $xstep
		}
		set xval 0
		incr yval $ystep
	}
}

itcl::body mako::Grid::getPointX {i j} {
	set pt [$this getPoint $i $j]
	if { $pt != "" } {
		return [lindex $pt 0]
	} else {
		return ""
	}
}


itcl::body mako::Grid::getPointY {i j} {
	set pt [$this getPoint $i $j]
	if { $pt != "" } {
		return [lindex $pt 1]
	} else {
		return ""
	}
}