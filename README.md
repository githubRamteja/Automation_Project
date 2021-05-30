# Automation_Project
This repository contains an automation script that checks if a web server is installed or not and installs apache2 web server if needed.
And then checks if the service for apache2 is enabled and running or not. Enables/starts the service if not already done.
Then the script creates logs based on time and compresses the log files using the tar compression.
Once done, these log files will be uploaded into an AWS S3 bucket.
