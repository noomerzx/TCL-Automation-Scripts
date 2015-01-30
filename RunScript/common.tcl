################################################################
# FILE:    	    common.tcl
# MAINTAINERS:  wiwat.tharateeraparb@reuters.com
#		    songkiet.pombuppa@reuters.com
#		    kittipong.theerawatsathein@reuters.com
#
# Copyright (C) 2005 Reuters Software (Thailand) Limited.
# All rights reserved.
#
# DESCRIPTION
#         Common lib 
#    
#
# LIMITATIONS
#        trap does not work properly , losing spawn id
#          
#
# REVISION HISTORY
#
#        Revision 1.0 2005/11/1 Wiwat T.
#        First Release
#
#        Revision 1.1 2005/12/07 Songkiet P.
#        Added variable FATAL_ERROR
#        Added init, uninit
#        Improved all log functions.
#
#        Revision 1.2 2005/12/14 Wiwat T.
#        Since 1.2 no need for package_required variable in test scripts.
#        Added CleanUp
#        Added trap to handle SINGINT (^C)
#        workaround in cleanUP, namespace delete caused tcl core dump if
#           there was package require inside the package namespace
#
#        Revision 1.2 2006/01/23 Songkiet P.
#        Changed dbgOut to output when DEBUG is set
#        Added FTP related functions.
#        Added CPU calculate functions.
#        Added iwait function.
#
#        Revision 1.2.1 2006/02/02 Songkiet P.
#        Fixed bug multi-hop ftp.
#
#        Revision 2.0 2006/03/06 Songkiet P.
#        Migrated FTP code to Ftp package.
#        Added generic connect function.
#
#        Revision 2.0.1 2006/04/01 Wiwat T.
#        fix editConfigFile to support rtic.cf/tic.cf
#        initServiceNames looks for both [service_names] and [metadata] tags
#        add {file mkdir [file dirname [info script]]/log}}
#        exp_send replaces send
#        detect env(USER), env(HOSTNAME), env(REMOTEHOST) for Linux compat
#        dbgOut write to log file as well
#        SEPARATE_DEBUG_MSG_WINDOW for separate debug msg window (set by -vvvs)
#        fixed bug at cleanUp. Added "unset fid" after close $fid
#        
#        remove "return -code error" if setting $${token}(isFirstEdit_${file}) 1
#           this is the way to force change on a file w/o restored back by 
#           function cleanUp() or restoreConfigFile()
#
#        Revision 2.1.0 2006/05/30 Songkiet P.
#        Merged RFA TTS implementation code
#        + Fixed bug in function interpolate (cause problem with space in string)
#
#        Revision 2.1.1 2006/06/02 Songkiet P.
#        Addd loadProfile function to connect
#
#        Revision 2.1.2 2006/06/03 Wiwat.t
#        in interpolate, replaced puts with dbgOut 
#
#        Revision 2.1.3 2006/06/13 Songkiet P.
#        Updated registerCpuMsgHandler
#         - Capture the most consuming CPU child process instead of parent process.
#
#        Revision 2.1.4 2006/06/20 Wiwat.t
#        $log autoscroll disable when a user is scrolling
#
#        Revision 2.1.5 2006/06/30 Wiwat.t
#        linked editConfigFile and restoreConfigFile to same names in ::File
#
#        Revision 2.1.6 2006/07/01 Wiwat.t
#        fixed bug lib's init function, initToken created
#           [regexp "^.$token\[\\]]" $line
#        redefined parray
#        $log coloring
#        added "info level -1" in dbgOut proc
#        changed interpolate from "return" to "return -code ok $temp"
#
#        Revision 2.1.7 2006/07/06 Songkiet P.
#        Modified registerCpuMsgHandler to handle prstat of sol10.
#
#        Revision 2.1.8 2006/07/28 Wiwat.t
#        comment-out unset ::${package}::ARR_VAR(DEBUG)
#
#        Revision 2.1.9 2006/07/28 Songkiet P., Wiwat T.
#        Added searchToken
#        Added ::common::run
#        Improved registerCpuMsgHandler
#        use ::File::restore in cleanUp
#
#        Revision 2.1.10 2006/08/08 Songkiet P.
#        Added ::common::run the optional argument for return the expected text to user
#
#        Revision 2.1.11 2006/08/16 Wiwat.t
#        Fixed parsing error token data if "=" is used e.g. JPY=
#        Added regsub -all {\[} $inlist {\\[} inlist in ::interpolate
#        Fixed bug #68, initToken and init. Set isConfig = 0
#        Added deletion of _MON.log, _EXAMPLEAPP.log, _TIE.log
#
#        Revision 2.1.12 2006/08/22 Songkiet P., Wiwat T.
#        ::common::run check prompt two times. Bug#69
#        Change PASS_PROMPT to "Password: |Password:", Bug #72
#        Support CYGWIN platform detection in ::connect, BUg #73
#        added checking {[uplevel 1 namespace current] == "::File"} for ::interpolate
#        catch Tk command error in case there is no DISPLAY exported
#        removed catch {wm withdraw .} to support Komposer mode (GUI)
#
#        Revision 2.1.13 2006/08/22 Songkiet P., Wiwat T.
#        ::common::connect change timeout from 10 (default) to 30 seconds
#           for allow slow respond of some server (e.g. Cygwin)
#        ::common::run change 'expect_msg' to optional argument
#        add ssh support in ::connect (set "remote_login = ssh" in Config.txt)
#
#        Revision 2.1.14 2006/10/11 Rachun C.
#        Added ::common::manageWindowsService function to start/stop windows service
#        Added ::common::killWindowsProcess fuction to kill windows process (WinXP and Win2000 only)
#
#        Revision 2.1.15 2006/10/25 Rachun C.
#        Added ::common::isWindowsProcessUp function to check windows process
#        Modified loadEnv to support loading windows environment
#
#        Revision 2.1.16 2006/12/20 Wiwat T.
#        added \" in changePath
#        changed many prompts in ARR_VAR
#        fix-bug candidate bug#ATT5
#           close expect log (log_file;) before open a new one (log_user -a...) in ::init
#        added "wait" after close -i $spawn_id to delays until spawn terminates
#        added catch packager require WindowsRegistry for backward-compat issue
#        changed debug window closed with triple mouse clicks
#
#        Revision 2.1.17 2007/02/01 Wiwat T.
#        added "No route to host" error checking in ::connect
#        added pause function
#
#        Revision 2.1.18 2007/05/22 Wiwat T.
#        added "exec bash" in ::connect
#
#        Revision 2.1.19 2007/05/29 Rachun C.
#        changed "cd" to "cd /D" for Windows platform in changePath function.
#
#        Revision 2.1.20 2007/06/18 Wiwat T.
#        added ::clnRMDSProc to kill a bunch of RMDS-related process
#
#        Revision 2.1.21 2007/06/22 Kittipong T.,Wiwat T.
#        added ::stty to detect and set display windows resolution
#        changed ::clnRMDSProc to use "pgrep -x"
#
#        Revision 2.1.22 2007/06/27 Wiwat T.
#        catch each step in ::cleanUp
#
#        Revision 2.1.23 2007/07/16 Rachun C.
#        changed killWindowsProcess to kill process id instead of process name.
#
#        Revision 2.1.24 2007/08/09 Wiwat T.
#        Added Windows telnet error message "Unable to connect to remote host"
#        Remove triple clicks to close the debug window
#        Added title bar information of a executing script name
#
#        Revision 2.1.25 2007/08/29 Rachun C.
#        fixed '\' lost after uplevel in initServiceNames function
#
#        Revision 2.1.26 2007/10/10 Wiwat T.
#        change PROMPT to support Suse standard installation
#        Try to override PROMPT's in other packages as well
#        workaround telnet to localhost #ATT63 by retry 3 times
#        Added Windows prompt RE in PROMPT ( used by JSFC )
#
#        Revision 2.1.27 2007/10/25 Rachun C.
#        - Changed from command "find" to "grep" in IsWindowsProcessUp 
#        due to the limitaion of "find" command with double quotes
#        - Modified Windows prompt due to problems with other drives (D, E, etc.)
#
#        Revision 2.1.28 2007/10/30 Rachun C.
#        Changed Windows prompt back for SUSE and modified for Windows at the last part instead.
#
#        Revision 2.1.29 2007/11/06 Wiwat T.
#        Fixed to support ::interpolate with ::XML::editConfigFile (bug#ATT68)
#        Display correct loading packages
#
#        Revision 2.1.30 2008/01/28 Rachun C.
#        Fixed '$' and '[' problem with uplevel in initServiceNames function
#
#        Revision 2.1.31 2008/01/05 Wiwat T.
#        ::connect to handle error "Connection closed by foreign host"
#
#        Revision 2.1.32 2008/04/23 Rachun C.
#        Added expOut function to display expect results when running scripts
#        Added exp_send '\r' in changePath
#        Changed "\" to "\\", "." to "\." in process command due to regular expression matching
#
#        Revision 2.1.33 2008/07/09 Rachun C.
#        Fixed killWindowsProcess to use "taskkill" if no "tskill" command
#
#        Revision 2.1.34 2008/09/19 Pathatai P.
#        Add ::getHostname to get machine hostname.
#
#        Revision 2.1.35 2008/09/24 Rachun C.
#        Added sending enter to get prompt in killWindowsProcess function
#
#        Revision 2.1.36 2008/11/04 Rachun C.
#        Use taskkill as default command in killWindowsProcess function
#
#        Revision 2.1.37 2008/11/28 Rachun C.
#        Added "kill" function to kill process by using running command(not process id)
#        Added option -E to grep command in isWindowsProcessUp
#
#        Revision 2.1.38 2008/12/22 Rachun C.
#        Fixed iwait function to not consume 100% CPU usage
#
#        Revision 2.1.39 2009/01/13 Rachun C.
#        + Use "after" instead of "wait" in closeSpawn function for Windows platform due to the disconnection problem
#        + Use "exp_spawn" instead of "spawn" in connect function, it seems more stable.
#        + Reinitialize ARR_VAR(FLAG) to 0 in closeSpawn function
#
#        Revision 2.1.40 2009/01/21 Atthaboon S.
#        + Add mcs in applist for kill process in function clnRMDSProc.
#
#        Revision 2.1.41 2009/01/21 Rachun C.
#        + Fixed prompt issue in changePath function
#
#        Revision 2.1.42 2009/02/23 Rachun C.
#        + Fixed running scripts problem on Windows 64-bit platform that could close spawn id
#
#        Revision 2.1.43 2009/10/09 Rachun C.
#        + Fixed "can't kill process" bug in ::common::kill
#
#        Revision 2.1.44 2009/10/21 Rachun C.
#        + Added ping function
#
#        Revision 2.1.45 2009/11/25 Pathatai P.
#        Add ::getHostArchitect to get machine architecture.
#
#        Revision 2.1.46 2009/12/01 Pathatai P.
#        Fix file issue in ::getHostArchitect function
#
#        Revision 2.1.47 2010/01/15 Atthaboon S.
#        Add "(%|#|\$) \x1b\[m\x0f$" in PROMPT regular for support SUSE11 64 bit
#
#		 Revision 2.1.48 2010/01/27 Ukrit H.
#		 + Fixed "Found prompt before login for machine which shows notification message.
#
#        Revision 2.1.49 2010/02/03 Rachun C.
#        Modified printing system information with "uname -a" instead of "uname -s" in connect function
#
#        Revision 2.1.50 2010/02/05 Wiwat T.
#        Introduce sshkey option for SSH login, if authorized it will login without password
#
#        Revision 2.1.51 2010/02/25 Rachun C.
#        Enhanced ::File::cd to support Windows platform
#
#        Revision 2.1.52 2010/08/10 Ukrit H.
#        Enhanced ::common::clnRMDSProc will clear Share Memory Key and Semaphore Key (when difined SHM_KEYS
#        SMP_KEYS in Config.txt on [meta] section
#        [meta]
#        SHM_KEYS = 80,81,82,83
#        SMP_KEYS = 80,81,82,83
#
#        Revision 2.1.53 2010/09/08 Atthaboon S.
#        Add step in ::common::connect for verify error from ssh connection "Host key verification failed".
#
#        Revision 2.1.54 2010/09/08 Atthaboon S.
#        Add step in ::common::connect for verify error from ssh connection no address associated with name.
#
#        Revision 2.1.55 2010/10/28 Rachun C.
#        Added expectRandomMsg function
#
#        Revision 2.1.56 2010/11/01 Rachun C.
#        Added loadCmd function to run any commands after login
#
#        Revision 2.1.57 2011/01/31 Rachun C.
#        Added notfoundList return variable from expectRandomMsg function
#
#        Revision 2.1.58 2011/01/31 Atthaboon S.
#        Add regular expression - to getHostname function
#
#        Revision 2.1.59 2011/10.28 Rachun C.
#        Modified connect function to support ip with port, e.g. 192.168.1.8:8080
#
#        Revision 2.1.60 2011/11/02 Atthaboon S.
#        Modified expectRandomMsg function searchToken before assign spawn_id value
#
#        Revision 2.1.61 2011/11/14 Atthaboon S.
#        Modified run function searchToken before assign send any command to token
#
#        Revision 2.1.62 2011/11/23 Atthaboon S.
#        add proc getExpectRandomMsgResult
#        add proc sendDirectCmd
#
#        Revision 2.1.63 2012/01/04 Atthaboon S.
#        add proc initAUTOBOT for init default variable and log file support AUTOBOT framework
#
#        Revision 2.1.64 2012/05/17 Pusit W.
#        Modified proc init to add testcase variable to top level of script.
#
#        Revision 2.1.65 2012/05/24 Pusit W.
#        Add proc monitor to monitor expected message and assign expect_out parameter to the token.
#
#        Revision 2.1.65 2012/05/24 Atthaboon S.
#        add proc convertFieldNameToFieldID for convert field name to field id using RDMFieldDictionary for reference.
#
#        Revision 2.1.66 2012/07/02 Pusit W.
#        Modified connect to support -timeout option.
#
#        Revision 2.1.67 2012/08/17 Pusit W.
#        Modified run and monitor to assign expect_out parameter to the token as expout.
#
#        Revision 2.1.68 2014/01/30 Wisarut P.
#        Modified init for provide custom log directory options in RunScript ( -L <dir_name> )
#
#        Revision 2.1.68 2014/02/24 Atthaboon S.
#        Modified init auto assign m_logpath to 'defaults' for support autobot framework 
#
################################################################
package provide common 2.1
package require File
# Need to catch it for backward-compat
catch {package require WindowsRegistry}
namespace eval ::common:: {
    namespace export init initServiceNames interpolate uninit cleanUp expectRandomMsg
    namespace export genOut infOut wrnOut errOut dbgOut expOut displayTestStep displayTestHeader
    namespace export calPerf iwait connect initToken searchToken pause clnRMDSProc 

