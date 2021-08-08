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

### Load timestamp data
#### Step 1: Create index
```
PUT /securityinfo
```
#### Step 2: Pushing data
```
curl -X POST http://localhost:9200/securityinfo/_doc/ -H 'Content-Type: application/json' -d'
{
    "@timestamp": 2021-01-05T10:10:10",
    "message":  "Protocol Port MIs-Match",
    "dst": {
        "ip": "192.168.1.56",
        "port": "888"
    }
}
'
```

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
### Add index mapping to securityinfo
#### Step 1: Mapping types to field
```
PUT /securityinfo-v2
{
  "mappings":{
      "properties": {
        "destination.ip": { "type": "ip"},
        "destination.port": { "type": "number" },
        "message": { "type": "text" }
      }
  }
}
```

#### Step 2: Input data through Dev Tools
```
PUT /securityinfo-v2
{
    "@timestamp": "2021-01-05T10:10:10",
    "message":  "Protocol Port MIs-Match",
    "destination.ip": "192.168.1.56",
    "destination.port": "888"
}
```

### Logging simulation
#### Step 1: Add mapping for lat/lon geo properties for logs
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

#### Step 2: Create two more to simulate daily logs
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

#### Step 4: Import log files
```
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/_bulk?pretty' --data-binary @logs.jsonl
```

#### Step 4: Check ElaticSearch for data
```
GET /_cat/indices/logstash-*
```

## Using analyzer in ElasticSearch
### Testing standard analyzer
#### Step 1: Check standard analyzer capability
```
GET /_analyze
{
  "analyzer": "standard",
  "text": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
  "explain": true
}
```

#### Step 2: Add some data
```
PUT /demo-url
PUT /demo-url/_doc/1
{
  "url.original": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd"
}
```

#### Step 3: Query and Filter data
1. using query: `url.original:wp-content`
2. using filter: `url.original is wp-content`
3. Select `Edit as Query DSL`
4. Change `match_phrase` to `term` (You'll get no result)

#### Step 4: Try to analyze with standard, simple, keywords and pattern
```
GET /_analyze
{
  "analyzer": "standard",
  "text": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
  "explain": true
}

GET /_analyze
{
  "analyzer": "simple",
  "text": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
  "explain": true
}

GET /_analyze
{
  "analyzer": "keyword",
  "text": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
  "explain": true
}

GET /_analyze
{
  "analyzer": "pattern",
  "text": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
  "explain": true
}
```

#### Step 5: Create a custom analyzer
```
PUT securityinfo-v3/
{
  "settings": {
    "analysis": {
        "analyzer":{
            "url_pattern_analyzer": {
                "type": "pattern",
                "pattern": "\\/|\\?"
            }
        }
    }
  },
  "mappings": {
    "properties": {
      "url.original": {
        "type": "text",
        "analyzer": "url_pattern_analyzer"
      },
      "destination.ip": {"type":"ip"},
      "destination.port": {"type": "integer"},
      "message":{
        "type":"text",
        "analyzer": "keyword"
      }
    }
  }
}
```

#### Step 6: Testing custom analyzer
```
GET securityinfo-v3/_analyze
{
  "field": "url.original",
  "text": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
  "explain": true
}
```

#### Step 7: Tesing keyword analyzer
```
GET securityinfo-v3/_analyze
{
  "field": "message",
  "text": "ALERT BAD THING HAPPENING MAYBE"
}
```

#### Step 8: Add some data 
```
POST /securityinfo/_doc
{
    "@timestamp": "2021-08-01T10:10:10",
    "url.origin": "https://blog.example.com/wp-content/plugins/evil.php?cmd=cat+%2Fetc%2Fpasswd",
    "message":  "Protocol Port MIs-Match",
    "destination.ip": "192.168.1.56",
    "destination.port": "888"
}
```