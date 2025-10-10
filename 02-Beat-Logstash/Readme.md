# How to install and configuring Beat
## Installation Guide
Reference for all beats
https://www.elastic.co/guide/en/beats/libbeat/current/getting-started.html

## Support Matrix
https://www.elastic.co/support/matrix

## Setup Environment
### Start Ubuntu for install filebeat and nginx
```vstscli
vagrant up
```
### Start Elasticsearch, Kibana and Logstash with docker compose
```vstscli
docker-compose up -d
```

## FileBeat
Setting up and running filebeat
https://www.elastic.co/guide/en/beats/filebeat/current/setting-up-and-running.html

### Step 0: Generate Certificate
```
// Get Certificate Authority
sudo docker compose exec -it elasticsearch bin/elasticsearch-certutil ca
sudo docker compose cp elasticsearch:/usr/share/elasticsearch/elastic-stack-ca.p12 /home/vagrant

// Get Client Certificate
sudo docker compose exec -it elasticsearch bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
sudo docker composr cp elasticsearch:/usr/share/elasticsearch/elastic-certificates.p12 /home/vagrant
sudo mv elastic-certificates.p12 /vagrant
```

### Step 1: Install and enable filebeat
```
sudo apt-get install filebeat
sudo systemctl enable filebeat
```

### Step 2: Configuring and start filebeat
Modify /etc/filebeat/filebeat.yml
```yaml
tags: ["us-west-01"]
fields:
    environment: staging
output.elasticsearch:
  hosts: ["ELASTIC_IP_ADDRESS:9200"]
  ssl:
     enabled: true
     verification_mode: none
     keystore.path: "/vagrant/elastic-certificates.p12"
     truststore.path: "/vagrant/elastic-certificates.p12"

  username: "elastic"
  password: "****"

setup.kibana:
    host: "KIBANA_URL:5601"
```

Don't forget to testing configuration file with this commands
```vstscli
filebeat test config
filebeat test output
```

### Step 3: Collect data
```vstscli
filebeat modules list
filebeat modules enable nginx
```

### Step 4: Config log location
Modify /etc/filebeat/modules.d/nginx.yml
```vstscli
- module: nginx
  access:
    var.paths: ["/var/log/nginx/access.log*"] 
```

### Step 5: Set up assets
```vstscli
filebeat setup -e
```

This CURL command upload filebeat template to Kibana server for older version
```vstscli
curl -XPUT "http://localhost:9200/_template/filebeat" -d "@/etc/filebeat/filebeat.template.json"
```

### Step 6: Start filebeat
```vstscli
sudo systemctl start filebeat
```

### Step 7: Discover data from Kibana
* Open browser and goto `http://<Host-IP-Address>:5601`
* In older version, You need to create index pattern manually 
* Select index pattern `filebeat-*`

## MetricBeat
Setting up and running metricbeat
https://www.elastic.co/guide/en/beats/metricbeat/7.14/setting-up-and-running.html

### Step 1: Install metricbeat
```vstscli
sudo apt-get install metricbeat
sudo systemctl enable metricbeat

```
### Step 2: Configure metricbeat
Modify /etc/metricbeat/metricbeat.yml
```yaml
output.elasticsearch:
    hosts: ["ELASTICSEARCH_URL:9200"]
setup.kibana:
    host: "KIBANA_URL:5601"
```

Don't forget to testing configuration file with this commands
```vstscli
metricbeat test config
metricbeat test output
```

### Step 3: Collect data
```vstscli
metricbeat modules list
metricbeat modules enable nginx
```

### Step 5: Set up assets
```vstscli
metricbeat setup -e
```

### Step 6: Start metricbeat
```vstscli
sudo systemctl start metricbeat
```

### Step 7: Discover data from Kibana
* Open browser and goto `http://<Host-IP-Address>:5601`
* Goto dashboard and select `[Metricbeat.System] Host Overview`

## HeartBeat
Setting up and running heartbeat
https://www.elastic.co/guide/en/beats/heartbeat/7.14/setting-up-and-running.html

### Step 1: Install heartbeat
```vstscli
sudo apt-get install heartbeat-elastic
sudo systemctl enable heartbeat-elastic
```
On Windows you need to install winpcap first
https://www.winpcap.org