    variable FATAL_ERROR 100
    variable fid
    array set ARR_VAR {
        PROMPT          {(%|#|\$) $|[a-zA-Z0-9]:.*> $|[A-Z]:\\.*>|(%|#|\$) \x1b\[m\x0f$}
        LOGIN_PROMPT    "[Ll]ogin: $"
        PASS_PROMPT     "[Pp]assword: $|[Pp]assword:$"
        FAIL            1
        PASS            0
        DEBUG           0
        FLAG            0
    }
    array set DATA_DICT {
        
    }
    proc convertBackSlash {inp} {
        regsub -all {\\} $inp {\\\\} oup
        regsub -all {\*} $oup {\\*} oup
        regsub -all {\+} $oup {\\+} oup
        regsub -all {\?} $oup {\\?} oup
        regsub -all {\:} $oup {\\:} oup
        regsub -all {\.} $oup {\\.} oup
        regsub -all {\^} $oup {\\^} oup
        regsub -all {\$} $oup {\\$} oup
        regsub -all {\!} $oup {\\!} oup
        regsub -all {\\{} $oup {\\\{} oup
        regsub -all {\\}} $oup {\\\}} oup
        regsub -all {\(} $oup {\\(} oup
        regsub -all {\)} $oup {\\)} oup
     return $oup
    }
    proc convertDoubleQuote {inp} {
        regsub -all {"} $inp {\"} oup
        return $oup
    }
    proc searchToken { token } {
        if {[regexp "::" $token]} {
            dbgOut "Ignore search token. $token tends to be a full-qualified name"
            return -code ok "$token"
        }
        foreach ns [namespace children ::] {
            if {[info exists ${ns}::${token}]} {
                dbgOut "$token gets translated to namespace ${ns}::${token}"
                return -code ok "${ns}::${token}"
            }
        }
        return -code error "$token not found in any namespace"
    }
}
#***************************************************************
# PROCEDURE 
#        init
#
# DESCRIPTION
#        Init state. Load packages, set debug mode on/off.
#        Load [service_names] section in Config.txt
#        open tester log file
#        open Expect log file (transcript)
#        trap process signals
#
# ARGUMENTS
#		None
#        
#                    
#***************************************************************
proc ::common::init {} {
    global package_required
    global auto_path
    global DEBUG
    variable fid
    variable ARR_VAR
    upvar testcase m_testcase
    upvar path     m_path
	upvar #0 LOG_PATH m_logpath
    
    if {![info exists m_logpath]} {
        set m_logpath "defaults"
    }
    
    trap {
        send_user "\n^C****** INTERRUPT RECEIVED ******\n"
        if {[catch cleanUp result]} {send_user "$result"}
        exit 1
    } SIGINT
    
    # to support common.tcl v. 1.0 - 1.1
    foreach {package version} [array get package_required] {
        package require $package $version
    }

    foreach {package} [package names] {
        if {[info exists ::${package}::ARR_VAR(DEBUG)]} {
            if {[info exists DEBUG]} {
                set ::${package}::ARR_VAR(DEBUG) $DEBUG
            } else {
                set ::${package}::ARR_VAR(DEBUG) 1
                set DEBUG 1
            }
        }
        # override PROMPT, LOGIN_PROMPT, PASS_PROMPT here
        if {[info exists ::${package}::ARR_VAR(PROMPT)]} {set ::${package}::ARR_VAR(PROMPT) $ARR_VAR(PROMPT)}
        if {[info exists ::${package}::ARR_VAR(LOGIN_PROMPT)]} {set ::${package}::ARR_VAR(LOGIN_PROMPT) $ARR_VAR(LOGIN_PROMPT)}
        if {[info exists ::${package}::ARR_VAR(PASS_PROMPT)]} {set ::${package}::ARR_VAR(PASS_PROMPT) $ARR_VAR(PASS_PROMPT)}
        
        set version [package provide $package]
        if {[info exists ::${package}::ARR_VAR(DEBUG)]} {puts [format "%-*sV.%s" 30 $package $version]}
    }
	
	# --- modified else condition for -L option in RunScript.tcl
	if { [string equal $m_logpath "defaults"] } {
		uplevel initServiceNames
		uplevel #0 {set testcase [file rootname [file tail [info script]]]}
		uplevel {set testcase [file rootname [file tail [info script]]]}
		uplevel {set path     [file join [pwd] [file dirname  [info script]]]}
		uplevel {set LOG_FILE "${testcase}_EXP.log"}    
		uplevel {if {![file isdirectory [file dirname [info script]]/log]} {file mkdir [file dirname [info script]]/log}}
		uplevel {log_file;log_file -a -noappend "[file dirname [info script]]/log/$LOG_FILE"}
		uplevel {file delete "[file dirname [info script]]/log/${testcase}_MON.log"}
		uplevel {file delete "[file dirname [info script]]/log/${testcase}_EXAMPLEAPP.log"}
		uplevel {file delete "[file dirname [info script]]/log/${testcase}_TIE.log"}
		# Begin logging testcase Tcl script
		if {[catch {open "${m_path}/log/${m_testcase}.log" "w+"} fid] != 0} {}
	} else {
		uplevel #0 {set testcase [file rootname [file tail [info script]]]}
		uplevel {set testcase [file rootname [file tail [info script]]]}
		uplevel {set path     [file join [pwd] [file dirname  [info script]]]}
		uplevel initServiceNames
		uplevel {upvar #0 LOG_PATH logpath}
		uplevel {set LOG_FILE "${testcase}_EXP.log"}    
		uplevel {if {![file isdirectory ${logpath}]} {file mkdir ${logpath}}}
		uplevel {log_file;log_file -a -noappend "${logpath}/$LOG_FILE"}
		uplevel {file delete " ${logpath}/${testcase}_MON.log"}
		uplevel {file delete " ${logpath}/${testcase}_EXAMPLEAPP.log"}
		uplevel {file delete " ${logpath}/${testcase}_TIE.log"}
		# Begin logging testcase Tcl script
		if {[catch {open "${m_logpath}/${m_testcase}.log" "w+"} fid] != 0} {}
	}
	# ---- end modified
}
#***************************************************************
# PROCEDURE 
#        initAUTOBOT
#
# DESCRIPTION
#        Init state for autobot framework. Load packages, set debug mode on/off.
#        Load [service_names] section in Config.txt
#        open tester log file
#        open Expect log file (transcript)
#        trap process signals
#
# ARGUMENTS
#       log_name    -   Log file name
#	    log_path    -   Log file path (Example D:/script/)
#
#***************************************************************
proc ::common::initAUTOBOT { log_name log_path } {
    global package_required
    global auto_path
    global DEBUG
    variable fid
    variable ARR_VAR
    upvar testcase m_testcase
    upvar path     m_path
    
    regsub -all {\\} $log_path {/} log_path
    
    set m_testcase $log_name
    set m_path $log_path
    
    trap {
        send_user "\n^C****** INTERRUPT RECEIVED ******\n"
        if {[catch cleanUp result]} {send_user "$result"}
        exit 1
    } SIGINT
    
    # to support common.tcl v. 1.0 - 1.1
    foreach {package version} [array get package_required] {
        package require $package $version
    }

    foreach {package} [package names] {
        if {[info exists ::${package}::ARR_VAR(DEBUG)]} {
            if {[info exists DEBUG]} {
                set ::${package}::ARR_VAR(DEBUG) $DEBUG
            } else {
                set ::${package}::ARR_VAR(DEBUG) 1
                set DEBUG 1
            }
        }
        # override PROMPT, LOGIN_PROMPT, PASS_PROMPT here
        if {[info exists ::${package}::ARR_VAR(PROMPT)]} {set ::${package}::ARR_VAR(PROMPT) $ARR_VAR(PROMPT)}
        if {[info exists ::${package}::ARR_VAR(LOGIN_PROMPT)]} {set ::${package}::ARR_VAR(LOGIN_PROMPT) $ARR_VAR(LOGIN_PROMPT)}
        if {[info exists ::${package}::ARR_VAR(PASS_PROMPT)]} {set ::${package}::ARR_VAR(PASS_PROMPT) $ARR_VAR(PASS_PROMPT)}
        
        set version [package provide $package]
        if {[info exists ::${package}::ARR_VAR(DEBUG)]} {puts [format "%-*sV.%s" 30 $package $version]}
    }
    
    uplevel initServiceNames
    uplevel {set LOG_FILE "${testcase}_EXP.log"}

    uplevel {if {![file isdirectory [file dirname ${path}]/log]} {file mkdir [file dirname ${path}]/log}}
    uplevel {log_file;log_file -a -noappend "[file dirname ${path}]/log/$LOG_FILE"}
    uplevel {file delete "[file dirname ${path}]/log/${testcase}_MON.log"}
    uplevel {file delete "[file dirname ${path}]/log/${testcase}_EXAMPLEAPP.log"}
    uplevel {file delete "[file dirname ${path}]/log/${testcase}_TIE.log"}
    # Begin logging testcase Tcl script
    if {[catch {open "[file dirname ${m_path}]/log/${m_testcase}.log" "w+"} fid] != 0} {}
}
#***************************************************************
# PROCEDURE 
#        uninit
#
# DESCRIPTION
#        close tester log file
#        close Expect log file (transcript)
#
# ARGUMENTS
#   None     
#	
# REMARKS:
#        Obsolete since common.tcl 1.2, will be removed in 2.0
#
#***************************************************************
proc ::common::uninit {} {
    variable fid
    
    log_file
    close $fid
}
#***************************************************************
# PROCEDURE 
#        initServiceNames
#
# DESCRIPTION
#        Initiate Service Names variables defined by Config.txt
#        into user context (upvar and uplevel)
#
# ARGUMENTS
#        None
#                    
#***************************************************************
proc ::common::initServiceNames {} {
    global CONFIG_FILENAME
    variable ARR_VAR
    set oldwd [pwd]
    set isConfig 0
    dbgOut "\n============= METADATA INIT =============="
    if { ![info exists CONFIG_FILENAME] } {
        cd ..
        cd ..
        set filename "Config.txt"
    } else {
        regsub -all {\\} $CONFIG_FILENAME {\\\\} filename
    }
    if { ![catch {set file [open $filename]}] } {      
        set data [read $file]
        close $file
        set isConfig 0
        set lines [split $data "\n"]
        foreach line $lines {
            set line [string trimleft $line]
            if { [ regexp {^\[service_names\]|^\[metadata\]} $line ] } {
                set isConfig 1
            } elseif { [regexp {^\[} $line] } {
                set isConfig 0
            } elseif { (![regexp {^#} $line]) && $isConfig} { 
                if {[regexp {([^=]*)=(.*)} $line -> key value]} {
                    set key [string trimright $key]
                    set value [string trimleft $value]
		    regsub -all {\\} $value {\\\\} temp
		    regsub -all {\[} $temp {\\[} temp
		    regsub -all {\$} $temp {\\$} temp
                    uplevel set $key \"$temp\"
                    dbgOut [format "%-*s= %s" 20 $key $value]
                }
            }
        }
    } else {
        cd $oldwd
        return -code error "ERROR: Cannot locate $filename. Abort !!"
    }
    cd $oldwd
    dbgOut "\n============= METADATA INIT ==============\n"
}
#***************************************************************
# PROCEDURE 
#        interpolate
#
# DESCRIPTION
#        Insert values of variables in a list using variable
#        definitions in user context (uplevel)
#
# ARGUMENTS
#        inlist      -   input list e.g.
#(code)
#                       set config {
#                           {$var1}     {$var2}
#                           ...
#                       }
#(end)                    
#***************************************************************
proc ::common::interpolate { inlist } {
    variable ARR_VAR
    if {[uplevel 1 namespace current] == "::XML"} {
        dbgOut "Before interpolation, inlist =";foreach {node attribute value} $inlist {dbgOut [format "%-*s %s %s" 60 $node $attribute $value]}
    } else {
        dbgOut "Before interpolation, inlist =";foreach {key value} $inlist {dbgOut [format "%-*s %s" 60 $key $value]}
    }
    regsub -all {\\} $inlist {\\\\} inlist
    regsub -all {"} $inlist {\"} inlist
    regsub -all {;} $inlist {\;} inlist
    regsub -all {\[} $inlist {\\[} inlist
    
    set temp {}
    foreach item $inlist {
        regsub -all { } $item {\\040} item
        if {[uplevel 1 namespace current] == "::"} {
            set temp "$temp [eval uplevel {list $item}]"
        } elseif {([uplevel 1 namespace current] == "::File") || ([uplevel 1 namespace current] == "::XML")} {
            set temp "$temp [eval uplevel 2 {list $item}]"
        } else {
            set temp "$temp [eval uplevel 3 {list $item}]"
        }
    }
    if {[uplevel 1 namespace current] == "::XML"} {
        dbgOut "After interpolation, inlist =";foreach {node attribute value} $temp {dbgOut [format "%-*s %s %s" 60 $node $attribute $value]}
    } else {
        dbgOut "After interpolation, inlist =";foreach {key value} $temp {dbgOut [format "%-*s %s" 60 $key $value]}
    }
    return -code ok $temp
}


#***************************************************************
# PROCEDURE 
#        Log functions
#
# DESCRIPTION
#        These log functions help to write log file of test cases
#        in the same format.
#
# ARGUMENTS
#        fid    - file descriptor of log file
#        msg    - text to print to log file
#
#***************************************************************
proc ::common::genOut { msg } {
    global VERBOSE log SEPARATE_DEBUG_MSG_WINDOW KOMPOSER

    variable    fid

    if {![info exists VERBOSE]} {
        set VERBOSE 1
    }
    
    if {[info exists fid]} {
        puts $fid "$msg"; flush $fid
    }
    
    #catch {wm withdraw .}
    if {$VERBOSE == 1} {
        if {[info exists SEPARATE_DEBUG_MSG_WINDOW] && $SEPARATE_DEBUG_MSG_WINDOW} {
            if {![winfo exists .logwindow]} {
                set log_height 40
                set log_width 80
                set log_xpos 0
                set log_ypos 0
                toplevel .logwindow
                wm geometry .logwindow ${log_width}x${log_height}+${log_xpos}+${log_ypos}
                event add <<CloseWindow>> <Control-Alt-F4>
                wm protocol .logwindow WM_DELETE_WINDOW [list event generate .logwindow <<CloseWindow>>]
                bind .logwindow <<CloseWindow>> { destroy .logwindow }
                #bind .logwindow <Triple-1> { destroy .logwindow }
                frame .logwindow.f1
                set log [text .logwindow.f1.log -background white -width $log_width -height $log_height \
                    -borderwidth 2 -relief raised -setgrid true \
                    -yscrollcommand {.logwindow.f1.scroll set}]
                scrollbar .logwindow.f1.scroll -command {.logwindow.f1.log yview}
                pack .logwindow.f1.scroll -side right -fill y
                pack .logwindow.f1.log -side left -fill both -expand true
                pack .logwindow.f1 -side top -fill both -expand true
                # Config text tags 
                $log tag configure DEBUG -foreground "black"
                $log tag configure INFO -foreground "dark green"
                $log tag configure WARN -foreground "dark orange"
                $log tag configure ERR -foreground red
                $log tag configure OK -font {courier 12 bold} -foreground "dark green"
                $log tag configure COMMENT -foreground "dark blue"
                $log tag configure DEFAULT -foreground "black"
                update
                #after 10000
            }
            
            foreach {top bottom} [$log yview] {}
            switch -regexp -- $msg {
                "DEBUG.*"       { $log insert end "$msg\n" {DEBUG} }
                "INFO.*"        { $log insert end "$msg\n" {INFO} }
                "WARN"          { $log insert end "$msg\n" {WARN} }
                "ERR|FAIL.*|WARN"    { $log insert end "$msg\n" {ERR} }
                "OK.*"          { $log insert end "$msg\n" {OK} }
                "^#|STEP|Preparation|Ensure that" { $log insert end "$msg\n" {COMMENT} }
                default         { $log insert end "$msg\n" {DEFAULT}}
            }
            if {$bottom == 1} { $log see end }
            wm title .logwindow "AUTOMAT: Debug \[ [info script] \]"
        } else {
            puts stdout "$msg"
        }
    }
#    flush $fid
}
interp alias {} ::common::expOut {} ::common::infOut
proc ::common::infOut { msg } {genOut " INFO  : $msg"}
proc ::common::wrnOut { msg } {genOut " WARN  : $msg"}
proc ::common::errOut { msg } {genOut " ERROR : $msg"}
proc ::common::dbgOut { msg } {
    global DEBUG
    set caller ""
    if {![catch {info level -1} caller]} {
        set caller "\[[lindex $caller 0]\]"
    }
    if {$DEBUG} { 
        genOut " DEBUG : $caller $msg" 
    } 
}

proc ::common::displayTestStep { subject } {
    variable ARR_VAR
    global log SEPARATE_DEBUG_MSG_WINDOW
    genOut ""
    if {$ARR_VAR(DEBUG) && [info exists SEPARATE_DEBUG_MSG_WINDOW] && $SEPARATE_DEBUG_MSG_WINDOW == 1} { 
        foreach {top bottom} [$log yview] {}
        $log insert end "###################################################################\n" {COMMENT}
        if {$bottom == 1} { $log see end }
    } elseif {$ARR_VAR(DEBUG)} { 
        puts stdout "###################################################################"
    }
    genOut "$subject"
    if {$ARR_VAR(DEBUG) && [info exists SEPARATE_DEBUG_MSG_WINDOW] && $SEPARATE_DEBUG_MSG_WINDOW == 1} { 
        foreach {top bottom} [$log yview] {}
        $log insert end "###################################################################\n" {COMMENT}
        if {$bottom == 1} { $log see end }
    } elseif {$ARR_VAR(DEBUG)} { 
        puts stdout "###################################################################"
    }
}
proc ::common::displayTestHeader { testCaseId description } {
    global env

    set curDate [clock format [clock seconds] -format "%a %d/%m/%y %k:%M"]
    
    if {[info exists env(USERNAME)]} {
        set tester $env(USERNAME)
    } elseif {[info exists env(USER)]} {
        set tester $env(USER)
    } else {
        set tester "N/A"
    }
    
#    if {[info exists env(HOSTNAME)]} {
#        set machine $env(HOSTNAME)
#    } else {
#        set machine "N/A"
#    }
    
    if {[info exists env(REMOTEHOST)]} {
        set remotehost $env(REMOTEHOST)
    } else {
        set remotehost "N/A"
    }
    
    genOut "###################################################################"
    genOut "#"
    genOut "# Test Case ID : $testCaseId"
    genOut "# Description  : $description"
    genOut "# Date/Time    : $curDate"
    genOut "# Tester       : $tester"
    genOut "# Machine      : [info hostname]"
    genOut "# Remotehost   : $remotehost"
    genOut "#"
    genOut "###################################################################"
}
#***************************************************************
# PROCEDURE 
#        cleanUp
#
# DESCRIPTION
#        unload packages
#        close spawns (if spawn_id is present)
#        destroy instances
#        close tester log file ($fid)
#        close Expect log file (transcript)
#
# ARGUMENTS
#	None
#                
#***************************************************************
proc ::common::cleanUp {} {
    variable fid
    variable ARR_VAR

    # Restore registry node from file
    foreach {package} [package names] {  
        if {[info exists ::${package}::token_list]} {
            eval set token_list $${package}::token_list
            foreach token $token_list {
                foreach {key value} [array get ${package}::${token}] {
                    if {[regexp {isFirstImport_(.*)} $key -> file]} {
                        if {[catch {
                            ::WindowsRegistry::restoreRegistry $token $file
                        }]} {lappend error "Failed at ::WindowsRegistry::restoreRegistry ($token)"}
                    }
                }
            }
        }
    }
    
    # Restore editted config files
    foreach {package} [package names] {  
        if {[info exists ::${package}::token_list]} {
            eval set token_list $${package}::token_list
            foreach token $token_list {
                foreach {key value} [array get ${package}::${token}] {
                    if {[regexp {isFirstEdit_(.*)} $key -> file]} {
                        if {[catch {
                            ::File::restore $token $file
                        }]} {lappend error "Failed at ::File::restore ($token)"}
                    }
                }
            }
        }
    }

    # Close all open spawn_ids
    foreach {package} [package names] {    
        if {[info exists ::${package}::token_list]} {
            eval set token_list $${package}::token_list
            foreach token $token_list {
                if {[info exists ::${package}::${token}(spawn_id)]} {
                    if {[catch {
                        ::${package}::closeSpawn $token
                    }]} {lappend error "Failed at closeSpawn ($token)"}
                }
            }
        }
    }
    
    # Destroy all instances
    foreach {package} [package names] {
        if {[info exists ::${package}::token_list]} {
            eval set token_list $${package}::token_list
            foreach token $token_list {
                if {[catch {
                    ${package}::destroy $token
                }]} {lappend error "Failed at destroy ($token)"}
            }
        }    
    }
    
    # Unload Reuters Automated Test Tools packages/namespace
    dbgOut "unloading packages/namespace except common.tcl....\n"
    foreach {package} [package names] {    
        if {[info exists ::${package}::ARR_VAR(DEBUG)] && ($package != "common")} {                     
            set version [package provide $package]           
            #if { [catch {namespace delete ::$package} result] } {errOut "Namespace $package deletion failed. Resutl: $result"}
            #unset ::${package}::ARR_VAR(DEBUG)
            if { [catch {package forget $package} result] } {errOut "Package $package unloading failed. Resutl: $result"}
            dbgOut [format "%-*sV.%s    Unloaded !!" 30 $package $version]
        }
    }
    dbgOut "...unload done\n"
    log_file

    close $fid
    unset fid
    if {[info exists error]} {
        return -code error "$error"
    } else {
        return -code ok 0
    }
}
###############################################################################
# PROCEDURE 
#        calPerf
#
# Description:
#       Calculate performance from top command
#
# MAINTAINERS: Rachapong Pornwiriyangkura
# 
# *Version*: 0.1 build on 03 March, 2005 11:23
#
# *Version*: 0.2 build on 04 March, 2005 17:45 
#   - Update result to show in Mbyte instead of Kbyte
#   - Detect negative nice value correctly
#
# *Version*: 0.3 build on 14 March, 2005 17:00 
#   - Update the memory calculation to not increase memory of the thread
#
# *Version*: 0.4 build on 09  June, 2005 13:00 
#   - Update the list of cmdWOThread to use lappend instead of set command
#
# *Version*: 0.5 build on 09  June, 2005 15:30 
#   - Count all commands that are the same name in the same interval as 
#     different threads but the same parent process ID.
# ARGUMENTS
#	inputFile	-	input File
#	cmdRun		-	Run command
###############################################################################
proc ::common::calPerf { inputFile cmdRun } {
    variable ARR_VAR
        
    # Verify input argument
    if {$inputFile == {} || $cmdRun == {} } {
        #ShowUsage inputFile
        return -code error
    }

    # Set up variables from input arguments
    set INP_FILE    $inputFile
    set CMD_LIST    $cmdRun

    # Determine OS using uname command
    if { [catch {open $INP_FILE r} fid] } {
      errOut "$fid"
      return -code error
    }

    set LINUX_HEAD "PID *USER *PRI *NI *SIZE *RSS *SHARE *STAT *%CPU *%MEM *TIME *CPU *COMMAND"
    set SOL_HEAD "PID *USERNAME *SIZE *RSS *STATE *PRI *NICE *TIME *CPU *PROCESS*"
    set WIN_HEAD "PID *USER *PR *NI *VIRT *RES *SHR *S *%CPU *%MEM *TIME\\+ *COMMAND*"

    set head {}
    foreach line [split [read $fid] "\n"] {
         regexp {(PID[^\r\n]*)} $line dummy head
      if [regexp "$LINUX_HEAD" $head] {
         set osName Linux
         break;
      } elseif [regexp "$SOL_HEAD" $head] {
         set osName SunOS
         break;
      } elseif [regexp "$WIN_HEAD" $head] {
         set osName Windows
         break;
      }
    }
    
    close $fid

    # Read input file
    if { [catch {open $INP_FILE r} fid] } {
      errOut "$fid"
      return -code error
    }


    #####
    # Parse data
    #
    
    # Initial variables
    set memUsage 0
    set cpuUsage 0
    set memUsageList {}
    set cpuUsageList {}
    set inData 0
    set count 0
    set totalMemUsage 0
    set totalCpuUsage 0
    set avgMemUsage 0
    set avgCpuUsage 0
    set foundCmdList {}
    set numThread 0
     
    # Read the CPU and memory usage for each process
    
    # Read each line in the file
    foreach line [split [read $fid] "\n"] {
      set dump {}
      set PID {}
      set USER {}
      set PRI {}
      set NI {}
      set SIZE {}
      set RSS {}
      set SHARE {}
      set STAT {}
      set cpuPercent {}
      set memPercent {}
      set TIME {}
      set CPU {}
      set COMMAND {}
      set cpuAndCmd {}
    
      # Detect the interesting process
      # This is kind of messy but if you look closely, it works just great.
      #
      # i.e. Two CPUs
      #  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU COMMAND
      # 2625 root      15   0  137M 8516  2340 S     0.9  1.6   0:17   0 X
      # 3637 root      20   0  1112 1112   916 R     0.4  0.2   0:00   0 top
      #    1 root      15   0   512  512   452 S     0.0  0.1   0:04   0 init
      #    2 root      RT   0     0    0     0 SW    0.0  0.0   0:00   0 migration/0
      #
      # i.e. One CPUs
      #  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
      # 3228 root      16   0   804  800   656 T     0.0  0.3   0:00 top
      # 3229 root      16   0   836  832   688 T     0.0  0.3   0:00 top
      # 4344 root      15   0  1048 1048   848 R     0.0  0.4   0:00 top
      #
    
      # Seperate each field
      if {"$osName" == "Linux" || "$osName" == "LinuxOS"} {
        regexp {([0-9]+)[ ]+([^ ]+)[ ]+([^ ]+)[ ]+([^ ]+)[ ]+([0-9M]+)[ ]+([0-9M]+)[ ]+([0-9]+)[ ]+([NSTDRWZ <]+)[ ]+([0-9.]+)[ ]+([0-9.]+)[ ]+([0-9:]+)[ ]+(.*)} $line dump PID USER PRI NI SIZE RSS SHARE STAT cpuPercent memPercent TIME cpuAndCmd
      } elseif {"$osName" == "SunOS"} {
        # i.e.
        #   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP       
        # 27945 root     2576K 1896K sleep   48    0   0:00.00 0.0% bash/1
        # 28070 root       13M   10M sleep   58    0   0:00.00 0.0% rmdstestclient/4
        # 27829 root     1832K 1312K sleep   58    0   0:00.00 0.0% in.telnetd/1
        regexp {([0-9]+)[ ]+([^ ]+)[ ]+([0-9MK]+)[ ]+([0-9MK]+)[ ]+([^ ]+)[ ]+([^ ]+)[ ]+([^ ]+)[ ]+([0-9:.]+)[ ]+([0-9.]+)%[ ]+(.*)} $line dump PID USER SIZE RSS STAT PRI NI TIME cpuPercent cpuAndCmd
      } elseif {"$osName" == "Windows"} {
        # i.e.
        #  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
        # 2188 Administ   8   0  2748 3688   40 R  3.0  0.7   0:00.07 top
        # 2104 SYSTEM     8   0  1952 1908   40 S  0.0  0.4   0:00.20 inetd
        # 2136 SYSTEM     8   0  2836 3812   44 S  0.0  0.7   0:00.39 inetd
        # 1472 Administ   8   0  3400 4468   40 S  0.0  0.9   0:00.32 bash
        # 2212 Administ   8   0  3400 4468   40 S  0.0  0.9   0:00.31 bash
        regexp {([0-9]+)[ ]+([^ ]+)[ ]+([^ ]+)[ ]+([^ ]+)[ ]+([0-9m]+)[ ]+([0-9m]+)[ ]+([0-9]+)[ ]+([^ ]+)[ ]+([0-9.]+)[ ]+([0-9.]+)[ ]+([0-9:.]+)[ ]+(.*)} $line dump PID USER PRI NI SIZE RSS SHARE STAT cpuPercent memPercent TIME cpuAndCmd
      } else {
        errOut "Unknown OS: $osName"
        exit $INTERNAL_ERROR
      }
    
      # Separate cpuAndCmd for CPU and COMMAND
      # i.e. cpuAndCmd = '1 rpc.statd' to CPU = '1' COMMAND = 'rcp.statd'
      #      cpuAndCmd = '1 mdadm' to CPU = '1' COMMAND = 'mdadm'
      if [regexp {([0-9]+)[ ]+(.*)} $cpuAndCmd dump CPU COMMAND] {
        # Nothing
      } else {
        set CPU 0
        set COMMAND $cpuAndCmd
      }
    
      dbgOut "------------------------"
      dbgOut "PID = '$PID', USER = '$USER', PRI = '$PRI', NI = '$NI', "
      dbgOut "SIZE = '$SIZE', RSS = '$RSS', SHARE = '$SHARE', STAT = '$STAT', "
      dbgOut "cpuPercent = '$cpuPercent', memPercent = '$memPercent', TIME = '$TIME', "
      dbgOut "CPU = '$CPU', COMMAND = '$COMMAND'"
    
      foreach EACH_CMD $CMD_LIST {
        if { [regexp "$EACH_CMD" "$COMMAND"] } {
          set inData 1
          set newCmdFound 1
          incr numThread 1
    
          # Set the command without thread
          regsub {/.*} "$COMMAND" {} cmdWOThread
    
          # Change the unit to megabyte
          # All value is add .0 to make it as a floating point
          if {"$osName" == "SunOS" && ![regexp {[0-9]+[MKm]} $SIZE]} {
            # Solaris shows value in byte therefore we need to divided by 1000000
            set SIZE [expr ${SIZE}.0 / 100000]
          } elseif {"$osName" == "Linux" && ![regexp {[0-9]+[MKm]} $SIZE]} {
            # Linux shows value in kilobyte therefore we need to divided by 1000
            set SIZE [expr ${SIZE}.0 / 1000]
          } elseif {"$osName" == "Windows" && ![regexp {[0-9]+[MKm]} $SIZE]} {
            # Windows shows value in kilobyte therefore we need to divided by 1000
            set SIZE [expr ${SIZE}.0 / 1000]
          }
    
          # If the value contains K, remove K character and divided by 1000
          if [regsub -- {K$} "$SIZE" {} SIZE] {
            set SIZE [expr ${SIZE}.0 / 1000]
          }
    
          # If the value contains M, remove M charater
          if [regsub -- {M$} "$SIZE" {} SIZE] {
            set SIZE ${SIZE}.0
          }
    
          # If the value contains m, remove m charater
          if [regsub -- {m$} "$SIZE" {} SIZE] {
            set SIZE ${SIZE}.0
          }
          
          # Increase memory usage only when found a new cmd
          #foreach {foundCmd foundSize} "$foundCmdList" {
          #  if {"$foundCmd" == "$cmdWOThread" && "$foundSize" == "$SIZE"} {
          #    set newCmdFound 0
          #  }
          #}
          #if {$newCmdFound} {
          #  set memUsage [expr $memUsage + $SIZE]
          #  lappend foundCmdList "$cmdWOThread" "$SIZE"
          #  set cmdWOThread {}
          #}
    
          # Increase cpu usage
          #set cpuUsage [expr $cpuUsage + $cpuPercent]
    
          set memUsage [expr $memUsage + $SIZE]
          set cpuUsage [expr $cpuUsage + $cpuPercent]
        } ;# Match the interesting command
      } ;# Foreach command
    
      # Detect new interval after the data is read
      # i.e."  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU COMMAND"
      if { [regexp {^[ ]+PID*} $line] && $inData } {
        set memUsage [expr $memUsage / $numThread]
        dbgOut "numThread = '$numThread'"
        dbgOut "memUsage = '$memUsage'"
        dbgOut "cpuUsage = '$cpuUsage'"
        set memUsageList "$memUsageList $memUsage"
        set cpuUsageList "$cpuUsageList $cpuUsage"
        set memUsage 0
        set cpuUsage 0
        set inData 0
        set foundCmdList {}
        incr count
        set numThread 0
      }
    } ;# foreach line
    
    # Last memory and CPU usage when get out of loop
    if {$inData} {
      set memUsage [expr $memUsage / $numThread]
      dbgOut "numThread = '$numThread'"
      dbgOut "memUsage = '$memUsage'"
      dbgOut "cpuUsage = '$cpuUsage'"
      set memUsageList "$memUsageList $memUsage"
      set cpuUsageList "$cpuUsageList $cpuUsage"
      incr count
      set inData 0
    }
    
    # Trim the usage
    set memUsageList [string trim $memUsageList]
    set cpuUsageList [string trim $cpuUsageList]
    
    # Find the average for memory
    foreach eachMemUsage $memUsageList {
      set totalMemUsage [expr $totalMemUsage + $eachMemUsage]
    }
    if {$count != 0} {
      set avgMemUsage [expr $totalMemUsage / $count]
    }
    
    # Find the average for CPU
    foreach eachCpuUsage $cpuUsageList {
      set totalCpuUsage [expr $totalCpuUsage + $eachCpuUsage]
    }
    if {$count != 0} {
      set avgCpuUsage [expr $totalCpuUsage / $count]
    }
    
    # Display information
    dbgOut "memUsageList = '$memUsageList'"
    dbgOut "cpuUsageList = '$cpuUsageList'"
    infOut "total number = '$count'"
    infOut "totalMemUsage= '$totalMemUsage' Mbyte, totalCpuUsage= '$totalCpuUsage' %"
    infOut "avgMemUsage  = '$avgMemUsage' Mbyte, avgCpuUsage  = '$avgCpuUsage' %"
    
    # write Result to log file consists of log details from expect command.
    genOut "###################################################################"
    genOut "CalPerf CPU Usage"
    genOut "###################################################################"
    genOut "memUsageList = '$memUsageList'"
    genOut "cpuUsageList = '$cpuUsageList'"
    genOut "total number = '$count'"
    genOut "totalMemUsage= '$totalMemUsage' Mbyte, totalCpuUsage= '$totalCpuUsage' %"
    genOut "avgMemUsage  = '$avgMemUsage' Mbyte, avgCpuUsage  = '$avgCpuUsage' %"
    
    close $fid
    return -code ok 0
}
###############################################################################
# PROCEDURE
#   iwait
#
# DESCRIPTION
#   Another wait function that update other background process every loop.
#
# ARGUMENTS
#   timeout - Time out in seconds. The proc will release to the next command after this timeout period.
#   str     - String to printout every second
###############################################################################
proc ::common::iwait {timeout {str {}}} {
    variable ARR_VAR

    set curTime   [clock seconds]
    set startTime [clock seconds]
    set diffTime  [expr $curTime - $startTime]
    set i         0

    while {$diffTime < $timeout} {
        update
        set curTime  [clock seconds]
        set diffTime [expr $curTime - $startTime]
        if {$diffTime >= $i} {
            puts -nonewline $str
            flush stdout
            incr i
        } else {
            after 10
        }
    }
    return -code ok 0
}
#***************************************************************
# PROCEDURE  
#        connect
#
# DESCRIPTION
#        start connecting Rtic on Remote Server
#
# ARGUMENTS
#       token           -   Fully qualifier name of an instance   
#      ?-spawn_id=?		-	log_spawn_id
#      ?-ssh?			-	...
#      ?-timeout=?      -   Increase expect timeout. default is 30. 
#
#***************************************************************
proc ::common::connect { token args } {
    variable ARR_VAR

    variable ${token}
    eval set machineList    $${token}(machineList)
    
    set tmp_spawn_id spawn_id
    set remote_login "telnet"
    set quick 0
    set sshkey 0
    set con_timeout 30
    # Parse option string
    foreach option $args {
        if {[regexp {^-([^=]*)=?(.*)} $option -> key value]} {
            switch -exact -- "-$key" {
                "-spawn_id" { set tmp_spawn_id $value }
                "-ssh"      { set remote_login "ssh"}
                "-sshkey"   { set remote_login "ssh";set sshkey 1}
                "-quick"    { set quick 1 }
                "-timeout"  { set con_timeout $value }
            }
        }
    }
    # check if remote_login is set in Config.txt
    if {[info exists ${token}(remote_login)]} {
        eval set remote_login $${token}(remote_login)
    }
    foreach machine $machineList {

        set ip      [ lindex $machine 0 ]
        set user    [ lindex $machine 1 ]
        set pass    [ lindex $machine 2 ]

        # support telnet with port, e.g. 192.168.1.8:8080
        if {$remote_login == "telnet"} {
           set port "23"
           set temp [split $ip ":"]
           if {[llength $temp] > 1} {
              set port [lindex $temp 1]
              set ip [lindex $temp 0]
           }
        }

        if { $ARR_VAR(FLAG) == 0 } { 
            # Spawn remote login session
            switch -- $remote_login {
                "telnet"    {exp_spawn telnet $ip $port}
                "ssh"       {exp_spawn ssh $user@$ip}
                "sshkey"    {exp_spawn ssh $user@$ip;set sshkey 1}
                default     {exp_spawn $remote_login $ip}
            }
            
            # if use SSH with an RSA key, no credential
            if {$sshkey} {
                expect {
                    -timeout 30
                    -re "$ARR_VAR(PROMPT)" {
                        dbgOut "sshkey used...no credential required"
                        exp_send "\r"
                    }
                    "Are you sure you want to continue connecting" {
                        exp_send "yes\r" 
                        exp_continue
                    } timeout {
                        errOut "Cannot connect to remote host: $ip ($user)"
                        return -code error "Cannot connect to remote host: $ip ($user)"
                    }
                }
            } else {
                set max_attempts 3
                # Supply with username and password if necessary
                expect { 
                    -timeout $con_timeout
                    -re "$ARR_VAR(LOGIN_PROMPT)" {
                        dbgOut "sending username..."                 
                        set send_human {.1 .3 1 .05 2}
                        exp_send -h "$user\r"
                        exp_continue
                    }
                    -re "$ARR_VAR(PASS_PROMPT)" {
                        dbgOut "sending password"                 
                        set send_human {.1 .3 1 .05 2}
                        exp_send -h "$pass\r"

                    }
                    "Are you sure you want to continue connecting" {
                        exp_send "yes\r" 
                        exp_continue
                    }
                    "Unable to connect to remote host" {
                        errOut "Unable to connect to remote host: $ip ($user)"
                        return -code error "Unable to connect to remote host: $ip ($user)"
                    }
                    "Login incorrect" {
                        if {$max_attempts} {
                            exp_send "\r"
                            wrnOut "Login incorrect. Retrying...($max_attempts)"
                            incr max_attempts -1
                            exp_continue
                        } else {
                            errOut "Login incorrect: $ip ($user)"
                            return -code error "Login incorrect: $ip ($user)"
                        }
                    }
                    "Connection refused" {
                        errOut "Connection refused: $ip ($user)"
                        return -code error "Connection refused: $ip ($user)"
                    }
                    "No route to host" {
                        errOut "No route to host: $ip ($user)"
                        return -code error "No route to host: $ip ($user)"
                    }
                    "Connection closed by foreign host" {
                        errOut "Connection closed by foreign host"
                        return -code error "Connection closed by foreign host"
                    }
                    "Host key verification failed" {
                        errOut "Host key verification failed. Can not ssh connected to host $ip."
                        return -code error "Host key verification failed. Can not ssh connected to host $ip."
                    }
                    -re "ssh.*?no address associated with name" {
                        errOut "No address associated with name. Can not ssh connected to host $ip."
                        return -code error "No address associated with name. Can not ssh connected to host $ip."
                    }
                
                    timeout {
                        errOut "Cannot connect to remote host: $ip ($user)"
                        return -code error "Cannot connect to remote host: $ip ($user)"
                    }
                }
            }
            ###Incase to make sure that prompt found after login
            expect {
                -timeout $con_timeout
                -re "$ARR_VAR(PROMPT)" {
                    dbgOut "Login ok...sending hostname"
                    exp_send "hostname\r"
                    expect {
                        -re "\[\r\n]+(\[^\r\n]+)\[\r\n]+" {
                            set ${token}(hostname) $expect_out(1,string)
                        }
                    }                
                } timeout {
                    errOut "Cannot connect to remote host: $ip ($user)"
                    return -code error "Cannot connect to remote host: $ip ($user)"
                }
            }
            # Store a new spawn_id in the instance's array variable 
            eval set ${token}($tmp_spawn_id) $spawn_id
            dbgOut "Current token properties"
            if {$ARR_VAR(DEBUG)} {parray ${token}}
            # After the first connection thru a telnet gateway, set FLAG
            set ARR_VAR(FLAG) 1
        } else {
            # support telnet with port, e.g. 192.168.1.8:8080
            if {$remote_login == "telnet"} {
               set port "23"
               set temp [split $ip ":"]
               if {[llength $temp] > 1} {
                  set port [lindex $temp 1]
                  set ip [lindex $temp 0]
               }
            }

            expect -re "$ARR_VAR(PROMPT)"   { 
                switch -- $remote_login {
                    "telnet"    {exp_send "telnet $ip $port\r"}
                    "ssh"       {exp_send "ssh $user@$ip\r"}
                    default     {exp_send "$remote_login $ip\r"}
                } 
            }
            expect { 
                -timeout $con_timeout
                -re "$ARR_VAR(LOGIN_PROMPT)" {
                    exp_send "$user\r"
                    exp_continue
                }
                -re "$ARR_VAR(PASS_PROMPT)" { 
                    exp_send "$pass\r" 
                    exp_continue
                }
                "Are you sure you want to continue connecting" {
                    exp_send "yes\r" 
                    exp_continue
                }
                "Unable to connect to remote host" {
                    errOut "Unable to connect to remote host: $ip ($user)"
                    return -code error "Unable to connect to remote host: $ip ($user)"
                }
                "Login incorrect" {
                    errOut "Login incorrect: $ip ($user)"
                    return -code error "Login incorrect: $ip ($user)"
                }
                "Connection refused" {
                    errOut "Connection refused: $ip ($user)"
                    return -code error "Connection refused: $ip ($user)"
                }
                "No route to host" {
                    errOut "No route to host: $ip ($user)"
                    return -code error "No route to host: $ip ($user)"
                }
                -re "$ARR_VAR(PROMPT)" { 
                    exp_send "hostname\r"
                    expect {
                        -re "\[\r\n]+(\[^\r\n]+)\[\r\n]+" {
                            set ${token}(hostname) $expect_out(1,string)
                        }
                    }  
                }
                timeout {
                    errOut "Cannot connect to remote host: $ip ($user)"
                    return -code error "Cannot connect to remote host: $ip ($user)"
                }
            }
        }
    }
    # Detect destinationremote host's OS. 
    # Store the value in the instance's array variable
    
    expect {
        -re "$ARR_VAR(PROMPT)" { 
            exp_send "uname -a\r"
        } timeout { 
            errOut "Cannot detect hostname."
            return -code error "Cannot detect hostname."
        }
    }
    expect {
            -re "\n(Linux|SunOS|CYGWIN|WindowsNT)" {
                exp_send "\r" 
                set ${token}(platform) $expect_out(1,string)
                dbgOut "Current token properties"
                if {$ARR_VAR(DEBUG)} {parray ${token}}
            } timeout { 
                errOut "Cannot detect system OS platform."
                return -code error "Cannot detect system OS platform."
            }
    }
    expect -re "$ARR_VAR(PROMPT)" { exp_send "TERM=vt100\r" }
    expect -re "$ARR_VAR(PROMPT)" { exp_send "exec bash\r" }
    
    set ARR_VAR(FLAG)   0           

    eval set real_spawn_id $${token}(spawn_id)
    eval set ${token}(spawn_id) $spawn_id

    if {!$quick} {
       # Run profile if exist
       loadProfile $token
       # Load env variable
       loadEnv $token
    }
    loadCmd $token

    eval set ${token}(spawn_id) $real_spawn_id
    
    return -code ok 0
}
#**************************************************** 
# PROCEDURE 
#       loadCmd
#
# DESCRIPTION
#        Load command after login
#        e.g.
#           INITCMD = net use z: \\10.42.37.18\incoming; net use x: \\192.168.1.100\share
#
# ARGUMENTS
#       token       -   Fully qualifier name of an instance  
#
#****************************************************
proc ::common::loadCmd { token } {
    variable ARR_VAR
    variable ${token}
    eval set spawn_id $${token}(spawn_id)
    
    dbgOut "loadCmd :: current spawn_id = $spawn_id"
    foreach {key value} [array get $token] {
        if {[regexp {INITCMD} $key]} {
            # split commands by ";"
            set cmds [split $value ";"]
            set len  [llength $cmds]
            exp_send "\r"
            for {set i 0} {$i < $len} {incr i} {
               expect -re "$ARR_VAR(PROMPT)" { exp_send "[lindex [string trim $cmds] $i]\r" }
               expect {
                   -timeout 10
                   -re "$ARR_VAR(PROMPT)"  {
                        
                   } timeout {
                       errOut "timeout loading commands"
                       return -code error "timeout loading commands"
                   }
               }          
            }
        }
    }    

    return -code ok 0
}
#**************************************************** 
# PROCEDURE 
#       loadEnv
#
# DESCRIPTION
#        Load environment variable according to Config.txt
#        e.g.
#           ENV_LD_LIBRARY_PATH = $LD_LIBRARY_PATH:/reuters/lib
#
#        the env variable in Config.txt should be prefix as
#        ENV_<system_env_variable>
#
# ARGUMENTS
#       token       -   Fully qualifier name of an instance  
#
#****************************************************
proc ::common::loadEnv { token } {
    variable ARR_VAR
    variable ${token}
    global env
    eval set spawn_id $${token}(spawn_id)
    
    eval set platform $${token}(platform)
    if { $platform == "WindowsNT" } {
       set CMD "set"
    } else {
       set CMD "export"
    }
    dbgOut "loadEnv :: current spawn_id = $spawn_id"
    foreach {key value} [array get $token] {
        if {[regexp {ENV_(.*)} $key -> key]} {
            exp_send "\r"
            expect -re "$ARR_VAR(PROMPT)" { exp_send "$CMD ${key}=${value}\r" }
            expect {
                -timeout 10
                -re "$ARR_VAR(PROMPT)"  { 
                } timeout {
                    errOut "timeout loading env variable"
                    return -code error "timeout loading env variable"
                }
            }       
        }
    }    
    exp_send "env\r"
    expect {
        -timeout 2
        "command not found" {}
    }
    return -code ok 0
}
#**************************************************** 
# PROCEDURE 
#       loadProfile
#
# DESCRIPTION
#        Execute profile files
#        e.g.
#           source_file = /home/myprofile
#
#        the function will execute 'source /home/myprofile'
#
# ARGUMENTS
#       token       -   Fully qualifier name of an instance  
#
#****************************************************
proc ::common::loadProfile { token {profile ""} } {
    variable ARR_VAR
    variable ${token}

    eval set spawn_id $${token}(spawn_id)

    dbgOut "loadProfile :: current spawn_id = $spawn_id"

    if {$profile != ""} {
        # If profile parameter is defined, used corresponding variable in token
        # Example:
        # if profile == myprofile then use ${token}(myprofile)
        eval set profile $${token}($profile)
    } else {
        if {[info exist ${token}(source_file)]} {
            # If profile is not defined, try to used to default one i.g. ${token}(source_file)
            eval set profile $${token}(source_file)
        } else {
            # If ${token}(source_file) doesn't exist. No profile to be load
            return -code ok 0
        }
    }

    exp_send "\r"
    expect -re "$ARR_VAR(PROMPT)" { exp_send "source $profile\r" }

    return -code ok 0
}
#******************************************************************************** 
# PROCEDURE 
#        changePath
#
# DESCRIPTION
#        Change path
#
# ARGUMENTS
#       token       -   Fully qualifier name of an instance  
#
#       path        -   Application's path
#
#********************************************************************************
proc ::common::changePath { token {path {}} } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id $${token}(spawn_id)
    if { $path == {} } {
        eval set path $${token}(run_path)
    }
    eval set platform $${token}(platform)
    if { $platform == "WindowsNT" } {
       set CD "cd /D"
    } else {
       set CD "cd"
    }    
    dbgOut "changePath :: current spawn_id = $spawn_id"
    exp_send "\r"
    expect -re "$ARR_VAR(PROMPT)"   { exp_send "$CD \"$path\" \r" }
    expect {
        -timeout 2
        ".* No such file or directory"  { 
            errOut "$expect_out(0,string)"
            return -code error "$expect_out(0,string)"
        } timeout { 
            return -code ok 0
        }
    }
}
#******************************************************************************** 
# PROCEDURE 
#        run
#
# DESCRIPTION
#        Send UNIX command to shell
#
# ARGUMENTS
#       token       -   Fully qualifier name of an instance  
#       cmd         -   command used to send to shell
#       expect_msg  -   expect message
#       time        -   time before the expect message is found
#       output_text -   name of vairable used to return result
#
#********************************************************************************
proc ::common::run { token cmd {expect_msg ""} {timeout 25} {output_text {}} } {
    variable ARR_VAR
    set token [searchToken $token]
    set ${token}(expout) ""
    
    eval set spawn_id   $${token}(spawn_id)
    
    dbgOut "run :: current spawn_id = $spawn_id"
    
    infOut "Sending $cmd"
    infOut "expect_msg $expect_msg"
    infOut "timeout $timeout"
    infOut "output_text $output_text"
    
    expect -re "$ARR_VAR(PROMPT)"       { exp_send "$cmd\r"   }
    
    # Looking for expected message. If not found within time, terminate comamnd 
    # and return
    expect {
        -timeout $timeout
        -re "$expect_msg" {
            set ${token}(expout) [array get expect_out]
            if {$output_text != ""} {
                upvar $output_text outputText
                set outputText $expect_out(0,string)
            }
            #exp_send    "\003"
        } timeout {
            errOut    "Time out in $timeout seconds!!!"
            exp_send    "\003"
            return -code error "Time out in $timeout seconds!!!"
        }
    }
 
    # Expected message is found or not, command should return prompt within time
    exp_send "\r"
    expect {
        -timeout $timeout
        -re "$ARR_VAR(PROMPT)" {
            exp_send "\r"
            return -code ok 0
        } timeout {
            # Can't expect prompt? Let's give another chance
            exp_send    "\003"
        }
    }
    expect {
        -timeout $timeout
        -re "$ARR_VAR(PROMPT)" {
            exp_send "\r"
        } timeout {
            errOut    "Time out in $timeout seconds!!!"
            exp_send    "\003"
            return -code error "Time out in $timeout seconds!!!"
        }
    }
 
    return -code ok 0
}
#**************************************************** 
# PROCEDURE 
#        closeSrcDist, closeSpawn
#
# DESCRIPTION
#        Close connection SrcDist on Remote Server.
#
# ARGUMENTS
#        token          -   Fully qualifier name of an instance 
#
#****************************************************
proc ::common::closeSpawn { token args } {
    variable ARR_VAR
    variable ${token}
    eval set platform   $${token}(platform)
    
    set ARR_VAR(FLAG) 0
    
    set tmp_spawn_id spawn_id
    # Parse option string
    foreach arg $args {
        set idx [string first "=" $arg]
        set key [string range $arg 0 [expr $idx - 1]]
        set val [string range $arg [expr $idx + 1] end]
        
        switch -- $key {
            "-spawn_id" {
               set tmp_spawn_id $val
            }
        }
    }

    set spawn_id [eval set ${token}($tmp_spawn_id)]

    dbgOut "Closing spawn_id = $spawn_id"
    
    set pid [exp_pid]
    close -i $spawn_id
    
    # to make sure that spawn is really closed 
    if { $::tcl_platform(os) == "Windows NT" } {
       exp_wait -i $spawn_id -nowait
       after 1000
       set round 3
       while {[regexp "\[\r\n\]\[^ \]+\[ \]+$pid " [exec tasklist]] && $round > 0} {
          exec taskkill /PID $pid
          incr round -1
       }   
    } else {
       wait
    }
    
    return -code ok 0
}

#********************************************************************************
# PROCEDURE 
#        registerCpuMsgHandler
#
# DESCRIPTION
#        Register the call back funtion to handle the event of cpu&mem message
#        of specified process.
#        When cpu and/or memery usage is changed the callback shall be invoked
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        msg_handler  -  name of function. Need full qualifier name. if the function is not in global namespace
#
#********************************************************************************
proc ::common::registerCpuMsgHandler { token msg_handler } {
    #------------------------------------------------------------------------
    # IMPORTANT!: 1. expect_background can access only global variable and thus
    #                we cannot save the msg_handler in a instance variable.
    #             2. It is not obvious but if expect commnad of same spawn id
    #                is invoked the expect_background will terminate.
    #                So the caller need to call this function to register
    #                again after calling the expect command of same spawn.
    #------------------------------------------------------------------------
    variable ARR_VAR
    variable ${token}
    
    if {[info exist ${token}(cpu_session_connected)] == 0} {
        dbgOut "Connecting CPU session..."

        ::common::connect $token -spawn_id=cpu_spawn_id

        eval set spawn_id          $${token}(cpu_spawn_id)
        eval set process_id        $${token}(process_id)
        eval set run_app           $${token}(run_app)
        
        # Remove some special charecters
        #set run_app [string trim $run_app "./ "]

        # SOLARIS platform
        # ----------------------------------------------------------------------------
        # 1. SIZE column for memory usage
        # 2. CPU column for CPU usage
        # COMMAND : prstat -p 339 -c 2 | grep src_dist
        # ----------------------------------------------------------------------------
        #   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP
        # ----------------------------------------------------------------------------
        #   339 root       21M   17M sleep   59    0   0:00.05 0.0% src_dist/5
        #   339 root       21M   17M sleep   59    0   0:00.05 0.0% src_dist/5
        #   339 root       21M   17M sleep   59    0   0:00.05 0.0% src_dist/5
        
        # LINUX platform
        # ----------------------------------------------------------------------------
        # 1. SIZE column for memory usage
        # 2. CPU column for CPU usage
        # COMMAND : top -b -d 2 -p 15728 | grep src_dist
        # ----------------------------------------------------------------------------
        #     PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU COMMAND
        # ----------------------------------------------------------------------------
        #   15728 root      15   0  8296 8292  2248 S     0.0  3.2   0:00   0 src_dist
        #   15728 root      15   0  8296 8292  2248 S     0.0  3.2   0:00   0 src_dist
        #   15728 root      15   0  8296 8292  2248 S     0.0  3.2   0:00   0 src_dist
        switch [eval set ${token}(platform)] {
            "SunOS" {
                #set CMD "prstat -p $process_id -c 2 | grep $process_id"
                switch [namespace qualifier $token] {
                    "::P2ps"    { 
                        set CMD "prstat -c 2 | grep p2ps"
                    }
                    "::SrcDist" {
                        set CMD "prstat -c 2 | grep src_dist"
                    }
                    "::Rtic" { 
                        set CMD "prstat -c 2 | grep rtic"
                    }
                    default {
                        set CMD "prstat -p $process_id -c 2 | grep $process_id" 
                    }
                }
                set reg_exp {[0-9\ ]+[ ]+[a-zA-Z]+[0-9a-zA-Z]*[ ]+[0-9MK\.]+[ ]+[0-9MK\.]+[ ]+[a-zA-Z]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+:[0-9]+\.[0-9]+[ ]+[0-9]+\.[0-9]+%[ ]+[0-9a-zA-Z\_\-\,\.]+[/][0-9]+}
                set mem_offset 2
                set cpu_offset 8
    
                append expect_info_string "-re {${reg_exp}\[^\r\n\]*} {"
                append expect_info_string "    set mem \[lindex \$expect_out(0,string) $mem_offset\]; "
                append expect_info_string "    set cpu \[lindex \$expect_out(0,string) $cpu_offset\]; "
                append expect_info_string "    $msg_handler \[namespace tail $token\] \$cpu \$mem; "
                append expect_info_string "    dbgOut \"I got \\\"\$expect_out(0,string)\\\"\"; "
                append expect_info_string "} "
            }
            "LinuxOS" -
            "Linux" {
                #set CMD "top -b -d 2 -p $process_id | grep $process_id"
                switch [namespace qualifier $token] {
                    "::P2ps"    { 
                        set CMD "top -b -d 2 | grep p2ps"

                        expect  -re "$ARR_VAR(PROMPT)"  { exp_send "top -b -n 1 | grep -v grep | grep -v mon | grep -v log | grep -c p2ps\r" }
                        expect  {
                            -timeout    2
                            -re "\n(\[0-9\]+)\[^\r\n\]*" {
                                set no_of_process $expect_out(1,string)
                            } timeout {
                                set no_of_process 1
                            }
                        }
                    }
                    "::SrcDist" {
                        set CMD "top -b -d 2 | grep src_dist"

                        expect  -re "$ARR_VAR(PROMPT)"  { exp_send "top -b -n 1 | grep -v grep | grep -v mon | grep -v log | grep -c src_dist\r" }
                        expect  {
                            -timeout    2
                            -re "\n(\[0-9\]+)\[^\r\n\]*" {
                                set no_of_process $expect_out(1,string)
                            } timeout {
                                set no_of_process 1
                            }
                        }
                    }
                    "::Rtic" { 
                        set CMD "top -b -d 2 | grep rtic"

                        expect  -re "$ARR_VAR(PROMPT)"  { exp_send "top -b -n 1 | grep -v grep | grep -v mon | grep -v log | grep -c rtic\r" }
                        expect  {
                            -timeout    2
                            -re "\n(\[0-9\]+)\[^\r\n\]*" {
                                set no_of_process $expect_out(1,string)
                            } timeout {
                                set no_of_process 1
                            }
                        }
                    }
                    default {
                        set CMD "top -b -d 2 -p $process_id | grep $process_id"

                        expect  -re "$ARR_VAR(PROMPT)"  { exp_send "top -b -n 1 -p $process_id | grep -c $process_id\r" }
                        expect  {
                            -timeout    2
                            -re "\n(\[0-9\]+)\[^\r\n\]*" {
                                set no_of_process $expect_out(1,string)
                            } timeout {
                                set no_of_process 1
                            }
                        }
                    }
                }
                set reg_exp {[0-9\ ]+[ ]+[a-zA-Z]+[0-9a-zA-Z]*[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9MK\.]+[ ]+[0-9MK\.]+[ ]+[0-9MK\.]+[ ]+[A-Z]+[ ]+[0-9]+\.[0-9]+[ ]+[0-9]+\.[0-9]+[ ]+[0-9]+:[0-9]+[ ]+[0-9]+[ ]+[0-9a-zA-Z\_\-\,\.]+}
                set mem_offset 4
                set cpu_offset 8

                append expect_info_string "-re {"
                for {set i 1} {$i < $no_of_process} {incr i} {
                    append expect_info_string "${reg_exp}\[\r\n\]+"
                }
                append expect_info_string "${reg_exp}\[^\r\n\]*} {"

                append expect_info_string "    set mem \[lindex \$expect_out(0,string) $mem_offset\]; "
                append expect_info_string "    set cpu \[lindex \$expect_out(0,string) $cpu_offset\]; "
                append expect_info_string "    set cpu \"\${cpu}%\"; "
                append expect_info_string "    set len \[string length \$mem\]; "
                append expect_info_string "    if {\[string index \$mem \[expr \$len - 1 \] \] == \"M\" || \[string index \$mem \$len\] == \"K\"} { } else { set mem \"\[expr \$mem / 1024\]M\"; } ; "
#                append expect_info_string "    set mem \"\[expr \$mem / 1024\]M\"; "
                append expect_info_string "    $msg_handler \[namespace tail $token\] \$cpu \$mem; "
                append expect_info_string "    dbgOut \"I got \\\"\$expect_out(0,string)\\\"\"; "
                append expect_info_string "} "
            }
            default {
                #set CMD "prstat -p $process_id -c 2 | grep $process_id"
                switch [namespace qualifier $token] {
                    "::P2ps"    { 
                        set CMD "prstat -c 2 | grep p2ps"
                    }
                    "::SrcDist" {
                        set CMD "prstat -c 2 | grep src_dist"
                    }
                    "::Rtic" { 
                        set CMD "prstat -c 2 | grep rtic"
                    }
                }
                set reg_exp {[0-9\ ]+[ ]+[a-zA-Z]+[0-9a-zA-Z]*[ ]+[0-9MK\.]+[ ]+[0-9MK\.]+[ ]+[a-zA-Z]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+:[0-9]+\.[0-9]+[ ]+[0-9]+\.[0-9]+%[ ]+[0-9a-zA-Z\_\-\,\.]+[/][0-9]+}
                set mem_offset 2
                set cpu_offset 8
    
                append expect_info_string "-re {${reg_exp}\[^\r\n\]*} {"
                append expect_info_string "    set mem \[lindex \$expect_out(0,string) $mem_offset\]; "
                append expect_info_string "    set cpu \[lindex \$expect_out(0,string) $cpu_offset\]; "
                append expect_info_string "    $msg_handler \[namespace tail $token\] \$cpu \$mem; "
                append expect_info_string "    dbgOut \"I got \\\"\$expect_out(0,string)\\\"\"; "
                append expect_info_string "} "
            }
        }

        expect {
            -re "$ARR_VAR(PROMPT)" {
                dbgOut "$CMD"
                exp_send "$CMD\r"
            }
        }

        set ${token}(cpu_session_connected) 1
    }

    eval set spawn_id $${token}(cpu_spawn_id)

#    infOut $expect_info_string
    
    expect_background -brace $expect_info_string
}
#********************************************************************************
# PROCEDURE 
#        registerSysCpuMsgHandler
#
# DESCRIPTION
#        Register the call back funtion to handle the event of cpu&mem message
#        of specified machine.
#        When cpu and/or memery usage is changed the callback shall be invoked
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        msg_handler  -  name of function. Need full qualifier name. if the function is not in global namespace
#
#********************************************************************************
proc ::common::registerSysCpuMsgHandler { token msg_handler } {
    #------------------------------------------------------------------------
    # IMPORTANT!: 1. expect_background can access only global variable and thus
    #                we cannot save the msg_handler in a instance variable.
    #             2. It is not obvious but if expect commnad of same spawn id
    #                is invoked the expect_background will terminate.
    #                So the caller need to call this function to register
    #                again after calling the expect command of same spawn.
    #------------------------------------------------------------------------
    variable ARR_VAR
    variable ${token}
    
    if {[info exist ${token}(sys_cpu_session_connected)] == 0} {
        dbgOut "Connecting CPU session..."

        ::common::connect $token -spawn_id=sys_cpu_spawn_id

        eval set spawn_id          $${token}(sys_cpu_spawn_id)
        eval set process_id        $${token}(process_id)
        eval set run_app           $${token}(run_app)
        
        # Remove some special charecters
        set run_app [string trim $run_app "./ "]

        eval set spawn_id $${token}(sys_cpu_spawn_id)
        
        set mem_offset 4
        set cpu_offset 21
        set mem_size 0
        # Determine 'CPU idle' column
        expect {
            -re "$ARR_VAR(PROMPT)" {
                # Filter only header row
                dbgOut "vmstat | grep id"
                exp_send "vmstat | grep id\r"
            }
        }
        expect {
            -re "r +.+ +id\[^\r\n\]*" {
                set mem_offset [lsearch $expect_out(0,string) "free"]
                set cpu_offset [lsearch $expect_out(0,string) "id"]
            }
        }
        if {[eval set ${token}(platform)] == "Linux" || [eval set ${token}(platform)] == "LinuxOS"} {
            expect {
                -re "$ARR_VAR(PROMPT)" {
                    # Filter only header row
                    dbgOut "cat /proc/meminfo | grep MemTotal\r"
                    exp_send "cat /proc/meminfo | grep MemTotal\r"
                }
            }
            expect {
                -re "MemTotal:\[ \]+(\[0-9\]+)\[ \]+kB\[^\r\n\]*" {
                    set mem_size $expect_out(1,string)
                    # Linux report mem in kbyte, we use Megabyte
                    set mem_size [expr $mem_size / 1024]
                }
            }
        } else {
            expect {
                -re "$ARR_VAR(PROMPT)" {
                    # Filter only header row
                    dbgOut "/usr/sbin/prtconf | grep Memory\r"
                    exp_send "/usr/sbin/prtconf | grep Memory\r"
                }
            }
            expect {
                -re "Memory size:\[ \]+(\[0-9\]+)\[ \]+Megabytes\[^\r\n\]*" {
                    set mem_size $expect_out(1,string)
                }
            }
        }
        if {$mem_size == "0"} {
            errOut "Cannot detect memory size on ${token}"
            return -code error "Cannot detect memory size on ${token}"
        }
        # SOLARIS platform
        # -------------------------------------------------------------------------------
        # 1. SIZE column for memory usage
        # 2. CPU column for CPU usage
        # COMMAND : vmstat 2
        # -------------------------------------------------------------------------------
        #  procs     memory            page            disk          faults      cpu
        #  r b w   swap  free  re  mf pi po fr de sr dd f0 s0 --   in   sy   cs us sy id
        # -------------------------------------------------------------------------------
        #  0 0 0 602712 94000   0   1  0  0  0  0  0  0  0  0  0  272 1370  565  0  0 100
        #  0 0 0 595368 80536   0   3  0  0  0  0  0  0  0  0  0  291 1388  604  0  0 100
        #  0 0 0 595368 80536   0   0  0  0  0  0  0  0  0  0  0  290 1354  599  0  0 100
        
        # LINUX platform
        # -------------------------------------------------------------------------------
        # 1. SIZE column for memory usage
        # 2. CPU column for CPU usage
        # COMMAND : vmstat 2
        # -------------------------------------------------------------------------------
        # procs                      memory      swap          io     system         cpu
        #  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy wa id
        # -------------------------------------------------------------------------------
        #  0  0  36884  12340  80408  15460    0    0     3     4    5     3  0  0  0  5
        #  0  0  36884  12324  80408  15460    0    0     0     0  169    79  0  0  0 100
        #  0  0  36884  12324  80408  15460    0    0     0     0  172    73  0  0  0 100
        switch [eval set ${token}(platform)] {
            "SunOS" {
                set CMD "vmstat 2"
                set reg_exp {[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+}
            }
            "LinuxOs" -
            "Linux" {
                set CMD "vmstat 2"
                set reg_exp {[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+}
            }
            default {
                set CMD "vmstat 2"
                set reg_exp {[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+[ ]+[0-9]+}
            }
        }

        expect {
            -re "$ARR_VAR(PROMPT)" {
                dbgOut "$CMD"
                exp_send "$CMD\r"
            }
        }

        set ${token}(sys_cpu_session_connected) 1
    }

    eval set spawn_id $${token}(sys_cpu_spawn_id)
    
    append expect_info_string "-re {${reg_exp}\[^\r\n\]*} {"
    append expect_info_string "    set mem \[lindex \$expect_out(0,string) $mem_offset\]; "
    append expect_info_string "    set cpu \[lindex \$expect_out(0,string) $cpu_offset\]; "
    append expect_info_string "    set cpu \"\[expr 100.0 - \$cpu\]%\"; "
    append expect_info_string "    set mem \"\[expr $mem_size - (\$mem / 1024)\]M\"; "
    append expect_info_string "    $msg_handler \[namespace tail $token\] \$cpu \$mem; "
    append expect_info_string "    dbgOut \"I got \\\"\$expect_out(0,string)\\\"\"; "
    append expect_info_string "} "

#   infOut $expect_info_string
    
    expect_background -brace $expect_info_string
}
#************************************************************************************
# PROCEDURE 
#        editConfigFile
#
# DESCRIPTION
#        edit(add/delete) and save configuration to a file on a remote host
#           *Enhancement* 
#				+ able to comment out lines
#               + file name is alias to value in Config.txt
#             
# ARGUMENTS
#       token          -    name of an instance
#
#       config_file    -    alias of full path name in Config.txt (default: config_file value in Config.txt)
#
#       action         -    add/delete/comment (defalut: add)
#
#       fs             -    field separator (default: whitespace)
#
#       config         -    list of config parameters in key-value format e.g.
#(code)
#                           ==== for addition(change) =========
#                           set config { 
#                                        {key_1}      {value_1}
#                                        {key_2}      {value_2}
#                                             ...
#                                        {key_N}      {value_N}
#                                      }
#                           
#                           ==== for deletion/comment =========
#                           set config { 
#                                        {key_1}
#                                        {key_2}
#                                          ...
#                                        {key_N}
#                                      }
#
#                           where {...} is a variable
#                           
#(end)
#************************************************************************************
namespace eval ::common:: { namespace import ::File::editConfigFile }

#*******************************************************************
# PROCEDURE 
#        restoreConfigFile
#
# DESCRIPTION
#        Restore a configuration file on a remote host
#        It simply rename a <config_file>.bak to <config_file>
#
# ARGUMENTS
#       token          -   name of an instance
#
#       config_file    -    alias of full path name in Config.txt
# 
#*******************************************************************
namespace eval ::common:: { namespace import ::File::restoreConfigFile }

#********************************************************************************
# PROCEDURE 
#        registerRRCPdumpMsgHandler
#
# DESCRIPTION
#        Register the call back funtion to handle rrdump message
#        of specified machine.
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        msg_handler  -  name of function. Need full qualifier name. if the function is not in global namespace
#
#********************************************************************************
proc ::common::registerRRCPdumpMsgHandler { token msg_handler } {
    variable ARR_VAR
    variable ${token}

    if {[info exist ${token}(rrcpdump_session_connected)] == 0} {
        dbgOut "Connecting CPU session..."

        ::common::connect $token -spawn_id=rrcpdump_spawn_id

        eval set spawn_id          $${token}(rrcpdump_spawn_id)
        eval set run_rrdump        $${token}(run_rrdump)
        eval set run_path          $${token}(run_path)

        if {[string index $run_rrdump 0] != "/"} {
            # Absolute path need to prefix with $run_path
            set run_rrdump "$run_path/$run_rrdump"
        }

        expect {
            -re "$ARR_VAR(PROMPT)" {
                exp_send "$run_rrdump\r"
            }
        }
        set ${token}(rrcpdump_session_connected) 1
    }

    eval set spawn_id $${token}(rrcpdump_spawn_id)

    set rrdump_list ""
    lappend rrdump_list { Total_pkts_sent             "Total pkts sent"                 }
    lappend rrdump_list { Msgs_from_users             "Msgs from users"                 }
    lappend rrdump_list { BC_pkts_sent                "BC pkts sent"                    }
    lappend rrdump_list { BC_msgs_from_users          "BC msgs from users"              }
    lappend rrdump_list { PP_pkts_sent                "PP pkts sent"                    }
    lappend rrdump_list { PP_msgs_from_users          "PP msgs from users"              }
    lappend rrdump_list { Total_pkts_rcvd             "Total pkts rcvd"                 }
    lappend rrdump_list { Msgs_to_users               "Msgs to users"                   }
    lappend rrdump_list { BC_pkts_rcvd                "BC pkts rcvd"                    }
    lappend rrdump_list { DATA_msgs_to_users          "DATA msgs to users"              }
    lappend rrdump_list { PP_pkts_rcvd                "PP pkts rcvd"                    }
    lappend rrdump_list { BC_DATA_msgs_to_users       "BC DATA msgs to users"           }
    lappend rrdump_list { BC_DATA_pkts_sent           "BC DATA pkts sent"               }
    lappend rrdump_list { PP_DATA_msgs_to_users       "PP DATA msgs to users"           }
    lappend rrdump_list { PP_DATA_pkts_sent           "PP DATA pkts sent"               }
    lappend rrdump_list { STATUS_msgs_to_users        "STATUS msgs to users"            }
    lappend rrdump_list { BC_DATA_pkts_rcvd           "BC DATA pkts rcvd"               }
    lappend rrdump_list { Bad_pkts/from_user          "Bad pkts/from user"              }
    lappend rrdump_list { PP_DATA_pkts_rcvd           "PP DATA pkts rcvd"               }
    lappend rrdump_list { Bad_pkts/from_net           "Bad pkts/from net"               }
    lappend rrdump_list { ACK_pkts_sent               "ACK pkts sent"                   }
    lappend rrdump_list { Discards/bad_opcode         "Discards/bad opcode"             }
    lappend rrdump_list { ACK_pkts_rcvd               "ACK pkts rcvd"                   }
    lappend rrdump_list { Discards/old_BC             "Discards/old BC"                 }
    lappend rrdump_list { RXMTREQ_pkts_sent           "RXMTREQ pkts sent"               }
    lappend rrdump_list { Discards/old_PP             "Discards/old PP"                 }
    lappend rrdump_list { Rxmt'd_BC_pkts_rcvd         "Rxmt'd BC pkts rcvd"             }
    lappend rrdump_list { Discards/rxmt'd_PP          "Discards/rxmt'd PP"              }
    lappend rrdump_list { DISCARD_pkts_rcvd           "DISCARD pkts rcvd"               }
    lappend rrdump_list { Msgs_filtered_out           "Msgs filtered out"               }
    lappend rrdump_list { RXMTREQ_pkts_rcvd           "RXMTREQ pkts rcvd"               }
    lappend rrdump_list { BC_msgs_misordered          "BC msgs misordered"              }
    lappend rrdump_list { Rxmt'd_BC_pkts_sent         "Rxmt'd BC pkts sent"             }
    lappend rrdump_list { PP_msgs_misordered          "PP msgs misordered"              }
    lappend rrdump_list { DISCARD_pkts_sent           "DISCARD pkts sent"               }
    lappend rrdump_list { Lost_data/BC_gaps           "Lost data/BC gaps"               }
    lappend rrdump_list { NULL_pkts_sent              "NULL pkts sent"                  }
    lappend rrdump_list { Lost_data/PP_gaps           "Lost data/PP gaps"               }
    lappend rrdump_list { NULL_pkts_rcvd              "NULL pkts rcvd"                  }
    lappend rrdump_list { Lost_data/node_resync       "Lost data/node resync"           }
    lappend rrdump_list { Rxmt'd_PP_pkts_rcvd         "Rxmt'd PP pkts rcvd"             }
    lappend rrdump_list { Lost_data/msg_dscrd'd       "Lost data/msg dscrd'd"           }
    lappend rrdump_list { Rxmt'd_PP_pkts_sent         "Rxmt'd PP pkts sent"             }
    lappend rrdump_list { Lost_data/incmplt_msg       "Lost data/incmplt msg"           }
    lappend rrdump_list { Unack'd_PP_pkts             "Unack'd PP pkts"                 }
    lappend rrdump_list { Lost_data/user_Q_overflow   "Lost data/user Q overflow"       }
    lappend rrdump_list { sendto_errors_n/a           "sendto\(\) errors \(n/a\)"       }
    lappend rrdump_list { Pkt_buffers_in_use          "Pkt buffers in use"              }
    lappend rrdump_list { recvfrom_errors_n/a         "recvfrom\(\) errors \(n/a\)"     }
    lappend rrdump_list { Msg_buffers_in_use          "Msg buffers in use"              }

    append expect_info_string "-re {Total pkts sent:.+Msg buffers in use: +(\[0-9\]+)} {"
    append expect_info_string "     set rrdump_output \$expect_out(0,string); set out_list \"\"; "
    append expect_info_string "     foreach key_val \{$rrdump_list\} { set out 0; set key \[lindex \$key_val 0\]; set val \[lindex \$key_val 1\]; regexp \"\${val}: +(\\\[0-9\\\]+)\" \$rrdump_output - out; lappend out_list \$out; }; "
    append expect_info_string "     $msg_handler \[namespace tail $token\] \$out_list; "
    append expect_info_string "     dbgOut \"I got \\\"\$out_list\\\"\"; "
    append expect_info_string "     dbgOut \"\$expect_out(spawn_id)\"; "
#    append expect_info_string "     if {\$RESET_RRCP == 1} { "
#    append expect_info_string "         exp_send -i \$expect_out(spawn_id) \"\\003\"; "
#    append expect_info_string "         exp_send -i \$expect_out(spawn_id) \"$cls_rrdump\\r\"; "
#    append expect_info_string "         exp_send -i \$expect_out(spawn_id) \"$run_rrdump\\r\"; "
#    append expect_info_string "         set RESET_RRCP 0; "
#    append expect_info_string "     };"
#    append expect_info_string "     incr RESET_RRCP;"
    append expect_info_string "} "

#    infOut $expect_info_string
    expect_background -brace $expect_info_string
}
#********************************************************************************
# PROCEDURE 
#        resetRRCPdump
#
# DESCRIPTION
#        Call command used to clear rrdump (cls_rrdump) of specified machine.
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#
#********************************************************************************
proc ::common::resetRRCPdump { token } {
    variable ARR_VAR
    variable ${token}
    eval set spawn_id          $${token}(spawn_id)
    eval set cls_rrdump        $${token}(cls_rrdump)
    eval set run_path          $${token}(run_path)

    if {[string index $cls_rrdump 0] != "/"} {
        # Absolute path need to prefix with $run_path
        set cls_rrdump "$run_path/$cls_rrdump"
    }

    expect {
        -re "$ARR_VAR(PROMPT)" {
            exp_send "$cls_rrdump\r"
        }
    }

    return -code ok 0
}
#********************************************************************************
# PROCEDURE 
#        registerRVMsgHandler
#
# DESCRIPTION
#        Register the call back funtion to handle the event of RVD webpage
#        of specified machine.
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        msg_handler  -  name of function. Need full qualifier name. if the function is not in global namespace
#
#********************************************************************************
proc ::common::registerRVMsgHandler { token msg_handler } {
    variable ARR_VAR
    variable ${token}

    eval set spawn_id $${token}(spawn_id)

    if {[info exist ${token}(rvdump_session_connected)] == 0} {
        dbgOut "Connecting CPU session..."

        ::common::connect $token -spawn_id=rvdump_spawn_id

        eval set spawn_id          $${token}(rvdump_spawn_id)
        eval set run_rvdump        $${token}(run_rvdump)
        eval set run_path          $${token}(run_path)

        if {[string index $run_rvdump 0] != "/"} {
            # Absolute path need to prefix with $run_path
            set run_rvdump "$run_path/$run_rvdump"
        }

        expect {
            -re "$ARR_VAR(PROMPT)" {
                exp_send "$run_rvdump\r"
            }
        }
        expect {
            -re "time,msgsIn,bytesIn,pktsIn,msgsOut,bytesOut,pktsOut" {
                ;# ok
            }
            timeout {
                errOut "cannot start rvdump script"
                return -code error "cannot start rvdump script"
            }
        }

        set ${token}(rvdump_session_connected) 1
    }

    eval set spawn_id $${token}(rvdump_spawn_id)

    set reg_exp {[0-9]+ [0-9]+ [0-9]+ [0-9]+}

    append expect_info_string "-re {${reg_exp}\[^\r\n\]*} { "
    append expect_info_string "    $msg_handler \[namespace tail $token\] \$expect_out(0,string); "
    append expect_info_string "} "

    expect_background -brace $expect_info_string

    return -code ok 0
}
#***************************************************************
# PROCEDURE 
#        initToken
#
# DESCRIPTION
#        Initilized token properties by reading from Config.txt
#
# ARGUMENTS
#        None
#                    
#***************************************************************
proc ::common::initToken { token } {
    set [uplevel 1 namespace current]::token $token
        
    namespace eval [uplevel 1 namespace current]:: {
        variable ARR_VAR
        variable ${token}
        global CONFIG_FILENAME
        set oldwd [pwd]
        # Check if tester explicitly specifies Config.txt location
        # Otherwise, change directory up two levels for Config.txt default location
        if { ![info exists CONFIG_FILENAME] } {
            cd ..
            cd ..
            set filename "Config.txt"
        } else {
            regsub -all {\\} $CONFIG_FILENAME {\\\\} filename
        }
        dbgOut "tester config file = $filename"
        dbgOut "Initialize ${token}.....looking for $filename"
        if { ![catch {set file [open $filename]}] } {      
            set data [read $file]
            close $file
            set isConfig 0
            set lines [split $data "\n"]
            foreach line $lines {
                set line [string trimleft $line]
                if { [regexp "^.$token\[\\]]" $line] && [regexp {^\[} $line] } {
                    set isConfig 1
                } elseif { [regexp {^\[} $line] } {
                    set isConfig 0
                } elseif { (![regexp {^#} $line]) && $isConfig} {
                    if {[regexp {([^=]*)=(.*)} $line -> key value]} {
                        set key [string trimright $key]
                        set value [string trimleft $value]
                        array set ${token} [list $key $value]
                    }
                }
            }
            if {[array size $token] == "0"} {
                return -code error "ERROR: $token is not defined in $filename"
            }
        } else {
            cd $oldwd
            return -code error "ERROR: Cannot locate $filename. Abort !!"
        }
        cd $oldwd
        dbgOut "Current token properties"
        if {$ARR_VAR(DEBUG)} {parray [namespace current]::${token}}
    }
}

# parray:
# Print the contents of a global array on stdout.
#
# RCS: @(#) $Id: parray.tcl,v 1.3 1998/09/14 18:40:03 stanton Exp $
#
# Copyright (c) 1991-1993 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Wiwat: use dbgOut instead of "puts stdout"

proc parray {a {pattern *}} {
    upvar 1 $a array
    if {![array exists array]} {
	error "\"$a\" isn't an array"
    }
    set maxl 0
    foreach name [lsort [array names array $pattern]] {
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    set maxl [expr {$maxl + [string length $a] + 2}]
    foreach name [lsort [array names array $pattern]] {
	set nameString [format %s(%s) $a $name]
	dbgOut [format "%-*s = %s" $maxl $nameString $array($name)]
    }
}

#********************************************************************************
# PROCEDURE 
#        manageWindowsService
#
# DESCRIPTION
#        manage windows service (start, stop)
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        serviceName  -  Service name, example "Dacs Sink Daemon"
#        action       -  "start" or "stop"
#
#********************************************************************************
proc ::common::manageWindowsService { token serviceName {action "start"} {timeout "25"} } {
    variable ARR_VAR
    variable ${token}
    set token [searchToken $token]
    eval set spawn_id          $${token}(spawn_id)

    expect -re "$ARR_VAR(PROMPT)" { exp_send "net $action \"$serviceName\"\r" }
    if {$action == "start"} {   
       expect {
       	    -timeout $timeout
            -re "The $serviceName service was started successfully" {
                infOut "Success: start service '$serviceName'"
		return -code ok 0
	    } -re "The requested service has already been started" {
		infOut "Success: service has already been started"
	        return -code ok 0	
            } timeout {
                errOut "Failed: can not start service '$serviceName'"
                return -code error "Failed: can not start service '$serviceName'"
            }
       }
    } elseif {$action == "stop"} {
       expect {
       	    -timeout $timeout
            -re "The $serviceName service was stopped successfully" {
                infOut "Success: stop service '$serviceName'"
		return -code ok 0
	    } -re "The $serviceName is not started" {
		infOut "Success: service is not started"
	        return -code ok 0	
	    } timeout {
                errOut "Failed: can not stop service '$serviceName'"
                return -code error "Failed: can not stop service '$serviceName'"
            }
       }
    } else {
       errOut "Wrong action name '$action'!!"
       return -code error "Wrong action name '$action'!!"
    }
}

#********************************************************************************
# PROCEDURE 
#        isWindowsProcessUp
#
# DESCRIPTION
#        check windows process up
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        process      -  Process name, example "notepad.exe" or "rvd.exe -listen tcp:7500" or Process id, example "7100"
#
#********************************************************************************
proc ::common::isWindowsProcessUp { token process } {
    variable ARR_VAR
    variable ${token}
    set token [searchToken $token]
    eval set spawn_id  $${token}(spawn_id)
    set ${token}(process_id) 0
    
    dbgOut "Checking windows process up..."
    
	set process [convertBackSlash $process]
	regsub -all {\"} $process {\"} process
    
    # process is process id
    if {[string is integer -strict $process]} {
	# use 'polist' command first
        expect -re "$ARR_VAR(PROMPT)" { exp_send "polist | grep -E \"^$process\"\r" }
	expect {
	       -timeout 3
               -re "\[\r\n\]$process\[ \t\]+" {
	           set grep_line [string trim $expect_out(0,string)]
	           set ${token}(process_id) $grep_line
	           return true
	       } -re "'polist' is not recognized as an internal or external command" {
	           # continue with other commands
	       } timeout {
                   return false	       
	       }
	}
	# if no 'polist', then use 'tlist'
	expect -re "$ARR_VAR(PROMPT)" { exp_send "tlist | grep -E \"^$process\"\r" }
	expect {
	       -timeout 3
               -re "\[\r\n\]$process\[ \t\]+" {
	           set grep_line [string trim $expect_out(0,string)]
	           set ${token}(process_id) $grep_line
	           return true
	       } -re "'tlist' is not recognized as an internal or external command" {
	           # continue with other commands
	       } timeout {
                   return false	       
	       }
	}
	# if no 'tlist', then use 'tasklist'
	expect -re "$ARR_VAR(PROMPT)" { exp_send "tasklist | grep -E \"^$process\"\r" }
	expect {
	       -timeout 3
               -re "\[\r\n\]\[A-Za-z\.\]+\[ \t\]+$process\[ \t\]+" {
                   set grep_line [string trim $expect_out(0,string)]
	           set grep_line [split $grep_line]
	           set ${token}(process_id) [lindex $grep_line [expr [llength $grep_line] - 1]]
	           return true
	       } -re "'tasklist' is not recognized as an internal or external command" {
	           # do nothing
	       } timeout {
                   return false	       
	       }
	}
    } else {
        # try command "polist" which develop by P'Ong+ ATE team first (to see arguments)
        expect -re "$ARR_VAR(PROMPT)" { exp_send "polist | grep -E \"$process\"\r" }	
        expect {
	    -timeout 3
	    -re "\[0-9\]+\[ \t\]+$process" {
	        set ${token}(process_id) [lindex [split $expect_out(0,string)] 0]
	        return true
            } -re "'polist' is not recognized as an internal or external command" {
	        # continue with other commands
  	    } timeout {
	        return false
	    }
	}
        
        expect -re "$ARR_VAR(PROMPT)" { exp_send "tlist | grep -E \"$process\"\r" }
        expect {
	   -timeout 3
           -re "\[0-9\]+\[ \t\]+$process" {
	       set ${token}(process_id) [lindex [split $expect_out(0,string)] 0]
	       return true
	   } -re "'tlist' is not recognized as an internal or external command" {
	       # continue with other commands
	   } timeout {
               return false	       
	   }
	}
	
	expect -re "$ARR_VAR(PROMPT)" { exp_send "tasklist | grep -E \"$process\"\r" }
        expect {
	   -timeout 3
           -re "$process\[ \t\]+\[0-9\]+" {
               set grep_line [string trim $expect_out(0,string)]
	       set grep_line [split $grep_line]
	       set ${token}(process_id) [lindex $grep_line [expr [llength $grep_line] - 1]]
	       return true
	   } -re "'tasklist' is not recognized as an internal or external command" {
	       # do nothing
	   } timeout {
               return false	       
	   }
	}
    }
    
    errOut "Unknown platform!!"
    return -code error "Unknown platform!!"        
}

#********************************************************************************
# PROCEDURE 
#        killWindowsProcess
#
# DESCRIPTION
#        kill windows process
#
# ARGUMENTS
#        token        -  Fully qualifier name of an instance
#        process      -  Process name or process id, example "notepad.exe" / "2017"
#
#********************************************************************************
proc ::common::killWindowsProcess { token process } {
    variable ARR_VAR
    variable ${token}
    set token [searchToken $token]
    eval set spawn_id $${token}(spawn_id)

    if {[isWindowsProcessUp $token $process]} {
	eval set process_id $${token}(process_id)
        dbgOut "Killing windows process..."
	exp_send "\r"
	expect -re "$ARR_VAR(PROMPT)" { exp_send "taskkill /F /PID $process_id\r" } 
	expect {
	       -timeout 2
	       -re "'taskkill' is not recognized as an internal or external command" {
		  expect -re "$ARR_VAR(PROMPT)" { exp_send "tskill $process_id\r" }
	       }
	}
        after 2000
	if {[isWindowsProcessUp $token $process_id]} {
	    errOut "Can not kill \"$process\" process!!"
	    return -code error "Can not kill \"$process\" process!!"
	} else {
	    infOut "\"$process\" process is already killed"
	    return -code ok 0
	}
    } else {
	infOut "No \"$process\" process running"
        return -code ok 0
    }
}

#**************************************************** 
# PROCEDURE 
#        kill
#
# DESCRIPTION
#        kill application from running command line on Windows and Unix platform
#
# ARGUMENTS
#        token           -   name of an instance
#        remote          -   0 use the old connection, 1 open new connection
#        process_command -   running command line
#
#****************************************************
proc ::common::kill { token {remote "1"} {process_command ""} } {
    variable ${token}
    variable ARR_VAR
    set token [searchToken $token]
    eval set platform   $${token}(platform)
    eval set spawn_id   $${token}(spawn_id)

    if {$process_command != ""} {
       set ${token}(process_command) $process_command
    }
    
    array set [namespace current]::token_t [array get $token]
    variable token_t

    if {[info exists token_t(process_command)] && $token_t(process_command) != ""} {
           if {$platform == "WindowsNT"} {   
               infOut "Killing application process  ..."
               if {$remote} {::common::connect [namespace current]::token_t}
               # set process_command to null if the process no longer run 
               if {![catch {::common::killWindowsProcess token_t $token_t(process_command)}]} {
                  set ${token}(process_command) ""
               }
               if {$remote} {::common::closeSpawn [namespace current]::token_t}
           } else {
               infOut "Killing application process  ..."
               if {$remote} {::common::connect [namespace current]::token_t; set spawn_id $token_t(spawn_id)}
               if {$process_command == ""} {
                  eval set runapp $${token}(run_app)
               } else {
                  eval set runapp $${token}(process_command)
               }
               set output {}
               set dump {}
               set PID {}
               set expect {([0-9]+)[^\r\n]+}
               append expect $runapp
               exp_send "\r"
               expect -re "$ARR_VAR(PROMPT)" { exp_send "ps -ef | grep \"$runapp\" | grep -v grep\r"}
               # kill get process id
               expect {
                  -timeout 3
                  -re "$expect"  {
                      set PID $expect_out(1,string)
                      expect -re "$ARR_VAR(PROMPT)" { exp_send "kill -9 $PID\r" }
                      expect -re "$ARR_VAR(PROMPT)" { exp_send "\r" }
                      expect -re "$ARR_VAR(PROMPT)" { exp_send "ps -ef | grep \"$runapp\" | grep -v grep\r"}
                      expect {
                         -timeout 2
                         -re "$expect" { }
                         timeout { set ${token}(process_command) "" }
                      }
                  } timeout { set ${token}(process_command) ""}
               }

               if {$remote} {::common::closeSpawn [namespace current]::token_t; eval set spawn_id $${token}(spawn_id)}
           }
           exp_send "\r"
    }

    array unset [namespace current]::token_t
}

#********************************************************************************
# PROCEDURE 
#        pause
#
# DESCRIPTION
#        An auxilary function to wait for n seconds
#
# ARGUMENTS
#        token       - ...
#
#********************************************************************************
proc ::common::pause { time } {
    set ::wait 0
    after [regsub "\\.\[0-9]*" [expr $time*1000] ""] {set ::wait 1}
    vwait wait
}

#********************************************************************************
# PROCEDURE 
#        clnRMDSProc
#
# DESCRIPTION
#        This proc is initially designed for killing RMDS-related processes
#        
#        Note:
#        1) Even though duplicate token name on different namespaces is allowed
#           It will not work here. It works as one-token-one-app cases only
#        2) Order in applist is important when killing a process, it may be respanwed
#
#        usage
#        ::common::clnRMDSProc token -applist=src_dist,rtic
#        or
#        ::common::clnRMDSProc token -applist="src_dist,rtic"
#        or
#        clnRMDSProc token -applist=src_dist,rtic      (recommended)
#
# ARGUMENTS
#        token        - ...
#        -applist     - application list to be killed e.g. -applist=rdtic,myapp,rvd,rrcp
#
#********************************************************************************
proc ::common::clnRMDSProc { token args } {
    loadConfig
    global CONFIG_FILENAME
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id $${token}(spawn_id)
    
    # default apps to be kill/pkill
    set applist {src_dist,p2ps,rtic,rdtic,mcs,hrm,ciServer,rmdstestclient,rtictest,sass3capture,sink_app,sink_driven_src,\
                 snkmnttest,example,Tib_consume3,rsslSinkApp,rrcpd,rvd}
    set timeout 1
    # Parse option string
    dbgOut "options: $args"
    foreach option $args {
        if {[regexp {^-([^=]*)=?(.*)} $option -> key value]} {
            switch -exact -- "-$key" {
                "-applist" { set applist $value }
                "-timeout" { set timeout $value }
            }
        }
    }
    # Clean up sharememory and semaphore key
    if {[regexp -all "," $applist] > 4 } {    
        if {[info exists SHM_KEYS]} {
            set shmList [split $SHM_KEYS ',']
            set shmCommand ""
            foreach shmkey $shmList {
                append shmCommand "ipcrm -M $shmkey;"
            }
            exp_send "\r"
            pause 1
            exp_send "$shmCommand\r"
            #errOut $shmCommand
        }
        
        if {[info exists SMP_KEYS]} {
            set smpList [split $SMP_KEYS ',']
            set smpCommand ""
            foreach smpkey $smpList {
                append smpCommand "ipcrm -S $smpkey;"
            }
            exp_send "\r"
            pause 1
            exp_send "$smpCommand\r"
            #errOut $smpCommand
        }
    }
    
    regsub -all {,} $applist { } applist
    dbgOut "applist: $applist"
    # First try with "pkill"
    foreach app $applist {
        exp_send "\r"
        expect {
            -re "$ARR_VAR(PROMPT)" {
                exp_send "pgrep -x $app\r"
            } timeout {
                errOut "Can't see prompt. Skip pkill $app"
                continue
            }
        }
        expect {
            -timeout $timeout
            -re "\n\[0-9\]+" {
                exp_send "pkill $app\r"
                dbgOut "Sending... pkill $app"
            } timeout {
            }
        }        
    }

    # Second try with "pkill -9"
    foreach app $applist {
        exp_send "\r"
        expect {
            -re "$ARR_VAR(PROMPT)" {
                exp_send "pgrep -x $app\r"
            } timeout {
                errOut "Can't see prompt. Skip pkill -9 $app"
                continue
            }
        }
        expect {
            -timeout $timeout
            -re "\n\[0-9\]+" {
                exp_send "pkill -9 $app\r"
                dbgOut "Retry... pkill -9 $app"
            } timeout {
            }
        }        
    }
    
    # Print summary
    foreach app $applist {
        exp_send "\r"
        expect {
            -re "$ARR_VAR(PROMPT)" {
                exp_send "pgrep -x $app\r"
            } timeout {
                errOut "Can't see prompt. Skip check status of $app"
                continue
            }
        }
        expect {
            -timeout $timeout
            -re "\n\[0-9\]+" {
                dbgOut "[format "%-*s%s" 20 $app "\[ Up ]"]"
            } timeout {
                dbgOut "[format "%-*s%s" 20 $app "\[Down]"]"
            }
        }        
    }
    return -code ok 0
}

#********************************************************************************
# PROCEDURE 
#        stty
#
# DESCRIPTION
#        Detect and set display windows resolution
#        
# ARGUMENTS
#        token          -   name of an instance
#       ?rows=?			-	e.g. rows=24
#       ?cols=?			-	e.g. cols=80
#
#********************************************************************************
proc ::common::stty { token args } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id $${token}(spawn_id)
    
    array set OPTS {
    }
    set rows ""
    set cols ""

    exp_send "\r"
    expect -re "$ARR_VAR(PROMPT)" { exp_send "stty -a\r" }
    expect {
        -re "rows\[^0-9]+(\[0-9]+); columns\[^0-9]+(\[0-9]+);" {
            set OPTS(rows) $expect_out(1,string)
            set OPTS(cols) $expect_out(2,string)
            infOut "Before adjusted resolution = $OPTS(rows)x$OPTS(cols)"
        } timeout {
            return -code error "Cannot get display resolution"
        }
	} 
	
    foreach option $args {
        if {[regexp {^-([^=]*)=(.*)} $option -> key value]} {
            switch -exact -- "-$key" {
                "-rows"         { set rows     "$value" }
                "-cols"         { set cols     "$value" }
                default         { return -code error "There is no -$key option" }
            }
        } 
        
        eval set default $OPTS($key)
        if { $value != "" } {
            if { $value != $default } {
                expect -re "$ARR_VAR(PROMPT)" { exp_send "stty $key $value\r" }
                set OPTS($key) $value
            } 
        }
    }
    
    exp_send "\r"
    expect -re "$ARR_VAR(PROMPT)" { exp_send "stty -a\r" }
    expect {
        -re "rows\[^0-9]+(\[0-9]+); columns\[^0-9]+(\[0-9]+);" {
            set rows $expect_out(1,string)
            set cols $expect_out(2,string)
            
            if { $rows == $OPTS(rows) && $cols == $OPTS(cols) } {
            	infOut "After adjusted resolution = $OPTS(rows)x$OPTS(cols)"
                return -code ok 0
            } else {
                return -code error "Fail to adjust display resolution"
            }

        } timeout {
            return -code error "Cannot detect display resolution"
        }
    }
    
}

#********************************************************************************
# PROCEDURE 
#        getHostname
#
# DESCRIPTION
#        Get machine hostname
#
#           usage:
#               set param_name [::common::getHostname token]
#
#           Note: This proc is initially design for RMDS so hostname value should 
#                 contain only character and number.
#        
# ARGUMENTS
#        token          -   name of an instance
#
#********************************************************************************
proc ::common::getHostname { token } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id $${token}(spawn_id)

    expect {
        -re "$ARR_VAR(PROMPT)" { 
            exp_send "echo \$HOSTNAME\r"
        } timeout { 
            errOut "Cannot detect prompt."
            return -code error "Cannot detect prompt."
        }
    }
    expect {
            -re "HOSTNAME\[\r\n]+(\[a-zA-Z0-9\-]+)\[\r\n]+" {
                exp_send "\r" 
                set retrieved_param $expect_out(1,string)
                dbgOut "Hostname is $retrieved_param."
            } timeout { 
                errOut "Cannot detect hostname."
                return -code error "Cannot detect hostname."
            }
    }

    return -code ok $retrieved_param
}

#********************************************************************************
# PROCEDURE 
#        ping
#
# DESCRIPTION
#        Check ping reply
#        return 1 -> got ping reply
#        return 0 -> no ping reply
#        
# ARGUMENTS
#        token          -   name of an instance
#        ipaddress      -   ip address of the destination machine
#        number         -   number of echo requests to send (default 3)
#
#********************************************************************************
proc ::common::ping {ipaddress {number 3}} {
    log_user 0
    spawn ping $ipaddress -n $number
    expect {
       -timeout [expr $number+1]
       -re "Reply from $ipaddress" {
           set ret 1
       } timeout {
           set ret 0
       }
    }
    log_user 1
    return $ret
}

#********************************************************************************
# PROCEDURE 
#        getHostArchitect
#
# DESCRIPTION
#        Get machine architecture
#
#           usage:
#               set param_list [::common::getHostArchitect token]
#
#               set OSplatform [ lindex $param_list 0 ]
#               set OSversion  [ lindex $param_list 1 ]
#               set Architect  [ lindex $param_list 2 ]
#
#           Note: This proc is initially design for RMDS so it supports only 
#                 Solaris and Linux platforms.
#        
# ARGUMENTS
#        token          -   name of an instance
#
# NOTE
#   This proc will return value as list with detail as follows:
#       OS platform   - Solaris Sparc, Solaris X86, Redhat, ...
#       OS version    - Redhat 4, Redhat 5, SuSE 9, ...
#       Architect     - 32-bit, 64-bit
#
#********************************************************************************
proc ::common::getHostArchitect { token } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id $${token}(spawn_id)
    eval set platform $${token}(platform)
    eval set run_path $${token}(run_path)

    ## Split command
    eval set run_cmd $${token}(run_app)
    set cmd [split $run_cmd " "]
    set run_app [ lindex $cmd 0 ]
    dbgOut "run_app = $run_app"

    ::common::run $token "cd $run_path\r"

    if {$platform == "SunOS"} {
#         dbgOut "platform = $platform"
        set OSversion "10"
        expect {
            -re "$ARR_VAR(PROMPT)" { 
                exp_send "file $run_app | grep SPARC\r"
                expect {
                    -timeout 5
                    -re ":\[ ]+ELF " {
                        exp_send "file $run_app | grep SPARC\r"
                        set OSplatform "SPARC"
                    } timeout {
                        exp_send "file $run_app \r"
                        set OSplatform "X86"
                    }
                }
            } timeout { 
                errOut "Cannot detect prompt."
                return -code error "Cannot detect prompt."
            }
        }
    } elseif  {$platform == "Linux"} {
#         dbgOut "platform = $platform"
        expect {
            -re "$ARR_VAR(PROMPT)" {
                exp_send "cat /etc/redhat-release\r"
                expect {
                    -timeout 5
                    -re "release (\[0-9]+)" {
                        exp_send "file $run_app\r"
                        set OSplatform "Redhat"
                        set OSversion $expect_out(1,string)
                    } timeout {
                        exp_send "file $run_app\r"
                        set OSplatform "SuSE"
                        exp_send "cat /etc/SuSE-release\r"
                        expect {
                            -timeout 5
                            -re "VERSION = (\[0-9]+)" {
                                exp_send "file $run_app\r"
                                set OSversion $expect_out(1,string)
#                                 dbgOut "$OSplatform release $OSversion"
                            } timeout {
                                errOut "Cannot detect OS platform."
                                return -code error "Cannot detect OS platform."
                            }
                        }
                    }
                }
            } timeout {
                errOut "Cannot detect prompt."
                return -code error "Cannot detect prompt."
            }
        }
    } else {
        errOut "This function does not support $platform platform."
        return -code error "This function does not support $platform platform."
    }

    expect {
        -re ":\[ ]+ELF (\[a-z0-9\-]+) " {
            exp_send "\r\n"
            set architect $expect_out(1,string)
            dbgOut "Architecture is $architect."
        } timeout {
            errOut "Cannot detect architecture."
            return -code error "Cannot detect architecture."
        }
    }

    set retrieved_param $OSplatform
    lappend retrieved_param $OSversion    
    lappend retrieved_param $architect
    return -code ok $retrieved_param
}
#**************************************************** 
# PROCEDURE 
#       expectRandomMsg
#
# DESCRIPTION
#       Monitor expected messages which random occur.
#
# ARGUMENTS
#       token           -   name of an instance
#       app_para        -   application parameter. leave it's "-" if not run application 
#       msg_array       -   array of expected messages
#       continue        -   0 run and break(^c) , 1 run
#       timeout         -   timeout in seconds
#****************************************************
proc ::common::expectRandomMsg { token app_para msg_array {continue "0"} {timeout "60"} } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id   $${token}(spawn_id)
    eval set run_app    $${token}(run_app)
    eval set run_path   $${token}(run_path)
    
    # for return expected messages which not found
    set ${token}(notfoundList) {}

    dbgOut "expectRandomMsg :: current spawn_id = $spawn_id"
    set expsize 0;
    set expmsg ""
    set i 0
    set arrsize [llength $msg_array]
   
    foreach msg $msg_array {    
       incr i
       set arrmsg($i) $msg
       if {[regexp {[][()]} $msg]} { 
           regsub -all {[^(]} $msg "" words;
           if {[string length $words]>0} {
              set expsize [expr $expsize + [expr [string length $words]]] 
           } else {
              incr expsize 
           }
       } else {
           incr expsize 
       }

       append expmsg "($msg)"
       if {$i < $arrsize} {
          append expmsg "|"
       }
    }

    # run application if app_para is not "-"
    if {$app_para != "-"} {
        ::common::changePath $token $run_path
        expect -re "$ARR_VAR(PROMPT)" { exp_send "$run_app $app_para \r" }
    }
    dbgOut $expmsg
    while {$arrsize != 0} {
        array unset expect_out
        expect {
           -timeout $timeout
           -re "$expmsg" {          
              for {set i 1} {$i <= $expsize} {incr i} {
                 #dbgOut "$expect_out($i,string)";
                 if {[info exists expect_out($i,string)] && $expect_out($i,string) != "\$"} {        
                    dbgOut "Found the expected message: $expect_out($i,string)" 
                    break
                 }
              }     
           } timeout {
              errOut "Time out in $timeout seconds!!!"
              # add not found messages to the list
              foreach {num msg} [array get arrmsg] {
                 lappend ${token}(notfoundList) "$msg"
              }
              return $ARR_VAR(FAIL)
           } 
        }

        incr arrsize -1

        # found all messages then return PASS
        if {$arrsize == 0} { 
           if {!($continue)} { 
              exp_send "\003" 
              # Detect prompt after exit the application
              expect {
                 -timeout $timeout
                 -re "$ARR_VAR(PROMPT)" { 
                     exp_send "\r" 
                  } timeout {
                     errOut "No prompt after exit the applicaiton!!!"
                     return -code error "No prompt after exit the application!!!"  
                  }
              }
           }
           return $ARR_VAR(PASS) 
        # not all messsages found then delete the message already found out from array list.
        } else {
           set expmsg ""
           set j 0
           foreach {num msg} [array get arrmsg] {
              if {[regexp -- "$msg" $expect_out($i,string)]} {
                 array unset arrmsg "$num"
                 break
              }
           }
           foreach {num msg} [array get arrmsg] {
              incr j
              append expmsg "($msg)"
              if {$j < $arrsize} {
                 append expmsg "|"
              }
           }   
        }
    }
    return  $ARR_VAR(PASS)
}
#**************************************************** 
# PROCEDURE 
#       sendDirectCmd
#
# DESCRIPTION
#       Send direct command to console by expect
#
# ARGUMENTS
#       token       -   name of an instance
#       cmd         -   command that user want to send to console (Please add \\r if want to send enter key)
#
#****************************************************
proc ::common::sendDirectCmd { token cmd } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id   $${token}(spawn_id)

    dbgOut "sendDirectCmd :: current spawn_id = $spawn_id"
    exp_send "$cmd"
}
#**************************************************** 
# PROCEDURE 
#       getExpectRandomMsgResult
#
# DESCRIPTION
#       Monitor expected messages which random occur and return string result
#
# ARGUMENTS
#       token           -   name of an instance
#       expmsg          -   expected messages
#       timeout         -   timeout in seconds (Default is 60 seconds)
#
#****************************************************
proc ::common::getExpectRandomMsgResult { token expmsg {timeout "60"} } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id   $${token}(spawn_id)

    dbgOut "getExpectRandomMsgResult :: current spawn_id = $spawn_id"
    expect {
       -timeout $timeout
       -re "$expmsg" {          
            return $expect_out(0,string)
       } timeout {
          errOut "Time out in $timeout seconds!!!"
          return -code error "Can not find expect message '$expmsg'.Time out in $timeout seconds!!!"
       }
    }
}
#***************************************************************
# PROCEDURE 
#        loadConfig
#
# DESCRIPTION
#         load variables from Config.txt
#
# ARGUMENTS
#        None
#                    
#***************************************************************
proc loadConfig {} {
    global CONFIG_FILENAME
    variable ARR_VAR
    set oldwd [pwd]
    set isConfig 0
    if { ![info exists CONFIG_FILENAME] } {
        cd ..
        cd ..
        set filename "Config.txt"
    } else {
        regsub -all {\\} $CONFIG_FILENAME {\\\\} filename
    }
    if { ![catch {set file [open $filename]}] } {      
        set data [read $file]
        close $file
        set isConfig 0
        set lines [split $data "\n"]
        foreach line $lines {
            set line [string trimleft $line]
            if { [ regexp {^\[service_names\]|^\[metadata\]} $line ] } {
                set isConfig 1
            } elseif { [regexp {^\[} $line] } {
                set isConfig 0
            } elseif { (![regexp {^#} $line]) && $isConfig} { 
                if {[regexp {([^=]*)=(.*)} $line -> key value]} {
                    set key [string trimright $key]
                    set value [string trimleft $value]
                    regsub -all {\\} $value {\\\\} temp
                    regsub -all {\[} $temp {\\[} temp
                    regsub -all {\$} $temp {\\$} temp
                    uplevel set $key \"$temp\"
                }
            }
        }
    } else {
        cd $oldwd
        return -code error "ERROR: Cannot locate $filename. Abort !!"
    }
    cd $oldwd
}

#***************************************************************
# PROCEDURE 
#        convertFieldNameToFieldID
#
# DESCRIPTION
#         Convert field name to field id using RDMFieldDictionary to reference.
#         Require define global variable RDMFieldDictionary point to RDMFieldDictionary file in Config.txt
#
# ARGUMENTS
#        fieldName           -   field name
#
# RETURN
#        fieldID             -   field Id
#                    
#***************************************************************
proc ::common::convertFieldNameToFieldID { fieldname } {
    variable DATA_DICT
    variable RDMFieldDictionary
    # Verify RDMFieldDictionary is define or not
    if {![info exists RDMFieldDictionary]} {
        loadConfig
    }
    if { [array size DATA_DICT] == 0} {
        set dictFile [read [open $RDMFieldDictionary]]
        set dictlines [split $dictFile "\n"]
        foreach line $dictlines {
            if {[regexp {^!} $line]} {
                continue
            }
            if {[regexp {(^[A-Za-z0-9_]+)[ \t]+(\"[A-Za-z0-9_ \'/]+\")[ \t]+([-]?[0-9]+)[ \t]+([A-Za-z0-9_]+)[ \t]+([A-Za-z0-9_]+)[ \t]+([0-9]+[ \t]+\([ \t]+[0-9]+[ \t]+\))[ \t]+([A-Za-z0-9_]+)[ \t]+([0-9]+)} $line -> ACRONYM DDE_ACRONYM FID RIPPLES_TO FIELD_TYPE LENGTH RWF_TYPE RWF_LEN]} {
                set DATA_DICT($ACRONYM) [list $DDE_ACRONYM $FID $RIPPLES_TO $FIELD_TYPE $LENGTH $RWF_TYPE $RWF_LEN]
            } elseif {[regexp {(^[A-Za-z0-9_]+)[ \t]+(\"[A-Za-z0-9_ \'/]+\")[ \t]+([-]?[0-9]+)[ \t]+([A-Za-z0-9_]+)[ \t]+([A-Za-z0-9_]+)[ \t]+([0-9]+)[ \t]+([A-Za-z0-9_]+)[ \t]+([0-9]+)} $line -> ACRONYM DDE_ACRONYM FID RIPPLES_TO FIELD_TYPE LENGTH RWF_TYPE RWF_LEN]} {
                set DATA_DICT($ACRONYM) [list $DDE_ACRONYM $FID $RIPPLES_TO $FIELD_TYPE $LENGTH $RWF_TYPE $RWF_LEN]
            }
        }
    }
    return [lindex $DATA_DICT($fieldname) 1]
}
#***************************************************************
# PROCEDURE 
#       monitor
#
# DESCRIPTION
#       This procedure will monitor expected message and assign expect_out parameter to the token.
#
# ARGUMENTS
#       token          -   name of an instance
#	expect_msg     -   expected result
#       continue       -   0 run and break(^c) , 1 run
#       timeout        -   timeout in seconds
#                    
#***************************************************************
proc ::common::monitor { token expect_msg {continue "0"} {timeout "25"} } {
    variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id   $${token}(spawn_id)
    eval set run_app    $${token}(run_app)
    eval set platform   $${token}(platform)
    set ${token}(error) ""
    set ${token}(expout) ""
    
    dbgOut "monitor :: current spawn_id = $spawn_id"
    dbgOut "expect_msg :: $expect_msg"
    # To search expected message on message box
    expect {
        -timeout $timeout
        -re "$expect_msg" {
            dbgOut "Found: $expect_out(0,string)"
            set pass 1
            set ${token}(expout) [array get expect_out]
            set ${token}(expect_out) [array get expect_out "*,string"]
        } 
        timeout {
            errOut "Time out in $timeout seconds!!!"
            set ${token}(error) "Time out in $timeout seconds!!!"
            set pass 0
            set ${token}(expect_out) ""
        }
    }
   
    if {!($continue)} {
          exp_send "\003"
          expect {
             -timeout $timeout
             -re "$ARR_VAR(PROMPT)" { 
                 exp_send "\r"
             } timeout {
                 errOut "No prompt after exit the applicaiton!!!"
                 set ${token}(error) "No prompt after exit the applicaiton!!!"
                 return -code error "No prompt after exiting the application!!!"  
             }
          }   
    }

    if {$pass} { return -code ok 0 } else { return -code error "Time out in $timeout seconds!!!" }
}
#***************************************************************
# PROCEDURE 
#       verifyValgrindMemleak
#
# DESCRIPTION
#       This procedure view grep all log valgrind memory leak into array.
#			definitely lost:    means your program is leaking memory -- fix those leaks!
#			indirectly lost:    means your program is leaking memory in a pointer-based structure. If you fix the "definitely lost" leaks, the "indirectly lost" leaks should go away.
#			possibly lost:      means your program is leaking memory, unless you're doing unusual things with pointers that could cause them to point into the middle of an allocated block.
#			still reachable:    means your program is probably ok -- it didn't free some memory it could have. 
#			suppressed:         means that a leak error has been suppressed. There are some suppressions in the default suppression files.
#
# ARGUMENTS
#       token          			-   name of an instance
#		?=valgind_log_file?    	-   valgrind log file  (Default loading from Config.txt)
#       ?=timeout?        		-   timeout in seconds (Default is 5 seconds)
#
#                    
#***************************************************************
proc ::common::verifyValgrindMemleak { token args } {
	variable ARR_VAR
    set token [searchToken $token]
    eval set spawn_id   		$${token}(spawn_id)
    eval set platform   		$${token}(platform)
	
	dbgOut "verifyValgrindMemleak :: current spawn_id = $spawn_id"
    
    # Default
    array set OPTS {
        timeout        	        "5"
        valgind_log_file       	""
    }
    if {[info exist ${token}(valgind_log_file)]} {
        eval set OPTS(valgind_log_file) $${token}(valgind_log_file)
    }
    foreach option $args {
        if {[regexp {^-([^=]*)=?(.*)} $option -> key value]} {
            switch -exact -- "-$key" {
                "-valgind_log_file"     { set OPTS($key) "$value"}
                "-timeout"              { set OPTS($key) "$value"}
                default                 { set OPTS($key) "$value"}
            }
        }
    }
    
    # Clear valgrind memleak data
    eval set ${token}(valgrind_memleak_definitely_lost) 0
    eval set ${token}(valgrind_memleak_indirectly_lost) 0
    eval set ${token}(valgrind_memleak_possibly_lost)   0
    eval set ${token}(valgrind_memleak_still_reachable) 0
    eval set ${token}(valgrind_memleak_suppressed)      0
    
    
	# cat valgrind.log file
	exp_send "tail -n 30 $OPTS(valgind_log_file)\r"
	expect {
		-timeout $OPTS(timeout)
		-re "LEAK SUMMARY" {
			dbgOut "LEAK SUMMARY"
			exp_continue
		}
		-re "definitely lost: (\[\,0-9]+) bytes in (\[\,0-9]+) blocks" {
			dbgOut "definitely lost $expect_out(1,string) $expect_out(2,string)"
            regsub -all {,} $expect_out(1,string) "" value
			eval set ${token}(valgrind_memleak_definitely_lost) $value
            exp_continue
		}
		-re "indirectly lost: (\[\,0-9]+) bytes in (\[\,0-9]+) blocks" {
			dbgOut "indirectly lost $expect_out(1,string) $expect_out(2,string)"
            regsub -all {,} $expect_out(1,string) "" value
            eval set ${token}(valgrind_memleak_indirectly_lost) $value
			exp_continue
		}
        -re "possibly lost: (\[\,0-9]+) bytes in (\[\,0-9]+) blocks" {
			dbgOut "possibly lost $expect_out(1,string) $expect_out(2,string)"
            regsub -all {,} $expect_out(1,string) "" value
            eval set ${token}(valgrind_memleak_possibly_lost) $value
			exp_continue
		}
        -re "still reachable: (\[\,0-9]+) bytes in (\[\,0-9]+) blocks" {
			dbgOut "still reachable $expect_out(1,string) $expect_out(2,string)"
            regsub -all {,} $expect_out(1,string) "" value
            eval set ${token}(valgrind_memleak_still_reachable) $value
			exp_continue
		}
        -re "suppressed: (\[\,0-9]+) bytes in (\[\,0-9]+) blocks" {
			dbgOut "suppressed $expect_out(1,string) $expect_out(2,string)"
            regsub -all {,} $expect_out(1,string) "" value
            eval set ${token}(valgrind_memleak_suppressed) $value
		}
		timeout {
			
		}
	}
    return -code ok 0
}
