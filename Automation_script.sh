# Installing awscli is done
# sudo apt update
# sudo apt install awscli

#my name variable
myname=sourajyoti

#update package
sudo apt update -y

#install apache2
sudo apt install apache2

#apache2 installation testing
WEB="apache2"

for pkg in $WEB; do
    if [ "dpkg-query -W $pkg | awk {'print $1'} = """ ]; then
        echo -e "$pkg is already installed"
    else
        apt-get -qq install $pkg
        echo "Successfully installed $pkg"
    fi
done

#apache2 service status testing
servstat=$(service apache2 status)

if [[ $servstat == *"active (running)"* ]]; then
  echo "process is running"
else 
  sudo systemctl start apache2
  echo "process is not running"
fi

#Apache service enable if not started, need to add in code
enable=$(sudo systemctl is-enabled apache2)
if [[ $enable=="enabled" ]];then
        echo " Apache service is enable"
else
        echo " Apache service is disable"
        echo " Enabling Apache service"
        sudo systemctl enable apache2
fi


#sending logs file to tmp
sudo find /var/log/apache2/ -type f -name '*.log' -print | while read FILE ; do
    BASENAME=`basename ${FILE} '.log'`
    cp ${FILE} /tmp/${BASENAME}.log
    cat > ${FILE} << EOF
EOF
done

#compressing tar file
timestamp=$(date '+%d%m%Y-%H%M%S')
sudo tar -czvf /tmp/$myname-httpd-logs-${timestamp}.tar /tmp/*.log

#S3bucket variable
S3_bucket=arn:aws:s3:us-east-1:925710499357:accesspoint/sourajyoti-accesspoint

# To copy the files from EC2 to S3
s3_bucket=arn:aws:s3:us-east-1:925710499357:accesspoint/sourajyoti-accesspoint
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://$s3_bucket/${myname}-httpd-logs-${timestamp}.tar
echo "File has been moved to S3-bucket"

#Scheduling cron job and creating inventory html file
inv_file="/var/www/html/inventory.html"
crn_file="/etc/cron.d/automation"
timestamp=$(date '+%d%m%Y-%H%M%S')
file_size=$(stat -c %s /tmp/*.tar)


if [ ! -f "$inv_file" ]
then
touch "$inv_file"
echo "Log Type&ensp;&ensp;&ensp;&ensp;Time Created&ensp;&emsp;&emsp;&emsp;Type&ensp;&ensp;&ensp;&emsp;Size&ensp;&ensp;&ensp;&ensp;<br>" >> "$inv_file"
fi
echo -e "<br><br>" >> $inv_file

echo "httpd-logs&ensp;&ensp;&ensp;&nbsp;"$timestamp"&ensp;&emsp;&nbsp;&nbsp;tar&ensp;&ensp;&emsp;&emsp;"$file_size"&ensp;&ensp;&ensp;<br>" >> "$inv_file"

if [ ! -f "$crn_file" ]
then
touch "$crn_file"
echo "00 00 * * * root /Automation_Project/Automation_script.sh" > "$crn_file"
fi

