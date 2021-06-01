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
	echo "Installing apache2 package"
	sudo apt install $pkg -y
fi

#Checking if apache2 service is enabled or not
apache_service_status=$(systemctl is-enabled apache2)
if [[ $apache_service_status == "enabled" ]];
then
	echo "Apache2 service is enabled."
else
	echo "Enabling apache2 service"
	sudo systemctl enable apache2
	echo "Apache2 service is now enabled."
fi

#Checking if apache2 service is running and starting it if not already.
apache_status=$(service apache2 status)

if [[ $apache_status == *"active (running)"* ]];
then
	echo "Apache service is running"
else
	echo "Starting apache2 service"
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

echo "Copied to S3 Bucket $s3_bucket"

#calculating tar file size
tar_size="$(du -h "${myname}-httpd-logs-${timestamp}.tar" | cut -f1)"

html_record="<p>httpd-logs\&emsp;\&emsp;\&emsp;$timestamp\&emsp;\&emsp;\&emsp;tar\&emsp;\&emsp;\&emsp;$tar_size<\/p>"
html_file="/var/www/html/inventory.html"


if [[ ! -f /var/www/html/inventory.html ]]
then
        touch /var/www/html/inventory.html
	sudo chmod 666 /var/www/html/inventory.html
        echo -e "<html>\n<body>\n<h3>Log Type&emsp;&emsp;Time Created&emsp;&emsp;Type&emsp;&emsp;Size</h3>\n</body>\n</html>" >> /var/www/html/inventory.html
else
        echo "The inventory.html file exists"
	sudo sed -i "/<\/body>/i $html_record" "$html_file"
	echo "Appended the log data"
fi


if [[ ! -f /etc/cron.d/automation ]]
then
        sudo touch /etc/cron.d/automation
        echo "0 0 * * * root /root/Automation_Project/automation.sh" |sudo tee /etc/cron.d/automation
        sudo chmod +x /etc/cron.d/automation
	echo "Automation cron job is created in /etc/cron.d/"
else
        echo "The automation cron job exists"
fi
