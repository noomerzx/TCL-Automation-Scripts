#!/usr/bin/tclsh
################################################################################
# FILE:    RunScript.tcl
#
# Copyright (C) 2005 Reuters Software (Thailand) Limited.
# All rights reserved.
#
# DESCRIPTION
#
#        The function used to run all test cases or subset of test cases
#        When no arguments RunScript will execute all test cases in all
#        test cases directory (except libs and reports)
#
#        USAGE: wish RunScript.tcl ?directory or filename? ?-options?
#               or 
#               ./RunScript.tcl ?directory or filename? ?-options?
#               options:
#                   -v               verbose (print test steps to stdout)
#                   -vv              debug (simply set global variable DEBUG)
#                   -vvv             super debug (-vv + set EXPECT transcript display)
#                   -vvvs            vvv + a separate window for debug msg
#                   -f <filename>    substitution of the default Config.txt file.
#                   -I <n>           specify iteration run number for log file in report/
#                   -E <ext>         specify log file extension for log file in report/
#                   -S ["c t"]       slowly send Expect's exp_send "c t" is argument of 
#                                    exp_send's -s option. See Expect's manual for detail.
#                                    "c t" is optional. If not defile value "1 0.01" is used
#                   -t               timestamp report.csv file as report_YYMMDDHHMMSS.csv
#                   -K               enable Komposer (GUI script composer)
#                   -check           check integrity of Config.txt and report to user
#                   -nt              enable Expect for Windows to open controlled consoles
#                   -sts ?<docname>? system test specification automation. docname is optional.
#                   -expout          use expOut as expected message of test step (required -sts option)
#                   -c ?<folder>?    ftp the modified configuration files from editConfigFile function to local machine in the specific folder"
#                   -zion_cf <file>  ZION feature: configuration file for updating test result in ZION system
#                                    e.g.  product  = <Product name>
#                                          project  = <Project name>
#                                          round    = <Test round name>
#                                          subround = <Test sub-round name>
#                                          username = <ZION username>
#                                          password = <ZION password>
#                   -zion_id <id>    ZION feature: test matrix id for updating a result
#                   -zion_pf <os>    ZION feature: test platform for updating results
#					-L<dir name>	 Generate the new directory for log file ( custom log file destination that can specific as Full Path and Relative Path )	
#									 Example: <tcl command run>	-L example01	-> The log will be generate at 'currentPath/example01/log/testcaseNo.log'
#
# LIMITATIONS
#        N/A
#
#
# REVISION HISTORY
#
#        Revision 1.0 2005/11/14 Songkiet Pombuppa
#        First Draft
#
#        Revision 1.1 2005/12/07 Songkiet Pombuppa
#        - Support Fatal error to terminate the test immediately.
#        - Support -h and -? switches.
#
#        Revision 1.2 2006/04/01 Wiwat T.
#        common2.0 compat
#        added ... {file mkdir [file dirname [info script]]/report}
#        added #!/usr/bin/wish to facilitate Tk
#        added destroy . to exit Tk parent window
#        added source only .tcl files
#        don't process "Readme.txt" files
#        use lappend auto_path {lib} instead of set auto_path [linsert $auto_path 0 {lib}]
#        added SEPARATE_DEBUG_MSG_WINDOW for using Tk msg windows instead of the terminal
#
#        Revision 2.0.1 2006/05/30 Songkiet P.
#        Merged RFA TTS implementation code:
#		 + Support -S["c t"] to control exp_send to send slowly
#
#        Revision 2.0.2 2006/06/17 Songkiet P.
#        Fixed bug of overrided return function. Use -code return instead of uplevel 
#        to make return affect the caller scope.
#
#        Revision 2.0.3 2006/06/19 Songkiet P.
#        Solve parray bug and interpolate
#
#        Revision 2.0.4 2006/06/19 Wiwat T.
#        Rewrite RunScript.tcl
#        ASSUME_RFA, if set proc return is redifined to suit RFA requirement
#        NO_CATCH, if set catch source $item
#        added "console show" to display console in cygwin wish
#        added catch cleanUp in execTestCase when test scripts fail
#
#        Revision 2.0.5 2006/06/21 Songkiet P.
#        Fixed return function to work with interpolate function.
#
#        Revision 2.0.6 2006/06/21 Wiwat T.
#        added catch cleanUp in execTestCase when test scripts ok
#
#        Revision 2.0.7 2006/06/22 Songkiet P.
#        Interpolate is not the root cause of error. convertFunction (convertBackSlate etc.)
#        is the real root cause. So change the if clause from Interpolate to convert*.
#
#        Revision 2.0.8 2006/06/22 Wiwat T.
#        display elapsed time for each test script
#
#        Revision 2.0.9 2006/06/27 Wiwat T.
#        fixed bug, set result "" when NO_CATCH = 1
#
#        Revision 2.0.10 2006/06/28 Songkiet P.
#        fixed bug#28, return function is updated.
#        fixed collectTestLog bug, maxNumber is increased outside if clause.
#
#        Revision 2.0.11 2006/07/03 Wiwat T.
#        Rewrite of ASSUME_RFA
#        added debug message in execTestCase for catching retCode
#        manage Tk debug window widget
#        filter onle .tcl file to be sourced
#
#        Revision 2.0.12 2006/09/06 Wiwat T.
#        Support [report] in Config.txt for customized report.csv
#        Confit.txt:
#           [report]
#                   usecustomreport  =   yes
#                   column           =   id,result,time,scriptname,detail
#                   id               =   TCID
#                   result           =   default
#                   time             =   default
#                   scriptname       =   FILE
#                   linefail         =   default
#                   detail           =   default
#        catch error loading Tk
#        add -t option for REPORT_FILENAME
#        fixed on glob error at execTestScript by adding -nocomplain
#
#        Revision 2.0.13 2006/09/20 Wiwat T.
#        Komposer, GUI script composer enabled by -K option
#        Need Tk 8.4 or up if would like to use Komposer
#
#        Revision 2.0.14 2006/12/20 Wiwat T.
#        added catch result and display it upon cleanUp
#
#        Revision 2.0.15 2007/03/27 Wiwat T.
#        Added ability to take arguments with spaces/tabs e.g. -f /etc/Config.txt
#
#        Revision 2.0.16 2007/05/23 Wiwat T.
#        Fixed bug introduced by the earlier check-in
#        Fixed log run nummber bug
#        Fixed log files move bug
#        Fixed error message winfo if Tk is not loaded e.g. run with -h
#        Fixed $fileinfo(type) for script can be any type of "file" or "link"
#
#        Revision 2.0.17 2007/06/20 Wiwat T.
#        Added overwrite option in [report]. bug ATT#32
#        Work-around bug #ATT36, #ATT16 by adding pause during execTestCase
#        If return code = OK, then show no more debug message (make the result easy to find)
#
#        Revision 2.1 2007/08/06 Wiwat T.
#        Added run with -check, Config.txt integrity check
#
#        Revision 2.1.1 2007/10/03 Wiwat T.
#        Change to use #!/usr/bin/tclsh
#        Added -nt option to let Expect turn on controlled consoles (Windows Only)
#
#        Revision 2.1.2 2008/02/29 Rachun C.
#        Added -sts option to create system test specification document from automated test scripts
#
#        Revision 2.2 2008/03/04 Rachun C., Wiwat T.
#        Changed -sts option to perform belows:
#            - generate default STS.doc at current directory (no template needed)
#            - able to change default STS name by -sts my_STS.doc
#            - if STS.doc exists then override it automatically
#            - if CREAT_STS is set then skip execTestCase and process only ::ATSTS::load only.
#            - CREATE_STS should has higher priority than execTestCase but lower than CHECK_CONFIG
#            - added an argument for ::ATSTS::load
#
#        Revision 2.2.1 2008/04/24 Rachun C., Rawich K.
#        Added -expout option for automat STS
#
#        Revision 2.2.2 2008/04/24 Rachun C., Rawich K.
#        Fixed bug #ATT92, chenge $item to ${_script}
#        Workaround if $CREAT_STS is set then disable logic negate for ASSUME_RFA
#        Fixed bug -sts-expout
#
#        Revision 2.2.3 2008/07/02 Atthaboon S.
#        Fixed bug ATSTS can't create root section without testscript
#             - Add global ATSTS_COUNT_EXEC_PROC as procedure counter.
#             - Add condition for create root section only first time running.
#        Remove Config.txt from invalid file handling
#
#        Revision 2.2.4 2008/07/04 Atthaboon S.
#        Add catch when create root section from ATSTS.
#        Change regexp for getting name of root section.
#
#        Revision 2.2.5 2008/08/15 Wiwat T.
#        Fixed bug #ATT106. Run with "-f config\Config.txt" now works.
#
#        Revision 2.2.5 2009/10/06 Rachun C.
#        Fixed bug from ASSUME_RFA on returning lists
#
#        Revision 2.2.6 2011/02/24 Rachun C.
#        Added -c option to backup the modified configuration files by editConfigfile function 
#
#        Revision 2.2.7 2012/07/02 Rachun C.
#        Added options to call ZION webservice in order to update test results into ZION
#            options: -zion_cf, -zion_id, -zion_pf
#
#		Revision 2.2.8 2012/07/02 Phuthp T.
#       Change result updating to Zion from 'PASS' to 'PASS-A'.
#            
#		Revision 2.2.9 2012/12/18 Phuthp T.
#       Send 'Fail' to Zion when FATAL_ERROR.
#
#		Revision 2.2.10 2014/01/30 Wisarut P.
#       Added -L option for custom log directory
#
#
################################################################################
#set auto_path   [linsert $auto_path 0 {lib}]
lappend  auto_path {../../../../AUTOMAT_FRAMEWORK/lib}
package require Expect
catch {package require Tk}
package require common 2.0
catch {package require ATSTS}
catch {package require ZION}
namespace import ::common::*

