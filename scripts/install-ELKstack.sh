#!/usr/bin/env bash

# Check if ELK Stack has been installed
if [ -f /home/vagrant/.elasticsearch ] && [ -f /home/vagrant/.kibana ] && [ -f /home/vagrant/.logstash ]
then
    echo "ELK Stack already installed."
    exit 0
fi

# Determine version from config

set -- "$1"
IFS="."; declare -a version=($*)

if [ -z "${version[1]}" ]; then
    installVersion=""
else
    installVersion="=$1"
fi

# Install Java 8

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

# Install Elasticsearch

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/${version[0]}.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-${version[0]}.x.list
sudo apt-get update
sudo apt-get -y install elasticsearch"$installVersion"

# Start Elasticsearch on boot

sudo update-rc.d elasticsearch defaults 95 10

# -------------------- Update Elasticsearch Configuration Starts --------------------

# Use 'homestead' as the cluster
sudo sed -i "s/#cluster.name: my-application/cluster.name: homestead/" /etc/elasticsearch/elasticsearch.yml

# Enable port binding so that local machine can access VM ports
echo "network.host: 0.0.0.0" | sudo tee -a /etc/elasticsearch/elasticsearch.yml

# # Enable CORS origin so that your frontend Javascript can send request to ES. 
# # '*' wildcard is currently being used. Change this for production.
echo "http.cors.allow-origin: '*'" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "http.cors.enabled: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml

# # Increase request http content line length, because the content length of the query might be too long. 
echo "http.max_content_length: 1024mb" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "http.max_initial_line_length: 1024kb" | sudo tee -a /etc/elasticsearch/elasticsearch.yml

# -------------------- Update Elasticsearch Configuration Ends --------------------

# Enable Start Elasticsearch

sudo systemctl enable elasticsearch.service
sudo service elasticsearch start




# # Install Kibana

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/${version[0]}.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-${version[0]}.x.list
sudo apt-get update
sudo apt-get -y install kibana"$installVersion"

# Start Kibana on boot

sudo update-rc.d kibana defaults 95 10

# -------------------- Update Kibana Configuration Starts --------------------

# Enable port binding so that local machine can access VM ports
echo "server.host: 0.0.0.0" | sudo tee -a /etc/kibana/kibana.yml

# -------------------- Update Kibana Configuration Ends --------------------

# Enable Start Kibana

sudo systemctl enable kibana.service
sudo service kibana start




# Install Logstash
sudo apt-get -y install logstash