### Step 2: Configure heartbeat to monitor elasticsearch and kibana
Modify /etc/heartbeat/heartbeat.yml
```yaml
output.elasticsearch:
    hosts: ["ELASTICSEARCH_URL:9200"]
```

Create /etc/heartbeat/monitors.d/tcp-demo.yml
```yml
- type: tcp
  name: tcpdemo
  enabled: true
  schedule: "@every 5s"
  hosts: ["192.168.2.37:9200", "192.168.2.37:5601"]
  timeouts: 10s
```

Don't forget to testing configuration file with this commands
```vstscli
heartbeat test config
heartbeat test output
```

### Step 5: Set up assets
```vstscli
heartbeat setup -e
```

### Step 6: Start heartbeat
```vstscli
sudo systemctl start heartbeat
```

### Step 7: Discover data from Kibana
* Open browser and goto `http://<Host-IP-Address>:5601`
* Goto Observability > Uptime 
* Create index pattern for discover data

### Step 8: Try to  monitor local services
Add more monitoring
```yaml
- type: tcp
  name: webserver
  enabled: true
  schedule: "@every 5s"
  hosts: ["localhost"]
  ports: [80]
```

### Step 9: Restart heartbeat to update configuration
```vstscli
sudo systemctl restart heartbeat-elastic
```

## PacketBeat
https://www.elastic.co/guide/en/beats/packetbeat/7.14/setting-up-and-running.html

### Step 1: Install and enable packetbeat
```
sudo apt-get install packetbeat
sudo systemctl enable packetbeat
```

### Step 2: Configuring and start packetbeat
Modify /etc/packetbeat/packetbeat.yml
```yaml
output.elasticsearch:
    hosts: ["ELASTICSEARCH_URL:9200"]
setup.kibana:
    host: "KIBANA_URL:5601"
```

Don't forget to testing configuration file with this commands
```vstscli
packetbeat test config
packetbeat test output
```

### Step 5: Set up assets
```vstscli
paketbeat setup -e
```

### Step 6: Start packetbeat
```vstscli
sudo systemctl start packetbeat
```

### Step 7: Discover data from Kibana
* Open browser and goto `http://<Host-IP-Address>:5601`
* Select index pattern `packetbeat-*`
* See network traffic in dashboard `[PacketBeat] DNS Overview ECS`
* Try to run this command
```vstscli
ping sanook.com
```

## Auditbeat
https://www.elastic.co/guide/en/beats/auditbeat/7.15/setting-up-and-running.html

### Step 1: Install auditd
```
sudo apt-get install auditd
```

### Step 2: Install and enable auditbeat
```
sudo apt-get install auditbeat
sudo systemctl enable packetbeat
```

### Step 2: Configuring and start auditbeat
Modify /etc/auditbeat/auditbeat.yml
```yaml
output.elasticsearch:
    hosts: ["ELASTICSEARCH_URL:9200"]
setup.kibana:
    host: "KIBANA_URL:5601"
```

Don't forget to testing configuration file with this commands
```
auditbeat test config
auditbeat test output
```

### Step 5: Set up assets
```vstscli
auditbeat setup -e
```

### Step 6: Start auditbeat
```vstscli
sudo systemctl start auditbeat
```

### Step 7: Discover data from Kibana
* Open browser and goto `http://<Kibana-IP-Address>:5601`
* Select index pattern `auditbeat-*`

## WinLogBeat
https://www.elastic.co/guide/en/beats/winlogbeat/7.14/setting-up-and-running.html

# How to install and configuring Logstash
## Instrmenting Linux Server
Loading SYSLOG data to formatting with logstash

