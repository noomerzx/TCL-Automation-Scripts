if {$argc == 1} {
	set amount [lindex $argv 0]
} else {
	set amount 10
}
list rouString 
list serString 
set status NOT
set inputName "input.txt"
set outputName "config_B.cnf"
source "Library/loadInput.tcl"
if {[string equal $status "READY"]} {
	source "Library/genOutput.tcl"
} else {
	puts "CAN'T WRITE OUTPUT DATA"
}

