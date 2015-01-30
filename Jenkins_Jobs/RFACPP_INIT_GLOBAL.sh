initialVariablesForRunningOS () {
   UNAME_S=`uname -s`
   if [[ $UNAME_S == *Windows* ]]
   then
      echo "[Shell] Detect OS : Windows"
      set +e
      net use p: \\\\192.168.8.151\\TESTMAP apibkk /user:administrator 
      set -e
      # _AUTOMATE_PATH=${AT_WIN_AUTOMATE_PATH}
      # _PACKAGE_PATH=${AT_WIN_PACKAGEPATH}
      # _OS=${AT_WIN_OS}
      _AUTOMATE_PATH="P:\SystemTest"
      _PACKAGE_PATH="P:\Packages\RFACPP"
      _OS="\\"
      _SEPERATOR=${AT_WIN_SEPERATOR}
      JAVA_HOME=${AT_WIN_JAVA_HOME}
   else
      echo "[Shell] Detect OS : UNIX"
      _AUTOMATE_PATH=${AT_UNIX_AUTOMATE_PATH}
      _PACKAGE_PATH=${AT_UNIX_PACKAGEPATH}
      _OS=${AT_UNIX_OS}
      _SEPERATOR=${AT_UNIX_SEPERATOR}
      JAVA_HOME=${AT_UNIX_JAVA_HOME}
   fi
   # Initial Environment variable
   export CLASSPATH="${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}bin${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}jaxrpc.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}activation.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}axis.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}commons-discovery-0.2.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}javax.wsdl_1.6.2.v201012040545.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}mail.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}org.apache.commons.logging_1.1.1.v201101211721.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}saaj.jar"
   export PATH="${_JAVA_HOME}${_SEPERATOR}${PATH}"
   export TCL_LIBRARY="C:\Tcl\lib\tcl8.4"
   echo "CLASSPATH = ${CLASSPATH}"
   echo "PATH = ${PATH}"
   echo "TCL_LIBRARY = ${TCL_LIBRARY}"
}

GenerateGlobalInput () {
   # specific platfrom variable
   env | egrep "^AT\_${2}\_" > tmp.txt
   echo "SHORTEN_PLATFORM=${3}" >> tmp.txt
   sed "s/AT_${2}_//g" tmp.txt > ${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}Global_Input_${1}.txt

   # common for all platforms
   env | egrep "^AT\_COMMON\_" > tmp2.txt
   sed "s/AT_COMMON_//g" tmp2.txt >> ${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}Global_Input_${1}.txt
}

###############################################################################
#
# Generate Config.txt for each Platform.
# Still need Jenkins plugin for copy files into running folder.
#
###############################################################################

#cat rfacpp.properties
#=============================================================================
#=============================================================================
# Replace # with $
initialVariablesForRunningOS
export `env | grep "#DOLLA_SIGN#" | sed "s/#DOLLA_SIGN#/\\\\\\\\$/g"`
#=============================================================================


#=============================================================================
#=============================================================================
# Overwrite _SECTIONS with JOB_NAME
_SECTIONS=`echo $JOB_NAME | cut -d'_' -f 4-`
echo $_SECTIONS
#=============================================================================