log_user 0
catch {console show}

#**************************************************************************************************
# PROCEDURE 
#        printReport
#
# DESCRIPTION
#        Print the test case result to screen in the pre-defined format.
#        Also print the result into "report/report.csv"
#
# SCOPE
#        Internal
#
# ARGUMENTS
#       item   :  Absolute path name of test case file
#       type   :  Either 'directory' or 'file'
#       level  :  No. of indent text
#       result : OK or FAIL (only use when type = 'file')
#
#****************************************************************************************************
proc printReport {item type {level {0}} {result "FAIL"}} {
    global REPORT
    global REPORT_FILENAME
    set indent ""
    for {set i 0} {$i < $level} {incr i} {
        append indent "  "
    }

    if {$type == "directory"} {
        set formatStr [format "%s%s"    $indent        \
                                        [file rootname [file tail $item] ] \
                      ]
    } elseif {$type == "file"} {
        set formatStr [format "%s%s : %s" $indent        \
                                          [file rootname [file tail $item] ] \
                                          $result                            \
                      ]                      
        set fid [open "$REPORT_FILENAME" "a+"]
        if { [info exists REPORT(column)] && $REPORT(usecustomreport) == "yes" } {
            puts $fid "[formatResult $item $result]"
        } else {
            puts $fid "[file rootname [file tail $item] ],$result"
        }        
        close $fid
    }
    puts stdout $formatStr
}
#**************************************************************************************************
# PROCEDURE 
#        formatResult
#
# DESCRIPTION
#   Format report.csv as specified in Config.txt
#
#           Field       |              descriptions        
#   ____________________|_______________________________________________
#   usescustomreport    | yes: use [report] format
#                       | no : use default format (default)
#   --------------------|-----------------------------------------------
#   format              | csv   (default)
#                       | html
#   --------------------------------------------------------------------
#   overwrite           | yes: report.csv will be overwritten (default)
#                       | no : append report to report.csv
#   --------------------|-----------------------------------------------
#   column              | Column to print. (Limitted only these columns)
#                       | id,result,time,scriptname,detail,runtime
#   --------------------|-----------------------------------------------
#   id                  | keyword to search for id, mostly at the top
#                       | of test script ( e.g. # TCID: 1234 )
#   --------------------|-----------------------------------------------
#   result              | OK,FAIL
#   --------------------|-----------------------------------------------
#   time                | time used by script (hh:mm:ss [+day])
#   --------------------|-----------------------------------------------
#   scriptname          | keyword to search for id, mostly at the top
#                       | of test script ( e.g. # FILE: 1234 )
#   --------------------|-----------------------------------------------
#   linefail            | n/a
#   --------------------|-----------------------------------------------
#   detail              | anything return from return -code ok/error
#   --------------------------------------------------------------------
#   starttime           | date/time
#   --------------------------------------------------------------------
#
# USAGE
#   Put these lines in Config.txt
#
#   [report]
#       overwrite        =   no
#       usecustomreport  =   yes
#       column           =   id,result,starttime,time,scriptname,detail
#       id               =   TCID
#       result           =   default
#       time             =   default
#       scriptname       =   FILE
#       detail           =   default
#       starttime        =   default
#
proc formatResult {item result} {
    global REPORT
    foreach field [split $REPORT(column) ","] {
        set field [string trimleft [string trimright $field]]
        set value ""
        switch -exact -- $field {
            id  {
                if {$REPORT($field) == "default"} {
                    set value [file rootname [file tail $item]]
                } else {
                    if { ![catch {set file [open $item]}] } {      
                        set data [read $file]
                        close $file
                        set lines [split $data "\n"]
                        foreach line $lines {
                            regexp "$REPORT($field)\[ ]*:?\[ ]*(.*)" $line -> value
                        }
                    }
                }
            }
            result  {
                if {$REPORT($field) == "default"} {
                    regexp {(OK|FAIL)} $result -> value
                }
            }
            time  {
                if {$REPORT($field) == "default"} {
                    regexp {Time: (.*)\)} $result -> value
                }
            }
            scriptname  {
                if {$REPORT($field) == "default"} {
                    set value [file tail $item]
                } else {
                    if { ![catch {set file [open $item]}] } {      
                        set data [read $file]
                        close $file
                        set lines [split $data "\n"]
                        foreach line $lines {
                            regexp "^# ?$REPORT($field)\[ ]*:?\[ ]*(.*)" $line -> value
                        }
                    }
                }
            }
            detail  {
                if {$REPORT($field) == "default"} {
                    regexp {(OK|FAIL)[ ]*(.*)[ ]*\(Elapsed} $result -> dontcare value
                }
            }
            starttime  {
                if {$REPORT($field) == "default"} {
                    global START_TIME
                    set value $START_TIME
                }
            }
            default {
                set value ""
            }
        }
        if {![info exists return_str]} {
            set return_str "$value"
        } else {
            set return_str "$return_str,$value"
        }
    }
    return "$return_str"
}

