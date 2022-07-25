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
  install_tomcat
else
  echo "JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"" >> /etc/environment
source ./etc/environment
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
 echo "Error in Java Installation "
 exit 1
fi
}


test()
{
cd /tmp

if  [  -f "apache-tomcat-9.0.64.tar.gz" ];
then
echo "hello"
else
echo "y"
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

install_jenkins()
{
cd /etc/init.d
if [[ ! -f "jenkins" ]]; then

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
e>     /etc/apt/sources.list.d/jenkins.list' 
sudo apt-get update
sudo apt-get install jenkins 

else
echo "jenkins already exists"

fi 

}

start_jenkins()
{
sudo /etc/init.d/jenkins start

}

echo 'Installing jenkins...'
update
if [ $? -eq 0  ]; then
     echo 'Checking for JAVA_HOME...'
     check_java_home
      if [ $? -eq 0  ]; then
      echo 'Checking for tomcat...'
      install_tomcat
           if [ $? -eq 0  ]; then
           echo "Setup okay for jenkins"
            install_jenkins
                   
                    if [ $? -eq 0 ]; then
                     read -p  "Do you wish to setup you Jenkins?[Y/N]:" ans 
                        case $ans in
                       [Yy] ) start_jenkins ; echo "please use the following password then setup username password"; 
     echo "please use this command to know your password --> sudo cat /var/lib/jenkins/secrets/initialAdminPassword";;
                           [Nn] ) echo "Okay";;
                         esac
                    else 
                    echo "Okay"
                     fi


           else 
          echo "Cannot install jenkins.. check on tomcat"
            fi
      else
      echo "JAVA_PATH is not set" 
fi

else
sudo apt-get upgrade
fi


