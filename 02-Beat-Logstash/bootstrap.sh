echo "[Task 1] Add GPG key from Elastic and app package to source list"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-9.x.list
echo "deb https://artifacts.elastic.co/packages/oss-9.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-9.x.list

echo "[Task 2] Update system"
sudo apt-get update

echo "[Task 3] Install filebeat"
sudo apt-get install -y filebeat
sudo systemctl enable filebeat

echo "[Task 4] Install nginx"
sudo apt-get install -y nginx
