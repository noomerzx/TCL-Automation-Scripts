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
      _JAVA_HOME="/cygdrive/c/Program Files/Java/jdk/bin"
   else
      echo "[Shell] Detect OS : UNIX"
      _AUTOMATE_PATH=${AT_UNIX_AUTOMATE_PATH}
      _PACKAGE_PATH=${AT_UNIX_PACKAGEPATH}
      _OS=${AT_UNIX_OS}
      _SEPERATOR=${AT_UNIX_SEPERATOR}
      _JAVA_HOME=${AT_UNIX_JAVA_HOME}
	  export PATH=${_JAVA_HOME}:$PATH
   fi
   # Initial Environment variable
   export CLASSPATH="${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}bin${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}jaxrpc.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}activation.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}axis.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}commons-discovery-0.2.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}javax.wsdl_1.6.2.v201012040545.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}mail.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}org.apache.commons.logging_1.1.1.v201101211721.jar${_SEPERATOR}${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}lib${_OS}saaj.jar"
   # export PATH="${_JAVA_HOME}:${PATH}"
   # export TCL_LIBRARY="C:\Tcl\lib\tcl8.4"
   echo "CLASSPATH = ${CLASSPATH}"
   echo "PATH = ${PATH}"
   # echo "TCL_LIBRARY = ${TCL_LIBRARY}"
}

convertSectionsToForLoop () {
   # remove double-quote(") from begin and last position, then replace ',' with whitespace ' '
   _SECTIONS=${_SECTIONS#\"}
   _SECTIONS=${_SECTIONS%\"}
   _SECTIONS=${_SECTIONS//,/ }
}

createConfigurationForJavaMyapp () {
   echo "+endpoint \"http://zion.ims.bkk.apac.ime.reuters.com/webservice?wsdl\"" > $1
   echo "+product \"${_ZION_PRODUCT}\"" >> $1
   echo "+project \"${_ZION_PROJ}\"" >> $1
   echo "+round \"${_PKG_NAME}\"" >> $1
   echo "+subRound \"${_ZION_SUB_ROUND}\"" >> $1
   echo "+username \"${_ZION_USER}\"" >> $1
   echo "+password \"${_ZION_PASSWORD}\"" >> $1
   echo "+sectionList \"${Section}\"" >> $1
   echo "+nodeName \"${2}\"" >> $1
   echo "+osSlash \"${_OS}\"" >> $1
   echo "+buildJenkinsUrl \"http://192.168.8.54:8080/job/05_Build_Slave\"" >> $1
   echo "+executeJenkinsUrl \"http://192.168.8.54:8080/job/06_Execute\"" >> $1
   echo "+packagePath \"${_PACKAGE_PATH}${_OS}${_PKG_NAME}\"" >> $1
   echo "+globalFile \"${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}Global_Input_Win.txt\"" >> $1
   echo "+systemTestPath \"${_AUTOMATE_PATH}\"" >> $1
   echo "+runScriptFilePath \"${_AUTOMATE_PATH}${_OS}Tools${_OS}RunScript${_OS}RunScript.tcl\"" >> $1
   echo "+masterBatchPath \"${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}\"" >> $1
   echo "+buildPath \"${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}${_OS}BuildExamples\"" >> $1
   echo "+executePath \"${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}${_OS}RunAT\"" >> $1
   echo "+scriptPath \"${_AUTOMATE_PATH}${_OS}RfaCppAT${_OS}${Section}${_OS}Scripts\"" >> $1
   echo "+templatePath  \"${_AUTOMATE_PATH}${_OS}RfaCppAT${_OS}${Section}${_OS}Configs${_OS}Batch\"" >> $1
   echo "+testHostPath \"${_AUTOMATE_PATH}${_OS}Tools${_OS}PrepareScripts${_OS}Config${_OS}testHost.txt\"" >> $1
   echo "+historyScriptPath \"${_AUTOMATE_PATH}${_OS}Tools${_OS}MoveLogFileToTestHistory${_OS}MoveLogFileToTestHistory.tcl\"" >> $1
   echo "+generateBuildScriptLocation \"${_AUTOMATE_PATH}${_OS}Tools${_OS}GenerateBuildScript${_OS}generateBuildScripts.tcl\"" >> $1
   echo "+appListForEachPlatform \"${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}${_OS}BuildExamples${_OS}inputForBuild\"" >> $1
   echo "+zionConfigPath \"${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}config-zion.txt\"" >> $1
   echo "+testHitoryPath \"P:\SystemTest\Test_History\"" >> $1
   #echo "+genZionConfig \"yes\"" >> $1
   #echo "+masterJob \"build\"" >> $1
   #echo "+masterJob \"execute\"" >> $1
   echo "+genBuild \"yes\"" >> $1
   #echo "+genConfig \"yes\"" >> $1
   #echo "+genRun \"yes\" " >> $1
   echo "[Shell] Generate Java configs"
   cat $1
   echo ""
}

#=============================================================================================
# Main 
#=============================================================================================

initialVariablesForRunningOS
convertSectionsToForLoop

for Section in ${_SECTIONS}
do
   # Ensure that required folder exists, and cd to target path
   echo "[Shell] Change Path to ${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}${_OS}BuildExamples"
   mkdir -p ${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}${_OS}BuildExamples
   cd ${_AUTOMATE_PATH}${_OS}RunAT${_OS}${_PKG_NAME}${_OS}${Section}${_OS}BuildExamples

   # Get platform name by cut from node
   PLAT_CURRENT=`echo ${NODE_NAME} | sed "s/_64.*/_64/g" | sed "s/_32.*/_32/g"`
   echo "[Shell] Generate current platform from ${NODE_NAME} to ${PLAT_CURRENT}"

   # SET CONFIG file for java
   CONFIG_JAVA="05_Build_Slave_${PLAT_CURRENT}_Config.txt"
   createConfigurationForJavaMyapp ${CONFIG_JAVA} ${PLAT_CURRENT}

   # SET CLASS PATH and run JAVA Myapp
   echo "[Shell] Set CLASSPATH and Run MyApp (JAVA)"
   java my.main.MyApp +ConfigFile "${CONFIG_JAVA}"
   # rm -f ${CONFIG_JAVA}

   # Generate Build Script
   echo "[Shell] Generate Build Script"
   rm -rf ${PLAT_CURRENT}*.bat
   chmod 777 gen_${PLAT_CURRENT}.bat
   ./gen_${PLAT_CURRENT}.bat
   wait $!
   rm -rf gen_${PLAT_CURRENT}.bat
   wait $!

   # Run Build Script
   echo "Call Build Script"
   chmod -fR +x Scripts
   for script in *${PLAT_CURRENT}*.bat
   do
      echo "runscript " $script
      chmod 777 $script
      ./$script
      wait $!
   done

   # Trigger 06_Execute_Slave_<Section> after
   # wget "http://192.168.8.54:8080/job/06_Execute_${_SECTIONS}_Slave/buildWithParameters?_MACHINES=${NODE_NAME}&_SECTIONS=${_SECTIONS}"
   rm -rf *html*.*
   rm -rf *.html

done
