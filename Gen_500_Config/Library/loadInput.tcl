set inputFile [open $inputName r]
set inputData [read $inputFile]
close $inputFile
set lineData [split $inputData "\n"]
set check ""
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
set status READY