proc GenerateConfig { amt } {
	set inputFile [open "input.txt" r]
	set inputData [read $inputFile]
	close $inputFile
	
	set outputFile [ open "config_A.cnf" w ]
	set lineData [split $inputData "\n"]
	set check ""
	set check2 0
	
	foreach line $lineData {
		if { [string equal $line "SERVICE"] } {
			set check "SERVICE"
			continue
		} elseif {[string equal $line "ROUTE"]} {
			set check "ROUTE"
			continue
		} elseif {[regexp {.*#.*} $line]} {
			continue
		}
		if { [string equal $check "SERVICE"] } {
			lappend serString "${line}"
		} elseif { [string equal $check "ROUTE"] } {
			if {![regexp {.*routeList.*} $line]} {
				lappend rouString "${line}"
			} 
		} 
	}
	
	lappend rouList *adh*routeList : S1
	puts $outputFile "#############################"
	puts $outputFile "SERVICE"
	puts $outputFile "#############################"
	
	for {set num 1} {$num < $amt} {incr num} {
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
	
	for {set num 1} {$num < $amt} {incr num} {
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
}
set amt 501
GenerateConfig $amt