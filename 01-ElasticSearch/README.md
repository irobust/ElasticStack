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
curl -s -H "Content-Type: application/json" -XPOST localhost:9200/_bulk --data-binary "@data/reqs.jsonl"
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
curl -XPOST "http://localhost:9200/bank/account/_bulk?pretty" -H 'Content-Type: application/json' --data-binary "@data/accounts.jsonl"
```

### Check inside ElasticSearch
```
GET /_cat/indices
GET /bank
```

### Set index pattern in Kibana
1. Go to index pattern page
     Home > Management > Index Pattern
2. Define index pattern name `bank*`
3. Custom index pattern id (Optional)
4. Edit fields mapping (Must verify it later)

## Index mapping
### Sample index mapping with GeoPoint
#### Step 1: create mapping
```
PUT my-index-000001
{
  "mappings": {
    "properties": {
      "location": {
        "type": "geo_point"
      }
    }
  }
}
```
#### Step 2: Add data to my-index-000001
```
PUT my-index-000001/_doc/1
{
  "text": "Geopoint as an object",
  "location": { 
    "lat": 41.12,
    "lon": -71.34
  }
}

PUT my-index-000001/_doc/2
{
  "text": "Geopoint as a string",
  "location": "41.12,-71.34" 
}

PUT my-index-000001/_doc/3
{
  "text": "Geopoint as a geohash",
  "location": "drm3btev3e86" 
}

PUT my-index-000001/_doc/4
{
  "text": "Geopoint as an array",
  "location": [ -71.34, 41.12 ] 
}

PUT my-index-000001/_doc/5
{
  "text": "Geopoint as a WKT POINT primitive",
  "location" : "POINT (-71.34 41.12)" 
}
``` 

#### Step 3: Query with Geo-Bounding-Box
```
GET my-index-000001/_search
{
  "query": {
    "geo_bounding_box": { 
      "location": {
        "top_left": {
          "lat": 42,
          "lon": -72
        },
        "bottom_right": {
          "lat": 40,
          "lon": -74
        }
      }
    }
  }
}
```

### Add mapping for lat/lon geo properties for logs
```
PUT /logstash-2021.07.18
{
  "mappings": {
    "properties": {
        "geo": {
            "properties": {
                "coordinates": {
                    "type": "geo_point"
                }
            }
        }
    }
  }
}
```

### Create two more to simulate daily logs
```
PUT /logstash-2021.07.19
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
PUT /logstash-2021.07.20
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
```

### Import log files
```
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/_bulk?pretty' --data-binary @logs.jsonl
```

### Check ElaticSearch for data
```
GET /_cat/indices/logstash-*
```
