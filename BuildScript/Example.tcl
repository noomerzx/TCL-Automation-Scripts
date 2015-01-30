#######################################################################################################################################
#--- Build Structure Descripttion
#---
#--- fullpath-packagename(XDEV) : full path of package
#--- Zion Config : zion config name
#--- applicationfullpath : fullpath of application you need to build
#--- application : name of application
#--- platform : name of platform at reuters standard format (example W8P_64_100_ST)
#--- filetype : filetype of application that need to build ( only for windows )( example vcproj vcxproj csproj sln )
#--- buildMode : release for debug ( only for windows )
#---
#######################################################################################################################################
#--- Structure for build in " WINDOW "
#--- Description : in window can blank only buildMode it's will build both release and debug
#---
#--- Examples
#--- initial (fullpath-packagename(XDEV)) (Zion Config)
#--- buildExample  (applicationfullpath) (application) (platform) (filetype(optional)) (buildMode(optional)) 
#---
#######################################################################################################################################
#--- Structure for build in " UNIX "
#--- Description : in UNIX need to balnk at fileType and buildMode
#---
#--- Examples
#--- initial (fullpath-packagename(XDEV)) (Zion Config)
#--- buildExample  (applicationfullpath) (application) (platform)
#---
#######################################################################################################################################






#######################################################################################################################################
#--- WINDOW EXAMPLE---#
#######################################################################################################################################
# set tcl_pkgPath	{BuildScript}
# lappend auto_path	{C:\OneClick\Scripts\BuildScript}
# package require Build 1.1
# set fd [ open "./logResult/01_PackageVerification_W08E_32_90_SH.log" w ]
# initial "C:\\Packages\\RFACPP760_XDEV5" "./config-zion.txt"
##################################################################
######################### W08E_32_90_SH ##########################
##################################################################
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\Consumer Consumer W08E_32_90_SH vcproj Release]
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\Consumer Consumer W08E_32_90_SH vcproj Debug]
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\HybridApp HybridApp W08E_32_100_ST vcxproj Release ]
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\HybridApp HybridApp W08E_32_100_ST vcxproj Debug ]
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\NewsDisplay NewsDisplay W08E_32_90_SH sln ]
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\NewsDisplay NewsDisplay W08E_32_90_SH sln ]
# puts $fd [ buildExampleInWindows Examples_01_PackageVerification\\HybridApp HybridApp W08E_32_100_ST vcxproj ]
#######################################################################################################################################






#######################################################################################################################################
#--- UNIX EXAMPLE---#
#######################################################################################################################################
# set tcl_pkgPath	{BuildScript}
# lappend auto_path	{C:\OneClick\Scripts\BuildScript}
# package require Build 1.1
# set fd [ open "./logResult/01_PackageVerification_RH5L_32_412_SH.log" w ]
# initial "/export/home/administrator/RFACPP760_XDEV5" "./config-zion.txt"
##################################################################
######################### RH5L_32_412_SH ##########################
##################################################################
# puts $fd [ buildExample Examples_01_PackageVerification/Consumer Consumer RH5L_32_412_SH ]
# puts $fd [ buildExample Examples_01_PackageVerification/HybridApp HybridApp RH5L_32_412_SH ]
# puts $fd [ buildExample Examples_01_PackageVerification/Provider_Interactive Provider_Interactive RH5L_32_412_SH ]
# puts $fd [ buildExample Examples_01_PackageVerification/StarterConsumer StarterConsumer RH5L_32_412_SH ]
# puts $fd [ buildExample Examples_01_PackageVerification/StarterConsumer_BatchView StarterConsumer_BatchView RH5L_32_412_SH ]
# puts $fd [ buildExample Examples_01_PackageVerification/StarterConsumer_Chain StarterConsumer_Chain RH5L_32_412_SH ]
#######################################################################################################################################
