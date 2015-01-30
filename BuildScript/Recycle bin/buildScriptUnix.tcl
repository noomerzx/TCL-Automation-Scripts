lappend auto_path {../../../../AUTOMAT_FRAMEWORK/lib}
package provide Build 1.2
package require common 2.0
package require Expect
catch {package require ZION}

namespace import ::common::*

proc initial { package_name { zion_config "-" }} {
	global rfa_package
	global ZION_UPLOAD
	global testcasePrefix
	global currentPath
	
	#--- Set current path
	set currentPath [pwd]
	
	#--- set packageName like RFACPPXDEV4
	set rfa_package ${package_name}
	if { ${zion_config} != "-" } {
		set ZION_UPLOAD 1
		set testcasePrefix "RFA_01"
		
		if {[catch {::ZION::loadConfig ${zion_config}} errorMsg]} { puts ${errorMsg}}
	}
}
proc firstInform { exampleName platform buildMode } {
	global platformName
	
	#--- Set variables
	if {${buildMode} == "-"} {
		set mode "Release&Debug"
	} else {
		set mode ${buildMode}
	}
	
	#--- Inform start build example
	sendMessage ":::::::::: \[ BUILD EXAMPLE START \] ::::::::::"
	
	#--- Show information depend on platforms
	if {${platformName} == "W"} {
		sendMessage ":::::::::: \[ ------------------- \] ::::::::::"
		sendMessage ":::::::::: \[ - BUILD IN WINDOW - \] ::::::::::"
		sendMessage ":::::::::: \[ ------------------- \] ::::::::::"
		sendMessage "\[INFO\] ::: Info -> Building \"${exampleName}\" In \"${platform}\" Mode \"${mode}\""
	} else {
		sendMessage ":::::::::: \[ ----------------- \] ::::::::::"
		sendMessage ":::::::::: \[ - BUILD IN UNIX - \] ::::::::::"
		sendMessage ":::::::::: \[ ----------------- \] ::::::::::"
		sendMessage "\[INFO\] ::: Info -> Building \"${exampleName}\" In \"${platform}\""
	}
}
proc lastInform {result} {
	sendMessage ":::::::::: \[  BUILD EXAMPLE END  \] ::::::::::"
	sendMessage "---------------------------------------------"
	sendMessage "- ${result} -"
	sendMessage "---------------------------------------------"
}
proc sendMessage { message } {
	global logFile
	
	#--- Send output to terminal and log file
	puts ${message}
	puts ${logFile} ${message}
}
proc prepareVariables { application platform folder } {
	global platformName
	global staticOrShared
	global staticOrSharedFull
	global staticOrSharedNum
	global bit
	global compiler
	global append64bit
	global full
	global rootFolder
	global subFolder
	global exampleName
	global projectFileName
	global awk
	
	#--- Split platforms to variables
	set word [split ${platform} "_"]
	set platformName [string index [lindex ${word} 0] 0]
	set bit [lindex ${word} 1]
	set compiler [lindex ${word} 2]
		
	#--- if in .NET Project word will have 3 items So set static to NO
	if {[llength word]==3} {
		set staticOrShared NO
	} else {
		set staticOrShared [lindex ${word} 3]
	}
	
	#--- split $folder to be list of variables
	if {${platformName} =="W"} {
		regexp {([a-zA-Z0-9\_\-]+)\\?(.*\\)(.*)} ${folder} full rootFolder subFolder exampleName
	} else {
		regexp {([a-zA-Z0-9\_\-]+)/?(.*/)(.*)} ${folder} full rootFolder subFolder exampleName
	}
	if {${folder} == "ValueAdd_01_PackageVerification"} { 
		set rootFolder $folder
		set exampleName $folder
	}
	
	#--- append platformName for 2 charactors except Windows ( Exmple 'S' to 'SS' )
	if {[string equal [string index ${platformName} 0] "S"]} {
		append platformName [string index [lindex ${word} 0] 1]
	}
	
	#--- set awk command for unix
	if { ${platformName} == "SL" } {
		set awk nawk
	} elseif { {$platformName} != "W" } {
		set awk awk
	}
	
	#--- Set compiler
	if { ${platformName} == "W"} {
		set compiler VS${compiler}
	} else {
		if { ${compiler} == "12"} {
			set compiler 1
		} else {
			set compiler 0
		}
	}
	
	#--- Libxml2 contains only static project files
	if {${application} == "Libxml2"} {
		set staticOrShared "ST"
	}
	
	#--- naming argument 
	if { ${staticOrShared} == "SH" } {
		set staticOrSharedFull "Shared"
		set staticOrSharedNum 0
	} elseif { ${staticOrShared} == "ST" } {
		set staticOrSharedFull "Static"
		set staticOrSharedNum 1
	}
	
	#--- naming argument
	if {${bit} == "64"} {
		set append64bit "_x64"
	} else {
		set append64bit ""
	}	
	
	#--- set projectFileName
	set projectFileName ${application}_${compiler}${append64bit}_${staticOrSharedFull}
}
proc preparePerfTools { rootFolder projectFileName } {
	global platformName
	#--- Eet PerfTools environment depend on platform
	if {[string equal [lindex [split ${rootFolder} "_"] 0] "PerfTools"]} {
		#--- Set on WINDOWS
		if { ${platformName} == "W"} {
			set extList [list vcproj vcxproj csproj]
			foreach ext ${extList} {
				#--- check type of project file				
				if {![file exists ${projectFileName}.${ext}]} {
					sendMessage "\[INFO\] ::: ${ext} File is not EXISTS"
					continue
				} 
				
				#--- Handle case 1 : libxml path use wrong directory
				sendMessage "\[INFO\] ::: Send -> sed s/\\\\..\\\\PerfTools\\\\/\\\\/g ${projectFileName}.${ext} > ${projectFileName}_temp.${ext}"
				if {[catch {exec sed s/\\\\..\\\\PerfTools\\\\/\\\\/g ${projectFileName}.${ext} > ${projectFileName}_temp.${ext}} errorMsg ]} {
					sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
				} else {
					sendMessage "\[INFO\] ::: Pass -> Already use correct LibsXML for PerfTools project"
				}
				
				#--- Handle case 2 : libxml path have 2 '\'
				sendMessage "\[INFO\] ::: Send -> sed s/\\\\..\\\\\\\\PerfTools\\\\/\\\\/g ${projectFileName}_temp.${ext} > ${projectFileName}.${ext}"
				if {[catch {exec sed s/\\\\..\\\\\\\\PerfTools\\\\/\\\\/g ${projectFileName}_temp.${ext} > ${projectFileName}.${ext}} errorMsg]} {
					sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
				} else {
					sendMessage "\[INFO\] ::: Pass -> Already use correct LibsXML for PerfTools project"
				}
			}
			
			#--- remove temp files
			sendMessage "\[INFO\] ::: Send -> rm ${projectFileName}_temp*"
			if {[catch {exec rm ${projectFileName}_temp*} errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else {
				sendMessage "\[INFO\] ::: Pass -> Already removed temp files"
			}
		} else {
			#--- Set on UNIX
			#--- Handle case 1 : wrong libsxml path
			sendMessage "\[INFO\] ::: Send -> sed s/\\$\(ROOTPLAT\)\\/PerfTools/../g makefile > makefile_temps"
			if {[catch {exec sed \'s/\\$\(ROOTPLAT\)\\/PerfTools/../g\' makefile > makefile_temps} errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else {
				sendMessage "\[INFO\] ::: Pass -> Already use correct LibsXML for PerfTools project"
			}
			
			#--- Handle case 2 : set LNCMD
			sendMessage "\[INFO\] ::: Send -> sed -e s/\\$\(LNCMD\) rfa/ln -sf rfa/g makefile_temps > makefile_tempz"
			if {[catch {exec sed -e \"s/\\$\(LNCMD\) rfa/ln -sf rfa/g\" makefile_temps > makefile_tempz} errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else {
			sendMessage "\[INFO\] ::: Pass -> Already set LNCMD in makefile"
			}
			
			#-- replace to makefile
			sendMessage "\[INFO\] ::: Send -> cp makefile_tempz makefile"
			if {[catch {exec cp makefile_tempz makefile} errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else {
				sendMessage "\[INFO\] ::: Pass -> Already use correct LibsXML for PerfTools project"
			}
			
			#--- remove all temp file
			sendMessage "\[INFO\] ::: Send -> rm -rf makefile_t.*"
			if {[catch {exec rm -rf makefile_t.*} errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else {
				sendMessage "\[INFO\] ::: Pass -> Already removed temp file"
			}
		}
	}
}
proc prepareConfig {outputFolderName rootFolder} {
	global platformName
	global staticOrSharedNum
	
	if { ${platformName} =="W"} {
		#--- copy all require file in output directory
		sendMessage "\[INFO\] ::: Send -> cd ${outputFolderName}"
		if {[catch {cd ${outputFolderName}} errorMsg]} {
			sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
		} else {
			sendMessage "\[INFO\] ::: Pass -> Coming in output directory" 
			#--- copy all required config to output folder
			sendMessage "\[INFO\] ::: Send -> cp -f ..\\..\\..\\*.cfg \." 
			if {[catch {exec cp -f ..\\..\\..\\*.cfg \.} errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already copy config file"}
			sendMessage "\[INFO\] ::: Send -> cp -f ..\\..\\*.cfg \." 
			if {[catch {exec cp -f ..\\..\\*.cfg \.} errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already copy config file"}
			sendMessage "\[INFO\] ::: Send -> cp -f ..\\*.cfg \." 
			if {[catch {exec cp -f ..\\*.cfg \.} errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already copy config file"}
			sendMessage "\[INFO\] ::: Send -> cp -f ..\\..\\..\\etc\\RDM\\* \." 
			if {[catch {exec cp -f ..\\..\\..\\etc\\RDM\\* \.} errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already copy file in RDM"}
			sendMessage "\[INFO\] ::: Send -> cp -f ..\\..\\..\\etc\\Marketfeed\\* \." 
			if {[catch {exec cp -f ..\\..\\..\\etc\\Marketfeed\\* \.} errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {	sendMessage "\[INFO\] ::: Pass -> Already copy file in Marketfeed"}
			
			#--- copy all required xml files for Perf Tools to output folder
			if {[string equal [lindex [split ${rootFolder} "_"] 0] "PerfTools"]} {
				sendMessage "\[INFO\] ::: Send -> cp -f ..\\..\\*.xml \." 
				if {[catch {exec cp -f ..\\..\\*.xml \.} errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already copy xml file"}
			}
			
			#--- remove unused files (*.sbr, *.obj, *.pdb, *.bsc)	
			sendMessage "\[INFO\] ::: Send -> rm -rf *.sbr" 
			if {[catch {exec rm -rf *.sbr } errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already remove .sbr file"}
			sendMessage "\[INFO\] ::: Send -> rm -rf *.obj"                                                                             
			if {[catch {exec rm -rf *.obj } errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already remove .obj file"}
			sendMessage "\[INFO\] ::: Send -> rm -rf *.pdb"                                                                              
			if {[catch {exec rm -rf *.pdb } errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already remove .pdb file"}
			sendMessage "\[INFO\] ::: Send -> rm -rf *.bsc"                                                                            
			if {[catch {exec rm -rf *.bsc } errorMsg]} {sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"} else {sendMessage "\[INFO\] ::: Pass -> Already remove .bsc file"}
		}
	} else {
		sendMessage "\[INFO\] ::: Send -> cd $outputFolderName"
		if {[catch {cd ${outputFolderName}}]} {
			sendMessage "\[WARN\] ::: Warn -> Can't Entered in output directory"
		} else {
			sendMessage "\[INFO\] ::: Pass -> Coming in output directory"
			#--- copy xml for perftools
			if {[string equal [lindex [split ${rootFolder} "_"] 0] "PerfTools"]} {
				sendMessage "\[INFO\] ::: Send -> cp -f ..\\..\\*.xml \."
				if {[catch {exec cp -f ..\/..\/\*.xml \.} errorMsg]} { sendMessage "\[WARN\] ::: Warn -> ${errorMsg}" } else { sendMessage "\[INFO\] ::: Pass -> Already copy xml file" }
			}
			#--- move static output folder to specific path
			if { ${staticOrSharedNum}==1 } {
				sendMessage "\[INFO\] ::: Send -> cp -rf .\/Static\/\* ."
				if {[catch {exec cp -rf .\/Static\/\* .} errorMsg]} { sendMessage "\[WARN\] ::: Warn -> ${errorMsg}" } else { sendMessage "\[INFO\] ::: Pass -> Already copy static folder to specific" }
				sendMessage "\[INFO\] ::: Send -> rm -rf Static"
				if {[catch {exec rm -rf Static} errorMsg]} { sendMessage "\[WARN\] ::: Warn -> ${errorMsg}" } else { sendMessage "\[INFO\] ::: Pass -> Already remove old file" }
			}
		}
	}
}
proc updateZION { exampleName platform result} {
	# ZION feature
	global ZION_UPLOAD
	global testcasePrefix
	set testcase ${testcasePrefix}_${exampleName}
	if { ${ZION_UPLOAD} } {
		sendMessage ":::::::::: \[   - ZION UPDATE -   \] ::::::::::"
		sendMessage ":::::::::::::::::::::::::::::::::::::::::::::"
		if { ${platform} == ""} {
			sendMessage "\[FAIL\] ::: Fail -> No platform for update ZION"
		} else {
			if {[catch {set zionResult [::ZION::setTestPlatform ${platform}]} errorMsg]} {
				sendMessage "\[ZION\] ::: Warn -> ${errorMsg}"
			}
			if {[catch {set zionResult [::ZION::updateTestResult ${testcase} ${result}]} errorMsg]} {
				sendMessage "\[ZION\] ::: Warn -> ${errorMsg}"
			} else { 
				if { ${result}=="PASS-A" } {
					sendMessage "\[ZION\] ::: Info -> Zion Updated Result ${exampleName} as PASS"
				} else {
					sendMessage "\[ZION\] ::: Info -> Zion Updated result ${exampleName} as FAIL"
				}
			}
			
		}
		sendMessage ":::::::::::::::::::::::::::::::::::::::::::::"
		sendMessage ":::::::::: \[   - ZION FINISH -   \] ::::::::::"
		sendMessage ":::::::::: \[   ---------------   \] ::::::::::"
	}
}
proc setEnvironmentPath {} {
	global env
	global bit
	global compiler
	global paths
	global orgEnvPath
	
	# Keep Original Environment Path before using the new one
	set orgEnvPath $env(PATH)
	set paths ""
	
	#--- set Environment Path on Window
	if { ${bit} == 32 } {
		if { ${compiler} == "VS71" } {
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\Common7\\IDE;"
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\VC\\BIN;"
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\Common7\\Tools;"
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\Common7\\Tools\\bin;"
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\VC\\PlatformSDK\\bin;"
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\SDK\\v2.0\\bin;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727;"
			append paths "C:\\Program Files\\Microsoft Visual Studio .NET 2003\\VC\\VCPackages\r"
		} elseif { ${compiler} == "VS80" } {
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\Common7\\IDE;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\VC\\BIN;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\Common7\\Tools;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\Common7\\Tools\\bin;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\VC\\PlatformSDK\\bin;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\SDK\\v2.0\\bin;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 8\\VC\\VCPackages\r"
		} elseif { ${compiler} == "VS90" } {
			append paths "C:\\Program Files\\Microsoft Visual Studio 9.0\\Common7\\IDE;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 9.0\\VC\\BIN;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 9.0\\Common7\\Tools;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v3.5;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 9.0\\VC\\VCPackages;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\r"
		} elseif { ${compiler} == "VS100" } {
			append paths "C:\\Program Files\\Microsoft Visual Studio 10.0\\Common7\\IDE;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 10.0\\VC\\BIN;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 10.0\\Common7\\Tools;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v3.5;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v4.0.30319;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 10.0\\VC\\VCPackages;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\r"
		} elseif { ${compiler} == "VS110" } {
			append paths "C:\\Program Files\\Microsoft Visual Studio 11.0\\Common7\\IDE;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 11.0\\VC\\BIN;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 11.0\\Common7\\Tools;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v3.5;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v4.0.30319;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727;"
			append paths "C:\\Program Files\\Microsoft Visual Studio 11.0\\VC\\VCPackages;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\r"
		}
	} elseif { ${bit} == 64 } {
		if { ${compiler} == "VS80" } {
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\VC\\BIN\\amd64;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\VC\\PlatformSDK\\bin\\win64\\amd64;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\VC\\PlatformSDK\\bin;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v2.0.50727;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\VC\\VCPackages;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\Common7\\IDE;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\Common7\\Tools;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\Common7\\Tools\\bin;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 8\\SDK\\v2.0\\bin\r"
		} elseif { ${compiler} == "VS90" } {
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 9.0\\VC\\BIN\\amd64;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v3.5;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v3.5\\Microsoft .NET Framework 3.5 \(Pre-Release Version\);"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v2.0.50727;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 9.0\\VC\\VCPackages;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 9.0\\Common7\\IDE;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 9.0\\Common7\\Tools;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 9.0\\Common7\\Tools\\bin;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\\x64;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\\win64\\x64;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\r"
		} elseif { ${compiler} == "VS100" } {
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 10.0\\VC\\BIN\\amd64;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v3.5;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v3.5\\Microsoft .NET Framework 3.5 \(Pre-Release Version\);"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v2.0.50727;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 10.0\\VC\\VCPackages;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 10.0\\Common7\\IDE;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 10.0\\Common7\\Tools;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 10.0\\Common7\\Tools\\bin;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\\x64;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\\win64\\x64;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\r"
		} elseif { ${compiler} == "VS110" } {
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 11.0\\VC\\BIN\\amd64;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v3.5;"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v3.5\\Microsoft .NET Framework 3.5 \(Pre-Release Version\);"
			append paths "C:\\WINDOWS\\Microsoft.NET\\Framework64\\v2.0.50727;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 11.0\\VC\\VCPackages;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 11.0\\Common7\\IDE;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 11.0\\Common7\\Tools;"
			append paths "C:\\Program Files \(x86\)\\Microsoft Visual Studio 11.0\\Common7\\Tools\\bin;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\\x64;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\\win64\\x64;"
			append paths "C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A\\bin\r"
		}
	}
	set env(PATH) "${paths};${orgEnvPath}"
}
proc setOutputFolderName {platform projectFileName { fileType "-" } { buildMode "" }} {
	global outputFolderName
	global platformName
	global staticOrSharedFull
	global compiler
	global bit
	global awk
	
	#--- Set output Folder name
	set outputFolderName ""
	if {${platform} == "-"} {
		if {${staticOrShared} == "NO" } {
			if {${buildMode} == "Release"} {
				set outputFolderName "Release_WIN_${bit}_${compiler}"
			} else {
				set outputFolderName "Debug_WIN_${bit}_${compiler}"
			}
		} else {
			if {${buildMode} == "Release"} {
				set outputFolderName "Release_WIN_${bit}_${compiler}_${staticOrSharedFull}"
			} else {
				set outputFolderName "Debug_WIN_${bit}_${compiler}_${staticOrSharedFull}"
			}
		}
	} else {
		set outputFolderName "${platform}"
	}

	#--- remove all old output directory
	sendMessage "\[INFO\] ::: Send -> rm -rf ${outputFolderName}"
	if {[catch {exec rm -rf ${outputFolderName}} errorMsg] } {
		sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Already removed old output directory"
	}
	
	#--- rename output folder name depend on platform and file type
	if { ${platformName} == "W"} {
		#--- Set in WINDOW
		if { ${fileType} == "sln" } {
			#--- Remove old target file for build
			sendMessage "\[INFO\] ::: Send -> rm -rf ${platform}.sln"
			if {[catch [exec rm -rf ${platform}.sln] errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else { sendMessage "\[INFO\] ::: Pass -> Already remove old target file for build" }
			
			#--- set destination file type
			if {${compiler} == "VS90"} {
				set type vcproj
			} else {
				set type vcxproj
			}
			
			#--- copy solution file to target file for rename all output folder
			sendMessage "\[INFO\] ::: Send -> cp -rf ${projectFileName}.sln target.txt"
			if {[catch {exec cp -rf ${projectFileName}.sln target.txt} errorMsg]} {
				sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
				sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
				sendMessage "\[FAIL\] ::: Fail -> Exit"
				return "FAIL"
			} else { sendMessage "\[INFO\] ::: Pass -> Already copy target for build file" }

			#--- get old output folder name in target file
			sendMessage "\[INFO\] ::: Send -> cat target.txt | grep \[a-zA-Z0-9_\\.\]*.${type}"
			if {[catch {set target [exec cat target.txt | grep \[a-zA-Z0-9_\\.\]*.${type}]} errorMsg]} {
				sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
				sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
				sendMessage "\[FAIL\] ::: Fail -> Exit"
				return "FAIL"
			} else { sendMessage "\[INFO\] ::: Pass -> Already cat file for get old output folder" }
			
			#--- rename output folder in soultion file and project destination file
			set projects [split $target "\n"]
			set number 1
			foreach project $projects {
				# regexp {[a-zA-Z0-9_\\.]*.${type}} $project oldOutput
				
				#--- regular for get full path of old project destination file
				set regOldFull \[a-zA-Z0-9_\\\\.\]\*.${type}
				regexp ${regOldFull} ${project} oldOutput
				
				#--- regular for get appname and change name with regsup to be target project file for build
				set regAppName \[a-zA-Z0-9_\]\*.${type}
				regexp ${regAppName} ${oldOutput} appName
				regsub -all ${appName} ${oldOutput} "${platform}_${number}.${type}" newOutput
				lappend appList ${appName}
				lappend projectList ${platform}_${number}
				
				#--- regular get root path
				set regRoot \\\\\[a-zA-Z0-9_\]\*.${type}
				regsub -all ${regRoot} ${oldOutput} {} rootPath
				
				#--- prepare for sed command
				regsub -all {\\} $oldOutput {\\\\} oldOutput
				regsub -all {\\} $newOutput {\\\\} newOutput
				
				#--- change project destination file in target solution file to temp file
				sendMessage "\[INFO\] ::: Send -> sed s/$oldOutput/$newOutput/g target.txt > ${platform}.sln"
				if {[catch {exec sed s/${oldOutput}/${newOutput}/g target.txt > ${platform}.sln} errorMsg]} {
					sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
					sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
					sendMessage "\[FAIL\] ::: Fail -> Exit"
					return "FAIL"
				} else { sendMessage "\[INFO\] ::: Pass -> Already change project destination in temp target solution file" }
				
				#--- update target file
				sendMessage "\[INFO\] ::: Send -> cp -rf ${platform}.sln target.txt"
				if {[catch {exec cp -rf ${platform}.sln target.txt} errorMsg]} {
					sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
					sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
					sendMessage "\[FAIL\] ::: Fail -> Exit"
					return "FAIL"
				} else { sendMessage "\[INFO\] ::: Pass -> Already move temp solution file to target solution file" }

				#--- remove target destination old project file
				sendMessage "\[INFO\] ::: Send -> rm -rf $rootPath\\${platform}_${number}.${type}"
				if {[catch {exec rm -rf $rootPath\\${platform}_${number}.${type}} errorMsg]} {
					sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
					sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
					sendMessage "\[FAIL\] ::: Fail -> Exit"
					return "FAIL"
				} else { sendMessage "\[INFO\] ::: Pass -> Already remove old build target file"}
				
				#--- Rename output folder depend on build mode in destination project file and move to target project file for build
				# if {$buildMode == "Release" || $buildMode == "-"} {
					# sendMessage "\[INFO\] ::: Send -> sed s/\[Rr\]\[Ee\]\[Ll\]\[Ee\]\[Aa\]\[Ss\]\[Ee\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > $rootPath\\${platform}_${number}.${type}"
					# if {[catch {exec sed s/\[Rr\]\[Ee\]\[Ll\]\[Ee\]\[Aa\]\[Ss\]\[Ee\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > $rootPath\\${platform}_${number}.${type}} errorMsg]} {
						# sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
						# sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
						# sendMessage "\[FAIL\] ::: Fail -> Exit"
						# return "FAIL"
					# } else { sendMessage "\[INFO\] ::: Pass -> Already rename output folder in project destination file"}
				# }
				# if {$buildMode == "Debug" || $buildMode == "-"} {
					# sendMessage "\[INFO\] ::: Send -> sed s/\[De\]\[Ee\]\[Bb\]\[Uu\]\[Gg\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > $rootPath\\${platform}_${number}.${type}"
					# if {[catch {exec sed s/\[De\]\[Ee\]\[Bb\]\[Uu\]\[Gg\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > $rootPath\\${platform}_${number}.${type}} errorMsg]} {
						# sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
						# sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
						# sendMessage "\[FAIL\] ::: Fail -> Exit"
						# return "FAIL"
					# } else { sendMessage "\[INFO\] ::: Pass -> Already rename output folder in project destination file"}
				# }
				
				if {$buildMode == "Release" || $buildMode == "-"} {
					sendMessage "\[INFO\] ::: Send -> sed s/\[Rr\]\[Ee\]\[Ll\]\[Ee\]\[Aa\]\[Ss\]\[Ee\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > ${rootPath}\\${platform}_${number}.${type}"
					if {[catch {exec sed s/\[Rr\]\[Ee\]\[Ll\]\[Ee\]\[Aa\]\[Ss\]\[Ee\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > ${rootPath}\\${platform}_${number}.${type}} errorMsg]} {
						sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
						sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
						sendMessage "\[FAIL\] ::: Fail -> Exit"
						return "FAIL"
					} else { sendMessage "\[INFO\] ::: Pass -> Already rename output folder in project destination file and move to temp file"}
				}
				if {$buildMode == "Debug" || $buildMode == "-"} {
					sendMessage "\[INFO\] ::: Send -> sed s/\[De\]\[Ee\]\[Bb\]\[Uu\]\[Gg\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > ${rootPath}\\${platform}_${number}.${type}"
					if {[catch {exec sed s/\[De\]\[Ee\]\[Bb\]\[Uu\]\[Gg\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${oldOutput} > ${rootPath}\\${platform}_${number}.${type}} errorMsg]} {
						sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
						sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
						sendMessage "\[FAIL\] ::: Fail -> Exit"
						return "FAIL"
					} else { sendMessage "\[INFO\] ::: Pass -> Already rename output folder in project destination file for build"}
				}
				if { (${number} > 1) && ${compiler} != "VS90" } {
					foreach app ${appList} {
						set pos 0
						sendMessage "\[INFO\] ::: Send -> sed s/${app}/[lindex ${projectList} ${pos}]/g ${rootPath}\\${platform}_${number}.${type} > $rootPath\\target.txt"
						if {[catch {exec sed s/${app}/[lindex ${projectList} ${pos}]/g ${rootPath}\\${platform}_${number}.${type} > $rootPath\\target.txt} errorMsg]} {
							sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
							sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
							sendMessage "\[FAIL\] ::: Fail -> Exit"
							return "FAIL"
						} else { sendMessage "\[INFO\] ::: Pass -> Already set destination projecfile to temp file"}
						
						sendMessage "\[INFO\] ::: Send -> cp -rf ${rootPath}\\target.txt ${rootPath}\\${platform}_${number}.${type}"
						if {[catch {exec cp -rf ${rootPath}\\target.txt ${rootPath}\\${platform}_${number}.${type}} errorMsg]} {
							sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
							sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
							sendMessage "\[FAIL\] ::: Fail -> Exit"
							return "FAIL"
						} else { sendMessage "\[INFO\] ::: Pass -> Already update destination project file for build" }
						incr pos
					}
				}
				sendMessage "\[INFO\] ::: Send -> rm -rf ${rootPath}\\target.txt"
				if {[catch {exec rm -rf ${rootPath}\\target.txt} errorMsg]} {
					sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
					sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
					sendMessage "\[FAIL\] ::: Fail -> Exit"
					return "FAIL"
				} else { sendMessage "\[INFO\] ::: Pass -> Already remove temp file" }
				incr number
			}
			#--- remove target file
			sendMessage "\[INFO\] ::: Send -> rm -rf target.txt"
			if {[catch {exec rm -rf target.txt} errorMsg]} {
				sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
				sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
				sendMessage "\[FAIL\] ::: Fail -> Exit"
				return "FAIL"
			} else { sendMessage "\[INFO\] ::: Pass -> Already remove temp solution file" }
		} else {
			#--- Remove old target file for build
			sendMessage "\[INFO\] ::: Send -> rm -rf ${outputFolderName}.${fileType}"
			if {[catch [exec rm -rf ${outputFolderName}.${fileType}] errorMsg]} {
				sendMessage "\[WARN\] ::: Warn -> ${errorMsg}"
			} else { sendMessage "\[INFO\] ::: Pass -> Already remove old target file for build"}
			
			#--- Rename output folder depend on build mode
			if {$buildMode == "Release" || $buildMode == "-"} {
				sendMessage "\[INFO\] ::: Send -> sed s/\[Rr\]\[Ee\]\[Ll\]\[Ee\]\[Aa\]\[Ss\]\[Ee\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${projectFileName}.${fileType} > ${platform}.${fileType}"
				if {[catch {exec sed s/\[Rr\]\[Ee\]\[Ll\]\[Ee\]\[Aa\]\[Ss\]\[Ee\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${projectFileName}.${fileType} > ${platform}.${fileType}} errorMsg ]} {
					sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
					sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
					sendMessage "\[FAIL\] ::: Fail -> Exit"
					return "FAIL"
				} else {
					sendMessage "\[INFO\] ::: Pass -> Already rename output folder."
				}
			}
			if {$buildMode == "Debug" || $buildMode == "-"} {
				sendMessage "\[INFO\] ::: Send -> sed s/\[De\]\[Ee\]\[Bb\]\[Uu\]\[Gg\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${projectFileName}.${fileType} > ${platform}.${fileType}"
				if {[catch {exec sed s/\[De\]\[Ee\]\[Bb\]\[Uu\]\[Gg\]_\[Ww\]\[Ii\]\[Nn\]_\[a-zA-Z0-9_\]*/${outputFolderName}/g ${projectFileName}.${fileType} > ${platform}.${fileType}} errorMsg ]} {
					sendMessage "\[FAIL\] ::: Fail -> ${errorMsg}"
					sendMessage "\[FAIL\] ::: Fail -> Build Failed at setOutputFolderName procedure" 
					sendMessage "\[FAIL\] ::: Fail -> Exit"
					return "FAIL"
				} else {
					sendMessage "\[INFO\] ::: Pass -> Already rename output folder."
				}
			}
		}
	} else {
		#--- Set in UNIX
		if { ${outputFolderName} != "-" } {
			sendMessage "\[INFO\] ::: Send -> sed s/^\[\ \\t\ \]*OUTPUT_DIR\[\ \\t\ \]*=\[\ \\t\ \]*.*/OUTPUT_DIR=${platform}/g makefile_temp3 > makefile_target"
			if {[catch {exec sed s/^\[\ \t\ \]*OUTPUT_DIR\[\ \t\ \]*=\[\ \t\ \]*.*/OUTPUT_DIR=${platform}/g makefile_temp3 > makefile_target } errorMsg ] } { 
				sendMessage "\[WARN\] ::: Warn -> $errorMsg"
				sendMessage "\[WARN\] ::: Warn -> Can't named output folder name in makefile"
			} else {
				sendMessage "\[INFO\] ::: Pass -> Already named output folder name in makefile"
			}
		} else {
			sendMessage "\[INFO\] ::: Send -> cp makefile_temp3 makefile_target\r "
			if {[catch {exec cp makefile_temp3 makefile_target } errorMsg ] } {
				sendMessage "\[WARN\] ::: Warn -> $errorMsg"
				sendMessage "\[WARN\] ::: Warn -> Can't named output folder name in makefile"
			} else {
				sendMessage "\[INFO\] ::: Pass -> Already named output folder name in makefile"
			}
		}
	}
}
proc buildInWindow { folder application platform fileType buildMode} {
	global rootFolder
	global projectFileName
	global staticOrShared
	global staticOrSharedFull
	global outputFolderName
	global bit
	global compiler
	global paths
	global rfa_package
	
	#--- Go to target directory
	sendMessage "\[INFO\] ::: Send -> cd ${rfa_package}\\${folder}"
	if {[catch {cd ${rfa_package}\\${folder}} errorMsg]} {
		sendMessage "\[FAIL\] ::: Fail -> $errorMsg"
		sendMessage "\[FAIL\] ::: Fail -> Exit"
		return "FAIL"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Coming in target directory"
	}
	
	#--- Prepare specific environment in PerfTools for build
	preparePerfTools ${rootFolder} ${projectFileName}
	
	#--- Set Output Folder Name
	setOutputFolderName ${platform} ${projectFileName} ${fileType} ${buildMode}
	
	after 2000
	
	#--- Build
	if { ${staticOrShared} == "NO" || ${staticOrShared} == "SH" } {
		sendMessage "\[INFO\] ::: Send -> devenv ${platform}.${fileType} /rebuild ${buildMode}"
		if {[catch {set result [exec devenv ${platform}.${fileType} /rebuild ${buildMode} ]} errorMsg]} {
			set result $errorMsg
		}		
	} else {
		sendMessage "\[INFO\] ::: Send -> devenv ${platform}.${fileType} /rebuild ${buildMode}\-static"
		if {[catch {set result [exec devenv ${platform}.${fileType} /rebuild ${buildMode}\-static ]} errorMsg]} {
			set result $errorMsg
		}	
	}
		
	#--- Send build result to terminal,log file
	sendMessage $result
	if {[regexp {([1-9] succeeded, 0 failed, (0 up-to-date, )?0 skipped)|(1 up-to-date)} ${result} ]} {
		sendMessage "\[INFO\] ::: Pass -> Build Finished"
	} else {
		sendMessage "\[FAIL\] ::: Fail -> Build Failed"
		sendMessage "\[FAIL\] ::: Fail -> Exit"
		return "FAIL"
	}
	
	#--- Clear Target file for build
	sendMessage "\[INFO\] ::: Send -> rm ${platform}.*"
	if {[catch {exec rm ${platform}.*} errorMsg]} {
		sendMessage "\[WARN\] ::: Warn -> ${errorMsg} Please Delete Old File"
	} else { sendMessage "\[INFO\] ::: Pass -> Already remove target file for build" }
		
	#--- Prepare all config to output folder
	prepareConfig ${outputFolderName} ${rootFolder}
		
	return "PASS"
}
proc buildInUnix { folder application platform } {
	global rfa_package
	global rootFolder
	global projectFileName
	global bit 
	global staticOrSharedNum
	global compiler
	global outputFolderName
	global awk
	
	#--- Go to target directory
	sendMessage "\[INFO\] ::: Send -> cd ${rfa_package}\/${folder}"
	if {[catch {cd ${rfa_package}\/${folder}} errorMsg]} {
		sendMessage "\[FAIL\] ::: Fail -> $errorMsg"
		sendMessage "\[FAIL\] ::: Fail -> Exit"
		return "FAIL"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Coming in target directory"
	}
	
	#--- Prepare specific environment in PerfTools for build
	preparePerfTools ${rootFolder} ${projectFileName}
	
	#--- Prepare makefiles for build
	#- set bit
	sendMessage "\[INFO\] ::: Send -> sed s/^\[\ \\t\ \]*COMPILE_BITS\[\ \\t\ \]*=\[\ \\t\ \]*.*/COMPILE_BITS=${bit}/g makefile > makefile_temp"
	if {[catch {exec sed s/^\[\ \t\ \]*COMPILE_BITS\[\ \t\ \]*=\[\ \t\ \]*.*/COMPILE_BITS=${bit}/g makefile > makefile_temp } errorMsg ] } { 
	
		sendMessage "\[WARN\] ::: Warn -> $errorMsg"
		sendMessage "\[WARN\] ::: Warn -> Can't setting bit in makefile"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Already set bit in makefile"
	}
	
	#- set static or share
	sendMessage "\[INFO\] ::: Send -> sed s/^\[\ \\t\ \]*USE_STATIC\[\ \\t\ \]*=\[\ \\t\ \]*.*/USE_STATIC=${staticOrSharedNum}/g  makefile_temp > makefile_temp1"
	if {[catch {exec sed s/^\[\ \t\ \]*USE_STATIC\[\ \t\ \]*=\[\ \t\ \]*.*/USE_STATIC=${staticOrSharedNum}/g makefile_temp > makefile_temp1 } errorMsg ] } { 
		sendMessage "\[WARN\] ::: Warn -> $errorMsg"
		sendMessage "\[WARN\] ::: Warn -> Can't setting static or share in makefile"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Already set static or share in makefile"
	}
		
	#- set compiler
	sendMessage "\[INFO\] ::: Send -> sed s/^\[\ \\t\ \]*USE_SS12\[\ \\t\ \]*=\[\ \\t\ \]*.*/USE_SS12=${compiler}/g makefile_temp1 > makefile_temp2"
	if {[catch {exec sed s/^\[\ \t\ \]*USE_SS12\[\ \t\ \]*=\[\ \t\ \]*.*/USE_SS12=${compiler}/g makefile_temp1 > makefile_temp2 } errorMsg ] } { 
		sendMessage "\[WARN\] ::: Warn -> $errorMsg"
		sendMessage "\[WARN\] ::: Warn -> Can't setting compiler(SS11 or SS12) in makefile"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Already set compiler(SS11 or SS12) in makefile"
	}
	
	#- set LN_HOMEPATH
	sendMessage "\[INFO\] ::: Send -> sed s/^\[\ \\t\ \]*LN_HOMEPATH\[\ \\t\ \]*=\[\ \\t\ \]*.*/LN_HOMEPATH=./g makefile_temp2 > makefile_temp3"
	if {[catch {exec sed s/^\[\ \t\ \]*LN_HOMEPATH\[\ \t\ \]*=\[\ \t\ \]*.*/LN_HOMEPATH=./g makefile_temp2 > makefile_temp3 } errorMsg ] } { 
		sendMessage "\[WARN\] ::: Warn -> $errorMsg"
		sendMessage "\[WARN\] ::: Warn -> Can't setting LN_HOMEPATH in makefile"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Already set LN_HOMEPATH in makefile"
	}
	
	#- set output folder name
	setOutputFolderName ${platform} ${projectFileName}
	
	#--- Build 
	sendMessage "\[INFO\] ::: Send -> gmake -f makefile_target"
	if {[catch {set result [exec gmake -f makefile_target] } errorMsg ] } {
		set result $errorMsg
	}
	
	#--- Send build result to terminal,log file
	sendMessage $result
	if {[regexp {([Ee][Rr][Rr][Oo][Rr])|([Ss][Tt][Oo][Pp])} $result ]} {
		sendMessage "\[FAIL\] ::: Fail -> Build Failed on $application $bit $compiler" 
		sendMessage "\[FAIL\] ::: Fail -> Exit"
		return "FAIL"
	} elseif {[regexp {([Ww][Aa][Rr][Nn][Ii][Nn][Gg])} $result ]} {
		sendMessage "\[WARN\] ::: Warn -> Build may be Incomplete please check logfile"
	} else {
		sendMessage "\[INFO\] ::: Pass -> Build Finished"
	}
	
	#--- Prepare all config to output folder
	if {${staticOrSharedNum}==1 || [string equal [lindex [split ${rootFolder} "_"] 0] "PerfTools"]} {
		prepareConfig ${outputFolderName} ${rootFolder}
	}
	
	return "PASS"
}
proc buildExample { folder application { platform "-" } { fileType "-" } { buildMode "-" }  } {
	global env
	global orgEnvPath
	global platformName
	global staticOrShared
	global staticOrSharedFull
	global staticOrSharedNum
	global bit
	global compiler
	global append64bit
	global rfa_package
	global full
	global rootFolder
	global subFolder
	global exampleName
	global logFile
	global outputFolderName
	global awk
	global currentPath
	set buildResultRelease ""
	set buildResultDebug ""
	set buildResultUnix ""
	
	#--- Prepare All Variable
	prepareVariables ${application} ${platform} ${folder}
	
	#--- Prepare Log Folder
	if {![catch {cd ${currentPath}} errorMsg]} {
		if {![file isdirectory ${currentPath}/logApp/${full}]} {file mkdir [pwd]/logApp/${full}}
		if { $buildMode == "-" } {
			set logFile [ open "${currentPath}/logApp/${full}/${platform}_Release_Debug.log" w ]
		} else {
			set logFile [ open "${currentPath}/logApp/${full}/${platform}_${buildMode}.log" w ]
		}
	} 

	#--- Inform build details
	firstInform ${exampleName} ${platform} ${buildMode}
		
	#--- Build Example depend on platform
	if { ${platformName} == "W"} {
		#--- Set Environment Path
		sendMessage "\[INFO\] ::: Send -> SET ENVIRONMENT PATH..."
		if {![catch {setEnvironmentPath}]} {
			sendMessage "\[INFO\] ::: Pass -> PATH = $env(PATH)"
		} 

		#--- call build in windows depend on build mode
		if {${buildMode} == "-" || ${buildMode} == "Release"} {
			set buildResultRelease [buildInWindow ${folder} ${application} ${platform} ${fileType} "Release" ]
		} 
		if {(${buildMode} == "-" && ${buildResultRelease} == "PASS" ) || (${buildMode} == "Debug")} {
			if {${buildResultRelease} == "PASS"} {
				sendMessage "---------------------- NEXT ROUND -----------------------"
			}
			set buildResultDebug [buildInWindow ${folder} ${application} ${platform} ${fileType} "Debug" ]	
		}
		
	} else {
		#--- call build in unix
		set buildResultUnix [ buildInUnix ${folder} ${application} ${platform} ]
	}
	
	#--- Inform end build process
	sendMessage ":::::::::: \[  - BUILD  FINISH -  \] ::::::::::"
	sendMessage ":::::::::: \[  -----------------  \] ::::::::::"

	#--- Check result and update to ZION
	set buildExampleResult ""
	if {[regexp {01_PackageVerification} ${rootFolder}]} {
		if {( ${buildResultRelease} == "PASS" && ${buildResultDebug} == "PASS") || ${buildResultUnix} == "PASS"  } {
			set buildExampleResult "PASS-A"
		} else {
			set buildExampleResult "FAIL"
		}
		updateZION ${exampleName} ${platform} ${buildExampleResult}
	} else {
		if {${platformName} == "W" && ${buildMode} == "-" && ${buildResultDebug} != "PASS"} {
			set buildExampleResult "FAIL"
		} elseif {${buildResultRelease} == "PASS" || ${buildResultDebug} == "PASS" || ${buildResultUnix} == "PASS"  } {
			set buildExampleResult "PASS-A"
		} else {
			set buildExampleResult "FAIL"
		} 
	}
	set reportResult "${buildExampleResult} ${exampleName} IN ${platform}"
	
	#--- Clear environment path (set to original)
	if { ${platformName} == "W"} {
		set env(PATH) ${orgEnvPath}
	}
	
	#--- Inform build result
	lastInform ${reportResult}
	
	#--- close file and return result to logResult
	close ${logFile}
	return ${reportResult}
}


#############################################################################################################
#																			  								#
##########                                 PROCEDURES  DESCRIPTION                                 ##########
#																			  								#
#############################################################################################################
#																			  								#
### initial 			:: inital zion config / keep current path / set package path						#
#																			  								#
### firstInform 		:: information before begin build process											#
#																			  								#
### lastInform 			:: build result information															#
#																			  								#
### sendMessage 		:: send result of each process to terminal and log file       						#
#																			  								#
### prepareVariable 	:: set all variable that this script need to use									#
#																			  								#
### preparePerfTools 	:: work around about PerfTools Section (set anything in file before build process)	#
#																			  								#
### prepareConfig 		:: copy all needed config to output folder and remove all not nessesary files		#
#																			  								#
### updateZION			:: update result to ZION															#
#																			  								#
### setEnvironmentPath	:: set environment path for window													#
#																											#
### setOutputFolderName	:: set the name of output folder depend on platform or build mode					#																																					#	
#																											#
### buildInWindow		:: process build in window															#
#																											#
### buildInUnix			:: process build in unix															#
#																											#
### buildExample		:: main procedure (call here for build example)										#
#																											#
#############################################################################################################
##########                                      EXAMPLE BELOW                                      ##########
#############################################################################################################
#																											#
# --- Test on window platform																				#
# initial C:\\RFACPP_AT\\TOOLS\\RFACPP760XDEV3 "config-zion.txt"											#
# buildExample Examples_01_PackageVerification\\HybridApp HybridApp W7P_64_100_SH vcxproj  					#
#																											#
#--- Test on unix platform																					#
#initial /export/home/administrator/Packages/RFACPP/RFACPP760_RRG_Ben "../config-zion.txt"			
#buildExample Examples_Ben/StarterConsumer_BatchView StarterConsumer_BatchView RH6L_32_444_SH
#																											#
#############################################################################################################	