#**************************************************************************************************
# PROCEDURE 
#        collectTestLog
#
# DESCRIPTION
#        Copy the log file of the test case into 'report' directory and rename it so that
#        the log file name have the postfix indicated the running number.
#        For example:
#           "filename_run[runNo].[ext]"
#        Expectation of log name convention in each test cases is:
#        [testcaseId].log
#        [testcaseId]_[any].log
#
# SCOPE
#        Internal
#
# ARGUMENTS
#   item       :  Relative path file name of test case file related to directory the RunScript.tcl
#                 is running. For example:
#                 "04_contribution/01_contribution via RTIC/RFACPP5_LIN_STS04001.tcl"
#
#   runNo      :  The number used to postfix the filename to indicate the cycle of running the
#                 test case. Here is an example of postfixing the log file with run number 5:
#                 "filename.log" > "filename_run05.log
#                 This argument will not be used if the runNo is exist and the 'force' flag is not set.
#
#   force      :  If the file with the new name already exist in 'report' directory. Enable this flag
#                 causes the function overwrites the existing file with the new one.
#                 "-force" for enable.
#
#   ext (log)  :  The new log file extention used for new copy of log file. For example:
#                 "filename.log" > "filename.res"
#
#****************************************************************************************************

proc collectTestLog {item {runNo ""} {force ""} {ext "log"} {logpath}} {
    set TCfullPath [file join [pwd] $item]
    set TCdir      [file dirname $TCfullPath]
    set TCname     [file rootname [file tail $item] ]

    set maxNumber 0
    set runNumber 0
    set dupplicate "false"

    # Retrive the list of log file related to the test case and extension in 'report' dir
    set oldlogs [glob -nocomplain "report/${TCname}_run*.${ext}"]

    # Find maxinum run number and examine that runNo is already exist.
    foreach oldlog $oldlogs {
        scan $oldlog "report/${TCname}_run%d.${ext}" runNumber
        if {$runNumber > $maxNumber} {
            set maxNumber $runNumber
        }
        if {$runNo == $runNumber} {
            set dupplicate "true"
        }
    }

    incr maxNumber

    # If user specify the runNo and no log file of this number exist
    # we use the number user specify. 
    # Otherwisr use maxNumber+1
    if { ($runNo != "") && ($dupplicate == "false") } {
        set maxNumber $runNo
    } elseif { ($runNo != "") && ($dupplicate == "true") && ($force == "-force") } {
        set maxNumber $runNo
    }
	
	# OLD SCRIPT
    # set logfiles [glob -nocomplain "${TCdir}/log/${TCname}_*.log"]
    # lappend logfiles "${TCdir}/log/${TCname}.log"
	
	#----------------------------------------
	# Modified by Noom  # 2.2.10
	if { [string equal $logpath "defaults"] } {
		set logfiles [glob -nocomplain "${TCdir}/log/${TCname}_*.log"]
		lappend logfiles "${TCdir}/log/${TCname}.log"
	} else {
		set logfiles [glob -nocomplain "${logpath}/${TCname}_*.log"]
		lappend logfiles "${logpath}/${TCname}.log"
	}
	#puts "-------------->${logfiles}"
	#----------------------------------------

    foreach logfile $logfiles {
		#puts "------------>example: $logfile"
        if {[file exist $logfile] == 1} {
            set logname [file rootname [file tail $logfile]]
            
            if {$force == "-force"} {
                file copy -force $logfile [format "report/%s_run%02d.%s" $logname $maxNumber $ext]
            } else {
                file copy $logfile [format "report/%s_run%02d.%s" $logname $maxNumber $ext]
            }
        } else {
            puts "ERROR LOG FILE NOT FOUND: $logfile"
        }
    }
}


