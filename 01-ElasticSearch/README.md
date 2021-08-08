# Module 01: ElasticSearch
Introduction to elasticsearch

## Start elasticsearch with docker-compose
Start elasticsearch with docker compose
```
cd 01-ElasticSearch
docker-compose up -d
```
## Explore elasticsearch
Basic REST API to manage your cluster

### Overall Cluster Health
```
GET /_cat/health?v
```

### Node Health
```
GET /_cat/nodes?v
```

### List Indices
```
GET /_cat/indices?v
```

### Create 'sales' Index
```
PUT /sales
```

### Add 'order' to 'sales' index
```
PUT /sales/order/123
{
"orderID":"123",
"orderAmount":"500"
}
```

### Retrieve document
```
GET /sales/order/123
```

### Delete index
```
DELETE /sales
```
## Bulk loading data
### Create file with requests (make sure to include new line at end of file)
Create new file and set filename to reqs
```
{ "index" : { "_index" : "my-test", "_type" : "my-type", "_id" : "1" } }
{ "col1" : "val1"}
{ "index" : { "_index" : "my-test", "_type" : "my-type", "_id" : "2" } }
{ "col1" : "val2"}
{ "index" : { "_index" : "my-test", "_type" : "my-type", "_id" : "3" } }
{ "col1" : "val3" }
```

# Load from CURL
@reqs is file that you created in previous step
```
curl -s -H "Content-Type: application/x-ndjson" -XPOST localhost:9200/_bulk --data-binary "@reqs"; echo
```

# Check with Kibana
```
GET /my-test
GET /my-test/my-type/1
```

# Load from Console
```
POST _bulk
{ "index" : { "_index" : "my-test-console", "_type" : "my-type", "_id" : "1" } }
{ "col1" : "val1" }
{ "index" : { "_index" : "my-test-console", "_type" : "my-type", "_id" : "2" } }
{ "col1" : "val2"}
{ "index" : { "_index" : "my-test-console", "_type" : "my-type", "_id" : "3" } }
{ "col1" : "val3" }
```

## Loading sample data from elastic.co
### Load via curl, notice the endpoint and type
```
cd data
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/bank/account/_bulk?pretty' --data-binary @accounts.jsonl
```

### Check inside ElasticSearch
```
GET /_cat/indices
GET /bank
```

### set index pattern in Kibana
    ``` Management > Uncheck time-based events > bank ```
and View on left to see properties