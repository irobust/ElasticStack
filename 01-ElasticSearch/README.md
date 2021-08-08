# Module 01: ElasticSearch
Introduction to elasticsearch

## Start elasticsearch with docker-compose
Start elasticsearch with docker compose
    ```vstscli
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
### Create File with Requests (make sure to include new line at end of file)
create file reqs
    ```json
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

# Check Kibana
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