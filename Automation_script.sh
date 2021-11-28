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