#**************************************************************************************************
# PROCEDURE 
#        execTestCase
#
# DESCRIPTION
#        Run all test case in the specified directories and subdirectories and print the test result
#        on the screen and create the test report. Also copy the test log into 'report' directory
#        and prefix them with running number.
#
# SCOPE
#        Internal
#
# ARGUMENTS
#       dirList : List of directory or file that want to execute
#       level   : Indicate the directory level used to print the indent
#
#****************************************************************************************************
proc execTestCase {dirList {level {0}}} {
    global CONFIG_FILENAME
    global LOG_RUN_NUMBER
    global LOG_EXTENSION
    global LOG_OVERWRITE
    global DEBUG NO_CATCH
    global START_TIME
    global CREATE_STS
    global ATSTS_COUNT_EXEC_PROC
    global ZION_UPLOAD
	global LOG_PATH
    
    set no_of_pass_testcases 0
    set no_of_fail_testcases 0

    foreach _script $dirList {
        if {[file tail ${_script}] == "lib" ||           \
            [file tail ${_script}] == "config" ||        \
            [file tail ${_script}] == "log" ||           \
            [file tail ${_script}] == "RunScript.tcl" || \
            [file tail ${_script}] == "Readme.txt" || \
            [file tail ${_script}] == "Config.txt" || \
            [file tail ${_script}] == "report" } { 
            continue;       # We do nothing for these system direcoties/files
        }
        
        file lstat ${_script} fileinfo
        if {[regexp {file|link} $fileinfo(type)] && [regexp {\.tcl$} ${_script}]} {
            set start_time [clock seconds]
            set START_TIME [clock format [clock seconds] -format "%a %d/%m/%y %k:%M"]
            # work-around bug #ATT 36,16. Variables not unset in time.
            pause 1
            # Creat only STS, don't execute real scripts
            if {$CREATE_STS} {
                # Create root Section only first time running.
                if {$ATSTS_COUNT_EXEC_PROC == 0} {
                    regexp {([^/\\]+).*} ${_script} -> temp
                    if {$temp != ""} {
                        catch {::ATSTS::run $temp}
                        incr ATSTS_COUNT_EXEC_PROC 1
                    }
                }
                ::ATSTS::run ${_script}
                
                continue
			} elseif {$NO_CATCH} {
					set retCode 0
					set result [source ${_script}] 
			} else {
					set retCode [catch {source ${_script}} result]
					dbgOut "Catch return code: $retCode"
			}
            set end_time [clock seconds]            
            set elapse_time [clock format [expr $end_time - $start_time] -gmt 1 -format {Elapsed Time: %H:%M:%S}]
            set days [expr {($end_time - $start_time) / 86400}]
            if {$days} {set elapse_time "${elapse_time} +$days"}
            if {$retCode == 0} {
                if {$result == 0} {set result ""}
                printReport ${_script} "file" $level "OK $result ($elapse_time)"
                displayTestStep "OK $result ($elapse_time)"
                set tmp_debug $DEBUG
                set DEBUG 0
                if {[catch cleanUp result]} {errOut "cleanUp: $result"}
                incr no_of_pass_testcases
                set DEBUG $tmp_debug
                
                # ZION feature
                if {$ZION_UPLOAD} {
                   ::ZION::updateTestResult $testcase "PASS-A" 
                }
                
            } elseif {$retCode == $::common::FATAL_ERROR } {
                printReport ${_script} "file" $level "FATAL_ERROR $result ($elapse_time)"
                displayTestStep "FATAL_ERROR $result ($elapse_time)"
                if {[catch cleanUp result]} {errOut "cleanUp: $result"}
				
				# ZION feature
                if {$ZION_UPLOAD} {
                   ::ZION::updateTestResult $testcase "FAIL"
                }
				
				
                break
            } else {
                printReport ${_script} "file" $level "FAIL $result ($elapse_time)"
                displayTestStep "FAIL $result ($elapse_time)"
                incr no_of_fail_testcases
                if {[catch cleanUp result]} {errOut "cleanUp: $result"}
                    
                # ZION feature
                if {$ZION_UPLOAD} {
                   ::ZION::updateTestResult $testcase "FAIL"
                }
            }
            
            if {$LOG_OVERWRITE == "true"} { set force "-force" } else { set force "" }
			
			# OLD SCRIPT # before 2.2.10 # collectTestLog ${_script} $LOG_RUN_NUMBER $force $LOG_EXTENSION
            #----------------------------------------
			# Modified by Noom # 2.2.10 # added new parameter LOG_PATH for copying log to report 
			collectTestLog ${_script} $LOG_RUN_NUMBER $force $LOG_EXTENSION $LOG_PATH
			#----------------------------------------
		
        } elseif {$fileinfo(type) == "directory"} {
            printReport ${_script} "directory" $level
            execTestCase [lsort [glob -nocomplain [file join ${_script} *]]] [expr $level+1]
        } else {
            puts "Invalid file: ${_script}"
        }
    }
}
#**************************************************************************************************
# PROCEDURE 
#        optParse
#
# DESCRIPTION
#        Parsing options begin with "-" and configure them
#
# SCOPE
#        Internal
#
# ARGUMENTS
#       argv    : List of arguments
#                   -v              verbose (print test steps to stdout)
#                   -vv             debug (simply set global variable DEBUG)
#                   -vvv            super debug (-vv + set EXPECT transcript display)
#                   -vvvs           vvv + a separate window for debug msg
#                   -f<filename>    substitution of the default Config.txt file.
#                   -I<n>           specify iteration run number for log file in report/
#                   -E<ext>         specify log file extension for log file in report/
#                   -S["c t"]       slowly send Expect's exp_send "c t" is argument of 
#                                   exp_send's -s option. See Expect's manual for detail.
#                                   "c t" is optional. If not defile value "1 0.01" is used
#                   -t              timestamp report.csv file as report_YYMMDDHHMMSS.csv
#                   -K              enable Komposer (GUI script composer)
#                   -check          check integrity of Config.txt and report to user
#                   -nt             enable Expect for Windows to open controlled consoles
#					-L<dir name>	Generate the new directory for log file ( custom log file destination that can specific as Full Path and Relative Path )	
#									Example: <tcl command run>	-L example01	-> The log will be generate at 'currentPath/example01/log/testcaseNo.log'
#
#****************************************************************************************************
proc optParse { argv } {
	#----------------------------------------
	# Modified by Noom # variable for custom log directory path
	global LOG_PATH
	#----------------------------------------
    global CONFIG_FILENAME
    global LOG_RUN_NUMBER
    global LOG_EXTENSION
    global LOG_OVERWRITE
    global DEBUG
    global VERBOSE
    global INVALID_ARGUMENT
    global SEPARATE_DEBUG_MSG_WINDOW
    global ENABLE_SEND_SLOW
    global SLOW_PARAM
    global REPORT_FILENAME
    global KOMPOSER
    global CHECK_CONFIG
    
    # System Test Spec feature
    global CREATE_STS
    global STS_OUTPUT_FILE
    global EXP_OUT    
    global HINT
    
    # ZION feature
    global ZION_UPLOAD
    global ZION_CONFIG
    global ZION_TEST_MATRIX_ID
    global ZION_TEST_PLATFORM
    
    # Backup editconfig feature
    global DO_BACKUP_MODIFIEDFILE
    global BACKUP_MODIFIEDFOLDER
    
	# Added -L Description in 'help(-h)' by noom
    foreach item $argv {
        if { [regexp {^-h$} $item] || \
             [regexp {^-?$} $item] } {
             puts stdout "USAGE: ./RunScript.tcl ?directory or file? ?-option? ?-option? ..."
             puts stdout " Options:"
             puts stdout "  -f <absolute_path_config_file>"
             puts stdout "     Specify your custom config file other than the default one"
             puts stdout "     i.e. config.txt at same directory of RunScript.tcl"
             puts stdout "     Example: -fD:\\myconfig\\config_contribution.txt"
             puts stdout "            : -f D:\\myconfig\\config_contribution.txt"
             puts stdout ""
             puts stdout "  -I <running_number>"
             puts stdout "     Specify number used to no. of running the test. This number"
             puts stdout "     appear in log file e.g. \[TestCaseID\]_run03.log"
             puts stdout "     Example: -I3"
             puts stdout "            : -I 3"
             puts stdout ""
             puts stdout "  -E <file_extension>"
             puts stdout "     Specify the custom extension of log file (.log is default)"
             puts stdout "     e.g. \[TestCaseID\]_run03.res"
             puts stdout "     Example: -Eres"
             puts stdout "            : -E res"
             puts stdout ""
			 puts stdout "  -L <directory_name>"
			 puts stdout "	   Generate the new directory for log file"
			 puts stdout "	   ( Custom log file destination that can specific as Full Path and Relative Path ) "
			 puts stdout "	   Example : <tcl command run> -L example01 "
			 puts stdout "	         --> The log will be generate at 'currentPath/example01/log/testcaseNo.log'"
             puts stdout ""
             puts stdout "  -v"
             puts stdout "     Print test step to the standard output"
             puts stdout ""
             puts stdout "  -vv"
             puts stdout "     Print both test step and debug message to the standard output"
             puts stdout ""
             puts stdout "  -vvv"
             puts stdout "     Same as -vv and enable tcl/expect debug message"
             puts stdout ""
             puts stdout "  -vvvs"
             puts stdout "     Same as -vvv with a separate window for debug msg"
             puts stdout ""
             puts stdout "  -S \[\"c t\"\]"
             puts stdout "     slowly send Expect's exp_send \"c t\" is argument of"
             puts stdout "     exp_send's -s option. See Expect's manual for detail."
             puts stdout "     \"c t\" is optional. If not defile value \"1 0.01\" is used"
             puts stdout "     Example: -S\[\"1 1\"]"
             puts stdout "            : -S \[\"1 1\"]"
             puts stdout ""
             puts stdout "  -t"
             puts stdout "     timestamp report.csv file as report_YYMMDDHHMMSS.csv"
             puts stdout ""
             puts stdout "  -K"
             puts stdout "     enable Komposer (GUI script composer)"
             puts stdout ""
             puts stdout "  -check"
             puts stdout "     check integrity of Config.txt and report to user"
             puts stdout ""
             puts stdout "  -nt"
             puts stdout "     enable Expect for Windows to open controlled consoles"
             puts stdout ""
             puts stdout "  -sts ?<docname>?"
             puts stdout "     system test specification automation. docname is optional."
             puts stdout "     Example: -sts D:\\path_to\\STS.doc"
             puts stdout "            : -sts=D:\\path_to\\STS.doc"
             puts stdout "            : -sts"
             puts stdout ""
             puts stdout "  -expout"
             puts stdout "     use expOut as expected message of test step (required -sts option)"
             puts stdout ""
             puts stdout "  -hint"
             puts stdout "     match regular expression to expected message in test log file (required -sts option)"
             puts stdout ""
             puts stdout "  -c ?<folder>?"
             puts stdout "     ftp the modified configuration files from editConfigFile function to local machine in the specific folder"
             puts stdout "     Example: -c modifiedFolder   the configuration files will be backup to \"modifiedFolder\""
             puts stdout "            : -c                  \"Config\" folder will be used by default"
             puts stdout ""
             puts stdout "  -zion_cf <ZION configuration file>"
             puts stdout "     configuration file of test matrix in order to submit test results to ZION system"
             puts stdout "     Example: -zion_conf config-zion.txt"
             puts stdout "     In The file:   "
             puts stdout "        product  = <Product name>"
             puts stdout "        project  = <Project name>"
             puts stdout "        round    = <Test round name>"
             puts stdout "        subround = <Test sub-round name>"
             puts stdout "        username = <ZION username>"
             puts stdout "        password = <ZION password>"
             puts stdout ""
             puts stdout "  -zion_id <ZION test matrix id>"
             puts stdout "     test matrix id from ZION system for updating test result "
             puts stdout "     (required if -zion_cf is specified but no -zion_pf)"
             puts stdout "     Example: -zion_id 65523"
             puts stdout ""
             puts stdout "  -zion_pf <ZION test platform>"
             puts stdout "     test platform for updating test result in ZION system"
             puts stdout "     (required if -zion_cf is specified but no -zion_id)"
             puts stdout "     Example: -zion_pf \"RHEL4.32 - RRCA\""
             puts stdout ""
             puts stdout "  -h or -?"
             puts stdout "     Print this help"
             puts stdout " "    
             puts stdout " Directories name:"
             puts stdout "  Specify list of the specific directories to run the test. "
             puts stdout "  Default is all directories at the same level of RunScript.tcl"
             puts stdout "  except key directories e.g. report lib"
			 
             
             set INVALID_ARGUMENT 1
             continue
         }
            
        if { [regexp {^-f(.*)} $item -> config_file] } {
            set CONFIG_FILENAME $config_file
            continue
        }
        if { [regexp {^-v$} $item] } {
            set VERBOSE 1              
            continue
        }
        if { [regexp {^-vv$} $item] } {
            set VERBOSE 1
            set DEBUG 1              
            continue
        }
        if { [regexp {^-vvv$} $item] } {
            set VERBOSE 1
            set DEBUG 1
            log_user 1  
            continue
        }
        if { [regexp {^-vvvs$} $item] } {
            set VERBOSE 1
            set DEBUG 1
            log_user 1
            set SEPARATE_DEBUG_MSG_WINDOW 1
            continue
        }
        if { [regexp {^-I(.*)} $item -> runNo] } {
            set LOG_RUN_NUMBER $runNo
            continue
        }
        if { [regexp {^-E(.*)} $item -> ext] } {
            set LOG_EXTENSION $ext
            continue
        }
        if { [regexp {^-F$} $item] } {
            set LOG_OVERWRITE "true"
            continue
        }
		#----------------------------------------
		# Modified by Noom # 2.2.10 #get argv for generate custom log directory
		if { [regexp {^-L(.*)} $item -> logpath] } {
            regsub -all {\\} $logpath {/} logpath
			set LOG_PATH $logpath
            continue
        }
		#----------------------------------------
        if { [regexp {^-S(.*)} $item -> slow_param] } {
            set ENABLE_SEND_SLOW "true"

            if {$slow_param != ""} {
                set SLOW_PARAM $slow_param
            } else {
                set SLOW_PARAM "1 0.01"
            }

            continue
        }
        if { [regexp {^-t$} $item] } {
            set REPORT_FILENAME "report/report_[clock format [clock seconds] -format %Y%m%d%H%M%S].csv"
            continue
        }
        if { [regexp {^-K$} $item] } {
            set KOMPOSER 1
            continue
        }
        if { [regexp {^-check$} $item] } {
            set CHECK_CONFIG 1
            continue
        }
        if { [regexp {^-nt$} $item] } {
            catch {set exp::winnt_debug 1}
            continue
        }
        if { [regexp {^-sts(.*)} $item -> output] } {
            set CREATE_STS 1
            if {$output == ""} {
                set STS_OUTPUT_FILE "STS.doc"
            } else {
                set STS_OUTPUT_FILE $output
            }
            continue
        }
        if { [regexp {^-expout$} $item] } {
            catch {set EXP_OUT 1}
            continue
        }
	if { [regexp {^-hint$} $item] } {
            catch {set HINT 1}
            continue
        }
        if { [regexp {^-c(.*)} $item -> output] } {
            set DO_BACKUP_MODIFIEDFILE 1
            if {$output == ""} {
                set BACKUP_MODIFIEDFOLDER "config"
            } else {
                set BACKUP_MODIFIEDFOLDER $output
            }
            regsub -all -- {\\} $BACKUP_MODIFIEDFOLDER {/} BACKUP_MODIFIEDFOLDER 
            continue
        }
        if { [regexp {^-zion_cf(.*)} $item -> config_file] } {
            set ZION_CONFIG $config_file
            set ZION_UPLOAD 1
            continue
        }
        if { [regexp {^-zion_pf(.*)} $item -> platform] } {
            set ZION_TEST_PLATFORM $platform
            continue
        }
        if { [regexp {^-zion_id(.*)} $item -> matrix_id] } {
            set ZION_TEST_MATRIX_ID $matrix_id
            continue
        }
        # if option does not begin with "-" then ignore it.(e.g. directory name)
        continue
    }
}

