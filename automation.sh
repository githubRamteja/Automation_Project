sudo apt update -y
#sudo su

#initializing variables required
webserver="apache2"
pkg="apache2"
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="sriramteja"
s3_bucket="upgrad-sriramteja"

# Checking if apache2 is installed and installing if not.
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ];
then
	sudo apt install $pkg -y
fi

#Checking if apache2 service is running and starting it if not already.
apache_status=$(service apache2 status)

if [[ $apache_status == *"active (running)"* ]];
then
	echo "Apache service is running"
else
	sudo systemctl start apache2
fi

#Archiving logs as per timestamp using the tar command
tar -cf ${myname}-httpd-logs-${timestamp}.tar $(find /var/log/apache2 -type f -name '*.log')

#Copying the tar file into /tmp folder
cp ${myname}-httpd-logs-${timestamp}.tar /tmp

#Uploading the file into s3 bucket
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

#Confirmation message after copying to the S3 Bucket
echo "Copied to S3 Bucket $s3_bucket"
