sudo apt-get update
sed "s/\$ROS_DISTRO/$ROS_DISTRO/g" "dependencies" | xargs sudo apt-get install -y 
pip install -r requirements.txt
pip3 install -r requirements3.txt
