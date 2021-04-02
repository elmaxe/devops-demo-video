#! /bin/bash
cp /var/www/devops-demo/devops-demo.service /etc/systemd/system
##add exceutable permissions to express app
sudo chmod +x /var/www/devops-demo/server.js
##Allows any users to write the app folder. Useful if using fs within the app
sudo chmod go+w /var/www/devops-demo
##Launches the express app
sudo systemctl daemon-reload
sudo systemctl start devops-demo
sudo systemctl enable devops-demo