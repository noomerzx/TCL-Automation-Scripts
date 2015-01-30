set +e
net use p: \\\\192.168.8.151\\TESTMAP apibkk /user:administrator 
set -e

_SECTIONS=${_SECTIONS#\"}
_SECTIONS=${_SECTIONS%\"}

cd ${AT_WIN_AUTOMATE_PATH}/Tools/Jenkins_Code/Create_Job

set +e
#./Job/cleanJob_*.bat
set -e

sed s/word/All,${_SECTIONS}/g ../XML_Config_Jobs/05_Build_Master_Config.xml > ../XML_Config_Jobs/buildMaster.xml
sed s/word/All,${_SECTIONS}/g ../XML_Config_Jobs/05_Build_Slave_Config.xml > ../XML_Config_Jobs/buildSlave.xml
sed s/word/All,${_SECTIONS}/g ../XML_Config_Jobs/06_Execute_Master_Config.xml > ../XML_Config_Jobs/exeMaster.xml

echo ${_SECTIONS} > temp.txt
sed "s/,/\\`echo -e '\r\n'`/g" temp.txt > input.txt
rm -rf temp.txt

tclsh createJenkinsJob.tcl 05_Build_Master ../XML_Config_Jobs/buildMaster.xml
tclsh createJenkinsJob.tcl 05_Build_Slave ../XML_Config_Jobs/buildSlave.xml
tclsh createJenkinsJob.tcl 06_Checkout_SAMI ../XML_Config_Jobs/06_Checkout_SAMI_Config.xml
tclsh createJenkinsJob.tcl 06_Execute_00_Master ../XML_Config_Jobs/exeMaster.xml
tclsh createJenkinsJob.tcl 06_Execute_[word]_Slave ../XML_Config_Jobs/06_Execute_Slave_Config.xml input.txt

rm -rf ../XML_Config_Jobs/buildMaster.xml
rm -rf ../XML_Config_Jobs/buildSlave.xml
rm -rf ../XML_Config_Jobs/exeMaster.xml

#./Job/genJob_*.bat