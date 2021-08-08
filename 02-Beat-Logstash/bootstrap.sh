echo "[Task 1] Add GPG key from Elastic and app package to source list"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

echo "[Task 2] Install filebeat"
sudo apt-get update && sudo apt-get install filebeat
sudo systemctl enable filebeat

echo "[Task 3] Install nginx"
sudo apt-get install nginx