### Step 0: Generate Certificate
```
// Get Certificate Authority (Elasticsearch)
sudo docker compose exec -it elasticsearch bin/elasticsearch-certutil ca --pem
sudo docker compose cp elasticsearch:/usr/share/elasticsearch/elastic-stack-ca.zip /home/vagrant
sudo unzip elastic-stack-ca.zip
sudo mv elastic-stack-ca /vagrant

// Get Logstash Certificate
sudo docker compose cp ca elasticsearch:/usr/share/elasticsearch
sudo docker compose exec -it elasticsearch bin/elasticsearch-certutil cert --ca-cert ca/ca.crt --ca-key ca/ca.key \
       --ip [LOGSTASH_IP] --pem --name logstash
sudo docker compose cp elasticsearch:/usr/share/elasticsearch/logstash-cert.zip /home/vagrant
sudo unzip logstash-cert.zip
cd logstash-cert
openssl pkcs8 -inform PEM -in logstash.key -topk8 -nocrypt -outform PEM -out logstash.pkcs8.key
sudo docker compose cp logstash-cert logstash:/usr/share/logstash
sudo dokcer compose cp ca logstash:/usr/share/logstash
sudo cp logstash-cert /vagrant

// Get Client Certificate
sudo docker compose exec -it elasticsearch bin/elasticsearch-certutil cert --ca-crt ca/ca.crt --pem --name client
sudo docker composr cp elasticsearch:/usr/share/elasticsearch/client-cert.zip /home/vagrant
sudo unzip client-cert.zip
sudo mv client-cert /vagrant
```

### Step 1: Install and enable filebeat
```
sudo apt-get install filebeat
sudo systemctl enable filebeat
```

### Step 2: Configuring and start filebeat
Modify /etc/filebeat/filebeat.yml
```yaml
enabled: true
paths:
    - /var/log/syslog
document_type: syslog

tags: ["us-west-01"]
fields:
    environment: staging

output.logstash:
    hosts: ["LOGSTASH_URL:5043"]
    ssl:
       enabled: true
       verification_mode: none
       certificate_authorities: ["/vagrant/ca/ca.crt"]
       certificate: "/vagrant/logstash/logstash.crt"
       key: "/vagrant/logstash/logstash.pkcs8.key"
setup.kibana:
    host: "KIBANA_URL:5601"
```

Don't forget to testing configuration file with this commands
```vstscli
filebeat test config
filebeat test output
```
### Step 3 Update Logstash Configuration
#### Step 3.1: Update TLS Connection
```
input {
  beats {
    port => 5044
    ssl_enabled => true
    ssl_certificate_authorities => ["/usr/share/logstash/ca/ca.crt"]
    ssl_certificate => "/usr/share/logstash/logstash/logstash.crt"
    ssl_key => "/usr/share/logstash/logstash/logstash.pkcs8.key"
    ssl_client_authentication => "required"
  }
}

output {
  elasticsearch{
        hosts => ["elasticsearch:9200"]
        index => "logstash-%{[@metadata][beat]}-%{+YYYY.MM.dd}"
        user => elastic
        password => [ELASTIC_PASSWORD]
    }
}
```
#### Step 3.2: Add filter
```vstscli
input {
  beats {
    port => 5044
    ssl_enabled => true
    ssl_certificate_authorities => ["/usr/share/logstash/ca/ca.crt"]
    ssl_certificate => "/usr/share/logstash/logstash/logstash.crt"
    ssl_key => "/usr/share/logstash/logstash/logstash.pkcs8.key"
    ssl_client_authentication => "required"
  }
}
filter{
    if [type] == "syslog" {
        grok{
            match => {"message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}])?: %{GREEDYDATA:syslog_message}"}
        }
        date {
            match => [ "syslog_timestamp", "MMM d HH:mm:ss", "MMM dd HH:mm:ss" ]
        }
    }
}
output {
  elasticsearch{
        hosts => ["elasticsearch:9200"]
        index => "logstash-%{[@metadata][beat]}-%{+YYYY.MM.dd}"
        user => elastic
        password => [ELASTIC_PASSWORD]
    }
}
```

### Step 4: Restart Logstash
```vstscli
sudo systemctl stop logstash
sudo systemctl start logstash
```

### Step 5: Set up assets
```vstscli
filebeat setup -e
```

This CURL command upload filebeat template to Kibana server for older version
```vstscli
curl -XPUT "http://localhost:9200/_template/filebeat" -d "@/etc/filebeat/filebeat.template.json"
```

### Step 6: Start filebeat service
```vstscli
sudo systemctl start filebeat
```

### Step 7: Discover data from Kibana
* Open browser and goto `http://<Host-IP-Address>:5601`
* Select index pattern `filebeat-*`