#=============================================================================
#=============================================================================
# For each "W", "R", and "S"
# "W" represent for W08, W7, etc.
# "R" represent for RHEL5, etc.
# "S" represent for SL10, SS11, etc.
for i in W R SS SL
do
   echo $i
   #=============================================================================
   #=============================================================================
   #  Initial specific parameter for each OS type
   # mkdir -p Global_Input
   if [ "$i" = "W" ]; then
      #=============================================================================
      #=============================================================================
      # WINDOWS
      #=============================================================================
      GenerateGlobalInput WIN WIN win
      # env | egrep "^AT\_WIN\_" > tmp.txt
      # env | egrep "^AT\_COMMON\_" > tmp2.txt
      # echo "SHORTEN_PLATFORM=win" >> tmp.txt
      # sed "s/AT_WIN_//g" tmp.txt > ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_WIN.txt
      # sed "s/AT_COMMON_//g" tmp2.txt >> ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_WIN.txt
      #cat Global_Input_${_SECTIONS}.txt

      export _NODENAME=W
      export _OSSLASH=\\\\
   elif [ "$i" = "R" ]; then
      #=============================================================================
      #=============================================================================
      # UNIX RHEL
      #=============================================================================
      GenerateGlobalInput RHEL UNIX linux
      # env | egrep "^AT\_UNIX\_" > tmp.txt
      # env | egrep "^AT\_COMMON\_" > tmp2.txt
      # echo "SHORTEN_PLATFORM=linux" >> tmp.txt
      # sed "s/AT_UNIX_//g" tmp.txt > ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_RHEL.txt
      # sed "s/AT_COMMON_//g" tmp2.txt >> ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_RHEL.txt
      #cat Global_Input_${_SECTIONS}.txt

      export _NODENAME=R
      export _OSSLASH=\\\\
   elif [ "$i" = "SS" ]; then
      #=============================================================================
      #=============================================================================
      # UNIX SUSE
      #=============================================================================
      GenerateGlobalInput SUSE UNIX linux
      # env | egrep "^AT\_UNIX\_" > tmp.txt
      # env | egrep "^AT\_COMMON\_" > tmp2.txt
      # echo "SHORTEN_PLATFORM=linux" >> tmp.txt
      # sed "s/AT_UNIX_//g" tmp.txt > ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_SUSE.txt
      # sed "s/AT_COMMON_//g" tmp2.txt >> ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_SUSE.txt
      # #cat Global_Input_${_SECTIONS}.txt

      export _NODENAME=SS
      export _OSSLASH=\\\\
   elif [ "$i" = "SL" ]; then
      #=============================================================================
      #=============================================================================
      # UNIX SOL
      #=============================================================================
      GenerateGlobalInput SOL UNIX solaris
      # env | egrep "^AT\_UNIX\_" > tmp.txt
      # env | egrep "^AT\_COMMON\_" > tmp2.txt
      # echo "SHORTEN_PLATFORM=solaris" >> tmp.txt
      # sed "s/AT_UNIX_//g" tmp.txt > ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_SOL.txt
      # sed "s/AT_COMMON_//g" tmp2.txt >> ${_AUTOMATE_PATH}${_OS}${_PKG_NAME}${_OS}Global_Input_SOL.txt
      # #cat Global_Input_${_SECTIONS}.txt

      export _NODENAME=SL
      export _OSSLASH=\\\\
   fi
     
   rm -rf tmp.*
	
   #rm -rf ${_ATPATH}/Global_Input.txt
   #rm -rf ${_ATPATH}/testHost.txt
   #cp -rf Global_Input.txt ${_ATPATH}/Global_Input.txt
   #cp -rf testHost.txt ${_ATPATH}/testHost.txt

   #=============================================================================
   #=============================================================================
   #  Initial CLASSPATH for call MyApp java
   #export CLASSPATH=".:PrepareScripts/bin:activation.jar:axis.jar:commons-discovery-0.2.jar:javax.wsdl_1.6.2.v201012040545.jar:jaxrpc.jar:mail.jar:org.apache.commons.logging_1.1.1.v201101211721.jar:saaj.jar"

   # export CLASSPATH=".;PrepareScripts/bin;activation.jar;axis.jar;commons-discovery-0.2.jar;javax.wsdl_1.6.2.v201012040545.jar;jaxrpc.jar;mail.jar;org.apache.commons.logging_1.1.1.v201101211721.jar;saaj.jar"

   #=============================================================================
   #=============================================================================
   #  Calling MyApp java
   # java my.main.MyApp +endpoint http://zion.ims.bkk.apac.ime.reuters.com/webservice?wsdl +product "${_ZION_PRODUCT}" +project ${_ZION_PROJ} +round ${_PKG_NAME} +SubRound ${_ZION_SUB_ROUND} +username ${_ZION_USER} +password ${_ZION_PASSWORD} +sectionList "${_SECTIONS}" +atPath "${_ATPATH}" +templatePath "${_TEMPLATEPATH}" +nodeName "${_NODENAME}" +osSlash "${_OSSLASH}" +globalFile "Global_Input/Global_Input_${_SECTIONS}.txt"

   #=============================================================================
done
