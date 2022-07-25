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
        [Yy] ) update; install_java;;
        [Nn] ) read -p "Please install java or if you already have Java, Do you wish to set your JAVA_HOME path?[Y/N]:" res
                     case $res in
                     [Yy] ) set_javahome ;;
                     [Nn] ) echo "Please set JAVA_HOME manually"; exit 1;;
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
if grep "$path" /etc/environment > /dev/null
then 
 echo "path already set"
  exit 1
else
  echo "JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"" >> /etc/environment
   echo "export JAVA_HOME" >> /etc/environment
exit 1
fi

}

install_java()
{
sudo apt-get install default-jdk
sudo apt-get install default-jre
if [ $? -eq 0 ]; then
 set_javahome
else
 echo "Error in Java Installation "
 exit 1
fi
}


install_tomcat()
{
cd /tmp
if [  -f  "apache-tomcat-9.0.65.tar.gz" ]; then
echo "Tomcat already exists."
install_jenkins

elif [[ ! -f "apache-tomcat-9.0.65.tar.gz" ]]; then

sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
cd /tmp
curl -O  https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz
chmod +rx apache-tomcat-9*tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1


install_tomcat

fi
}


install_jenkins()
{
cd /etc/init.d
if [[ ! -f "jenkins" ]]; then

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
e>     /etc/apt/sources.list.d/jenkins.list' 
sudo apt-get update
sudo apt-get install jenkins 

jsetup

else
echo "jenkins already exists"
jsetup

fi 

}
jsetup()
{

cp -r -u /home/ishitakarandikar/test1/plugins/. /var/lib/jenkins/plugins
if [ $? -eq 0 ]; then
echo "plugins setup success"
else
echo "plugins setup failed"

fi 

cp -r -u /home/ishitakarandikar/test1/jobs/. /var/lib/jenkins/jobs
if [ $? -eq 0 ]; then
echo "jobs setup success"
else 
echo "jobs setup failure"
fi

start_jenkins
}

start_jenkins()
{
sudo /etc/init.d/jenkins start
echo "please use this command to know your initial password --> sudo more /var/lib/jenkins/secrets/initialAdminPassword"
}

echo 'Installing jenkins...'
update
if [ $? -eq 0  ]; then
     echo 'Checking for JAVA_HOME...'
     check_java_home
      
else
sudo apt-get upgrade
fi


