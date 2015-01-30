set logPath [lindex $argv 0]
set historyRootPath [lindex $argv 1]

regexp {[\d]+_[\_\.\w]+} $logPath sectionName
regexp {(RFACPP|RFANET)[\d]+_[\w]+} $logPath packageName
regexp {[\w]+_[\d]+_[\d]+(_SH|_ST)?} $logPath platformName

cd $logPath
set logList [glob -type f *.log]
foreach log $logList {
	set logSplitedWithDot [split $log "."]
	set logFileName [lindex $logSplitedWithDot 0]
	regsub -all {_EXP} $logFileName {} logTargetFolder
	
	# Ensure that target folder exists
	set historyPath "${historyRootPath}/$sectionName"
	if {![file isdirectory $historyPath/$logTargetFolder]} {
		file mkdir $historyPath/$logTargetFolder
	}
	
	# Copy from original log to target log
	set targetLog "${historyPath}/${logTargetFolder}/${packageName}_${platformName}_${logFileName}.log"
	if {![catch {exec cp -rf ${log} ${targetLog}}]} {
			puts "Copy Original Log : \'${log}\'"
			puts "To Target Log : \'${targetLog}\'"
	}
}