set outputFile [ open $outputName w ]
lappend rouList *adh*routeList : S1
puts $outputFile "#############################"
puts $outputFile "SERVICE"
puts $outputFile "#############################"
incr amount
for {set num 1} {$num < $amount} {incr num} {
	foreach sLine $serString {
		regsub -all {IDN_RDF} $sLine "S${num}" text
		if {[regexp {.*serviceId.*} $text]} {
			puts $outputFile "\*S${num}\*serviceId : ${num}"
		} else {
			puts $outputFile "$text"
		}
	}
	if {$num>1} {
		lappend rouList ,S${num}
	}
	puts $outputFile "#############################"
	puts "::::: COMPLETE :: SERVICE S${num}:::::"
}

puts $outputFile "#############################"
puts $outputFile "ROUTE"
puts $outputFile "#############################"

for {set num 1} {$num < $amount} {incr num} {
	foreach rLine $rouString {
		regsub -all {.*.route} $rLine "*adh*routeS${num}.route" text
		regsub -all {IDN_RDF} $text "S${num}" text
		if {[regexp {.*serverId.*} $text]} {
			puts $outputFile "\*adh\*routeS${num}.route\*S${num}\*serviceId : ${num}"
		} else {
			puts $outputFile "${text}"
		}
	}
	puts $outputFile "#############################"
	puts "::::: COMPLETE :: ROUTE S${num}:::::"
}
puts $outputFile "${rouList}"
puts $outputFile "#############################"
close $outputFile