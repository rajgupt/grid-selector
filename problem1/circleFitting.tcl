namespace eval mako {}

# circle fitting by using least square method
# cost function is sum of square of residuals w.r.t. circle. Cost = sum((d_i - r_avg)^2)
# minimize cost function by gradient descent method
# ref: https://www.spaceroots.org/documents/circle/circle-fitting.pdf
proc mako::circleFitting { lst_pts } {
	# puts [info level 0]
	if { [llength $lst_pts] < 3 } { 
		tk_messageBox -title "Info" -message "Need minimum 3 point to fit circle"
		return
	}
	
	if { [llength $lst_pts] eq 3 } {
		# 3 point circle fit
		# ref: http://paulbourke.net/geometry/circlesphere/
		lassign [lindex $lst_pts 0] x1 y1
		lassign [lindex $lst_pts 1] x2 y2
		lassign [lindex $lst_pts 2] x3 y3
		
		# reaarange point to avoid inifinite slope case
		if { $x1 eq $x2 && $x2 eq $x3 } {
			tk_messageBox -title info -message "Collinear points detected. Circle fitting failed."
			return
		}
		if { $x1 eq $x2 } {
			# swap 2 with 3
			set tmp $x2
			set x2 $x3
			set x3 $tmp
			set tmp $y2
			set y2 $y3
			set y3 $tmp
		} 
		if { $x3 eq $x2 } {
			# swap 1 with 2
			set tmp $x2
			set x2 $x1
			set x1 $tmp
			set tmp $y2
			set y2 $y1
			set y1 $tmp
		}
		set ma [expr ($y2-$y1)/($x2-$x1)]
		set mb [expr ($y3-$y2)/($x3-$x2)]
		if { $ma ne $mb } {
			set cx [expr ($ma*$mb*($y1-$y3)+$mb*($x1+$x2)-$ma*($x2+$x3))/(2*($mb-$ma))]
			set cy [expr -1*($cx-0.5*($x1+$x2))/$ma + 0.5*($y1+$y2)]
			set r  [expr sqrt(($cx-$x1)**2+($cy-$y1)**2)]
			return [list $cx $cy $r]
		} else {
			tk_messageBox -title info -message "Collinear points detected. Circle fitting failed."
			return
		}
	} else {
		
		# initialize 
		set sumx 0
		set sumy 0
		set N [llength $lst_pts]
		foreach pt $lst_pts {
			set sumx [expr $sumx+[lindex $pt 0]]
			set sumy [expr $sumy+[lindex $pt 1]]
		}
		set sumx [expr double($sumx)]
		set sumy [expr double($sumy)]
		# estimate center
		set a [expr $sumx/[llength $lst_pts]]
		set b [expr $sumy/[llength $lst_pts]]
		set r 0
		set di {}
		set tol 0.00001; # tolerace of min. step
		set gamma 0.1; # const gradient multiplier factor (for simplicity)
		set stepA $a
		set stepB $b
		set cnt 0
		while { $stepA > $tol || $stepB > $tol } {
		
			#estimate r
			set di {}
			foreach pt $lst_pts {
				lappend di [expr sqrt(($a-[lindex $pt 0])**2+($b-[lindex $pt 1])**2)]
			}
			set r [expr ([join $di +])/[llength $di].]
			set gradientA 0
			set gradientB 0
			set idx 0
			foreach pt $lst_pts {
				set gradientA [expr 2*($a-[lindex $pt 0])*([lindex $di $idx]-$r)/[lindex $di $idx]]
				set gradientB [expr 2*($b-[lindex $pt 1])*([lindex $di $idx]-$r)/[lindex $di $idx]]
				incr idx
			}
			# puts "gradient = ( $gradientA , $gradientB )"
			set prevA $a
			set prevB $b
			
			set a [expr $a - $gamma*$gradientA]
			set b [expr $b - $gamma*$gradientB]
			
			set stepA [expr abs($prevA - $a)]
			set stepB [expr abs($prevB - $b)]
			
			incr cnt
			# max number of iterations
			if { $cnt > 100000 } { break }
			# puts "circle = ( $a , $b , $r )"
			# puts "Step = ( $stepA , $stepB )"
		}
		
		# puts "circle = ( $a , $b , $r )"
		# puts "di = $di"
		# calculate cost function
		set cost 0
		set idx 0
		foreach pt $lst_pts {
			set cost [expr $cost+([lindex $di $idx]-$r)**2]
			incr idx
		}
		# puts "cost = $cost"
		return [list $a $b $r]
	}
}