#**************************************************************************************************
# PROCEDURE 
#        checkConfig
#
# DESCRIPTION
#        Try to check integrity of Config.txt and report to user
#
# SCOPE
#        Internal
#
# ARGUMENTS
#
#****************************************************************************************************
proc checkConfig {} {
    catch {wm withdraw .} 
    package require File
    global CONFIG_FILENAME
    regsub -all {\\} $CONFIG_FILENAME {\\\\} filename
    puts "---------------------------------------------------------------"
    puts "Config.txt = $filename"
    puts "---------------------------------------------------------------"
    # read Config.txt into arrays
    if { ![catch {set file [open $filename]}] } {      
        set data [read $file]
        close $file
        set isConfig 0
        set lines [split $data "\n"]
        
        foreach line $lines {
            set line [string trimleft $line]
            if { [ regexp {^\[service_names\]|^\[metadata\]} $line ] } {
                set isConfig 0
            } elseif { [regexp {^\[([^\]]+)} $line -> token] } {
                set isConfig 1
                global $token
                lappend token_list $token
            } elseif { (![regexp {^#} $line]) && $isConfig} { 
                if {[regexp {([^=]*)=(.*)} $line -> key value]} {
                    set key [string trimright $key]
                    set value [string trimleft $value]
                    array set ${token} [list $key $value]
                }
            }
        }
    } else {
        return -code error "ERROR: Cannot locate $filename. Abort !!"
    }
    #infOut "token_list: $token_list"
    # Test each token properties
    foreach token $token_list {
        puts "\n$token"
        # Check machineList first
        foreach {key value} [array get $token] {
            switch -regexp -- $key {
                "^machineList$" {
                    if {![catch {connect ::$token}]} {
                        checkConfigResult $key "OK ($value)"
                    } else {
                        checkConfigResult $key "FAIL ($value)"
                    }
                }
                default {
                }
            }
        }
        # Check other properties
        foreach {key value} [array get $token] {
            switch -regexp -- $value {
                "^\{" {
                }
                "^/" {
                    if {![catch {::File::ls ::$token $value}]} {
                        checkConfigResult $key "OK"
                    } elseif {[file exists $value] && ![info exists ::${token}(spawn_id)]} {
                        checkConfigResult $key "OK"
                    } else {
                        checkConfigResult $key "FAIL ($value)"
                    }
                }
                "^\\./|\\.\[a-zA-Z0-9]" {
                    catch {::File::cd ::$token}
                    set value [lindex $value 0]
                    if {![catch {::File::ls ::$token $value}]} {
                        checkConfigResult $key "OK"
                    } elseif {[file exists $value] && ![info exists ::${token}(spawn_id)]} {
                        checkConfigResult $key "OK"
                    } else {
                        checkConfigResult $key "FAIL ($value)"
                    }
                }
                default {
                    checkConfigResult $key "-"
                }
            }
        }
    }
    # Nicely close spawned processes
    foreach token $token_list {
        foreach {key value} [array get $token] {
            if {$key == "spawn_id"} {
                catch {close -i $value}
                wait
            }
        }
    }
    if {![catch {winfo children .}]} {
        while { [winfo children .] != "" } {
            # do nothing until user has closed all Tk windows
            update
            pause 0.5
        }
    }
    catch {destroy . }
}
proc checkConfigResult {key result} {
    puts [format "    %-*s : %s" 25 $key "$result"]
}
#**************************************************************************************************
# Main execution starts here
#**************************************************************************************************
global DEBUG
global VERBOSE
global CONFIG_FILENAME
global LOG_RUN_NUMBER
global LOG_EXTENSION
global LOG_OVERWRITE
global INVALID_ARGUMENT
global RUNSCRIPT
global ENABLE_SEND_SLOW
global SLOW_PARAM
global ASSUME_RFA
global DEBUG_RETURN
global NO_CATCH
global REPORT
global REPORT_FILENAME
global KOMPOSER
global TK
global CHECK_CONFIG
global CREATE_STS
global ATSTS_COUNT_EXEC_PROC
global STS_OUTPUT_FILE
global EXP_OUT
global HINT
global DO_BACKUP_MODIFLEDFILE
global BACKUP_MODIFIEDFOLDER

# Added by noom # 2.2.10 # variable for custom log directory
global LOG_PATH
set LOG_PATH	"defaults"

set DEBUG 0
set VERBOSE 0
set CONFIG_FILENAME [file join [pwd] "Config.txt"]
set LOG_RUN_NUMBER  ""
set LOG_EXTENSION   "log"
set LOG_OVERWRITE   "false"
set INVALID_ARGUMENT 0
set RUNSCRIPT 1
set ENABLE_SEND_SLOW "false"
set SLOW_PARAM       "1 0.01"
set ASSUME_RFA 1
set DEBUG_ASSUME_RFA 1
set NO_CATCH 0
set REPORT_FILENAME "report/report.csv"
set KOMPOSER 0
set CHECK_CONFIG 0
set TK 0
set CREATE_STS 0
set EXP_OUT 0
set ATSTS_COUNT_EXEC_PROC 0
set HINT 0
set DO_BACKUP_MODIFIEDFILE 0
set BACKUP_MODIFIEDFOLDER ""

# ZION feature
set ZION_UPLOAD 0
set ZION_CONFIG ""
set ZION_TEST_MATRIX_ID ""
set ZION_TEST_PLATFORM ""

# option and its value can have spaces, equal sign
set i [lsearch -exact $argv {-f}]
if {$i > -1} {
    regsub -- "-f" $argv [list -f[lindex $argv [incr i]]] argv
    set argv [lreplace $argv $i $i]
}
# handle spaces in option value
set i [lsearch -exact $argv {-zion_cf}]
if {$i > -1} {
    regsub -- "-zion_cf" $argv [list -zion_cf[lindex $argv [incr i]]] argv
    set argv [lreplace $argv $i $i]
}
set i [lsearch -exact $argv {-zion_pf}]
if {$i > -1} {
    regsub -- "-zion_pf" $argv [list -zion_pf[lindex $argv [incr i]]] argv
    set argv [lreplace $argv $i $i]
}
#----------------------------------------
# Modified by Noom # 2.2.10 #
set i [lsearch -exact $argv {-L}]
if {$i > -1} {
    regsub -- "-L" $argv [list -L[lindex $argv [incr i]]] argv
    set argv [lreplace $argv $i $i]
}
#----------------------------------------
regsub -all -- "-f\[ \t=]+" $argv "-f" argv
regsub -all -- "-I\[ \t=]+" $argv "-I" argv
regsub -all -- "-E\[ \t=]+" $argv "-E" argv
regsub -all -- "-S\[ \t=]+" $argv "-S" argv
regsub -all -- "-sts\[ \t=]+" $argv "-sts" argv
regsub -all -- "-sts-" $argv "-sts -" argv
regsub -all -- "-c\[ \t=]+(?!-)" $argv "-c" argv
regsub -all -- "-c{" $argv "{-c" argv
regsub -all -- "-zion_cf\[ \t=]+" $argv "-zion_cf" argv
regsub -all -- "-zion_id\[ \t=]+" $argv "-zion_id" argv
regsub -all -- "-zion_pf\[ \t=]+" $argv "-zion_pf" argv

# Filter out options begin with "-"
foreach item $argv { 
    if {[string match "-*" $item] != 1} {
        lappend runList $item
    }
}

# Create list of direcory if no argument is specified
if {[info exist runList] == 0} {
    set runList [lsort [glob [file join [pwd] *]]]
}

# Options parsing and setting
optParse $argv

# See if custom report.csv defined in Config.txt
# normally tokenized by [report.csv]
#
if { ![catch {set file [open $CONFIG_FILENAME]}] } {      
    set data [read $file]
    close $file
    set isConfig 0
    set lines [split $data "\n"]
    foreach line $lines {
        set line [string trimleft $line]
        if { [ regexp {^\[report]} $line ] } {
            set isConfig 1
        } elseif { [regexp {^\[} $line] } {
            set isConfig 0
        } elseif { (![regexp {^#} $line]) && $isConfig} { 
            if {[regexp {([^=]*)=(.*)} $line -> key value]} {        
                set key [string trimright $key]
                set value [string trimleft $value]
                set REPORT($key) $value
            }
        }
    }
} else {
    return -code error "RunScript.tcl: Cannot open $CONFIG_FILENAME"
}

# Print the header of the report and clean the content
if {![file isdirectory [pwd]/report]} {file mkdir [pwd]/report}
# overwrite report.csv?
if { [info exists REPORT(overwrite)] && $REPORT(overwrite) == "no" } {
    set fid [open "$REPORT_FILENAME" "a+"]
    puts $fid ""
} else {
    set fid [open "$REPORT_FILENAME" "w+"]
}
if { [info exists REPORT(column)] && $REPORT(usecustomreport) == "yes" } {
    puts $fid "$REPORT(column)"
} else {
    puts $fid "TestCaseId,Result"
}
close $fid

if {$ENABLE_SEND_SLOW == "true"} {
    rename ::exp_send ::exp_send_orig

    proc ::exp_send {args} {
      global SLOW_PARAM

      upvar 1 send_slow local_send_slow

      set local_send_slow $SLOW_PARAM
      uplevel 1 exp_send_orig -s $args
    }
}

# ZION feature
if {$ZION_UPLOAD} {
    if {$ZION_TEST_MATRIX_ID == "" && $ZION_TEST_PLATFORM == ""} {
        puts "Error: RunScript.tcl requires options for ZION feature"
        exit
    }
    ::ZION::loadConfig $ZION_CONFIG
    ::ZION::setTestMatrixId $ZION_TEST_MATRIX_ID
    ::ZION::setTestPlatform $ZION_TEST_PLATFORM
}

if {$ASSUME_RFA && !$CREATE_STS} {
#**************************************************************************
# PROCEDURE 
#        return
#
# DESCRIPTION
#   For Framework 1.x compatible
#   1.x return only 0 or 1 for PASS and FAIL respectively
#   2.x return -code ok 0, -code error "msg", return true, return false
#   Function convert the following return value
#   '-code ok'     -> 0
#   '-code error'  -> 1
#   'true'         -> 0
#   'false'        -> 1
#   Other value that above is not converted.
#
#   NOTE! This only affect in library namespace. So you can use 'return -code'
#         at the test case script level as usual.
#
# ARGUMENTS
#        args  : accept all parameter from original return function
#
#************************************************************************** 
    rename ::return ::return_orig
    proc ::return args {
        global DEBUG_ASSUME_RFA
        if {[uplevel 1 namespace current] != "::" && [uplevel 2 namespace current] != "::"} {
            if {$DEBUG_ASSUME_RFA} {
            infOut "\[ASSUME_RFA] (lib <--return-- lib) NO CHANGE of return value."
            infOut "\[ASSUME_RFA] Caller : [info level -1]"
            infOut "\[ASSUME_RFA] \$args = $args"
            }
            switch -regexp -- $args {
                "^-code[\t ]+ok"    {if {$DEBUG_ASSUME_RFA} {dbgOut "return: [lindex $args 2]"};return_orig -code return [lindex $args 2]}
                "^-code[\t ]+error" {if {$DEBUG_ASSUME_RFA} {dbgOut "eval return_orig $args"};eval return_orig $args}
                "^true$"            {if {$DEBUG_ASSUME_RFA} {dbgOut "return true"};return_orig -code return true}
                "^false$"           {if {$DEBUG_ASSUME_RFA} {dbgOut "return false"};return_orig -code return false}
                default             {if {$DEBUG_ASSUME_RFA} {dbgOut "returns default: $args"};eval return_orig -code return $args}
            }
        
        } elseif {[uplevel 1 namespace current] != "::" && [uplevel 2 namespace current] == "::"} {
            if {$DEBUG_ASSUME_RFA} {
            wrnOut "\[ASSUME_RFA] (test script <--return-- lib) return value redefined !!!!"
            wrnOut "\[ASSUME_RFA] Caller : [info level -1]"
            wrnOut "\[ASSUME_RFA] \$args = $args"
            }
            switch -regexp -- $args {
                "^-code[\t ]+ok"    {if {$DEBUG_ASSUME_RFA} {dbgOut "return: [lindex $args 2]"};return_orig -code return [lindex $args 2]}
                "^-code[\t ]+error" {if {$DEBUG_ASSUME_RFA} {dbgOut "return: -code return 1"};return_orig -code return 1}
                "^true$"            {if {$DEBUG_ASSUME_RFA} {dbgOut "return value change: true->0"};return_orig -code return 0}
                "^false$"           {if {$DEBUG_ASSUME_RFA} {dbgOut "return value change: false->1"};return_orig -code return 1}
                default             {if {$DEBUG_ASSUME_RFA} {dbgOut "returns default: $args"};eval return_orig -code return $args}
            }
            
        } else {
            if {$DEBUG_ASSUME_RFA} {
            infOut "\[ASSUME_RFA] (RunScript.tcl <--return-- test script) NO CHANGE of return value."
            infOut "\[ASSUME_RFA] Caller : [info level -1]"
            infOut "\[ASSUME_RFA] \$args = $args"
            infOut "\[ASSUME_RFA] return = [lindex $args 2]"
            }
            switch -regexp -- $args {
                "^-code[\t ]+ok"    {if {$DEBUG_ASSUME_RFA} {dbgOut "return: [lindex $args 2]"};return_orig -code return [lindex $args 2]}
                "^-code[\t ]+error" {if {$DEBUG_ASSUME_RFA} {dbgOut "eval return_orig $args"};eval return_orig $args}
                default             {if {$DEBUG_ASSUME_RFA} {dbgOut "returns default: $args"};return_orig -code return $args}
            }
        
        }
    }
};#end ASSUME_RFA

#
# Begin executing test scripts here
# 
if {$KOMPOSER} {
    package require Komposer
    Komposer::start
} elseif {$CHECK_CONFIG} {
    checkConfig
} else {
    catch {wm withdraw .}
    if {$INVALID_ARGUMENT == 0} {
       if {$CREATE_STS} { ::ATSTS::load $STS_OUTPUT_FILE $runList}
       execTestCase $runList
       if {$CREATE_STS} { ::ATSTS::finalize}
    }
    if {![catch {winfo children .}]} {
        while { [winfo children .] != "" } {
            update;# do nothing until user has closed all Tk windows
            pause 0.5
        }
    }
    catch {destroy . }
}
# EOF
