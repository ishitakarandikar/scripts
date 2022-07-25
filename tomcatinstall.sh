#!/bin/bash

if [[ $EUID -ne 0 ]]; then
echo "You must run the script as root or using sudo"
   exit 1
fi


check_java_home() {
 if [ -z ${JAVA_HOME} ];
    then
        echo 'Could not find JAVA_HOME. Please install Java and set JAVA_HOME'

       
       read -p  "Do you wish to install Java?[Y/N]:" ans

    case $ans in
        [Yy] ) update; install_java; set_javahome ;;
        [Nn] ) read -p "Please install java or if you already have Java, Do you wish to set your JAVA_HOME path?[Y/N]:" res
                      case $res in
                      [Yy] ) set_javahome ;;
                      [Nn] ) echo "Please set JAVA_HOME manually" ; exit 1 ;;
           esac


    esac



    else 
	echo 'JAVA_HOME found: '$JAVA_HOME
          install_tomcat
        if [ ! -e ${JAVA_HOME} ]
        then
	    echo 'Invalid JAVA_HOME. Make sure your JAVA_HOME path exists'
	    exit
        fi
    fi

}
update()
{
sudo apt-get update
}

set_javahome()
{

path="JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64""
if grep "$path" /etc/profile > /dev/null
then
echo "path already set"
. /etc/profile
install_tomcat

else
echo "export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"
export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
exit 1

fi
}

install_java()
{
sudo apt-get install default-jdk
sudo apt-get install default-jre
if [ $? -eq 0 ]; then
  echo "Please set JAVA_HOME"
  set_javahome
else
  echo "Error in Java Installation"
 exit 1
fi

}

install_tomcat()
{
cd /tmp
if [  -f  "apache-tomcat-9.0.64.tar.gz" ]; then
echo "Tomcat already exists."
elif [[ ! -f "apache-tomcat-9.0.64.tar.gz" ]]; then

sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
cd /tmp
curl -O  https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.64/bin/apache-tomcat-9.0.64.tar.gz
chmod +rx apache-tomcat-9*tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1




fi
}

tomcat_start()
{
read -p  "Do you wish to start tomcat?[Y/N]:" ans

    case $ans in
        [Yy] ) cd /opt/tomcat/bin; ./startup.sh; echo "please check localhost";;
        [Nn] ) echo "Okay";;
    esac

}

echo 'Installing tomcat server...'
echo "Updating..."
update
echo 'Checking for JAVA_HOME...'
check_java_home

   
