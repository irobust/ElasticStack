# Kibana Query Language(KQL)
## Simple Queries
### Show me everything
```
GET bank/account/_search
```

### Find CA accounts only
```
GET bank/account/_search
{
  "query": {
    "match": {
      "state": "CA"
    }
  }
}
```

### Find "Techade" accounts in CA only
```
GET bank/account/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": {"state": "CA"} },
        { "match": {"employer": "Techade"}}
      ]
    }
  }
}
```

### Find non "Techade" accounts outside of CA
```
GET bank/account/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "match": {"state": "CA"} },
        { "match": {"employer": "Techade"}}
      ]
    }
  }
}
```

### Boost results for Smith
```
GET bank/account/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": {"state": "CA"} },
        { "match": {
          "lastname": {
            "query": "Smith",
            "boost": 3
            }
          }
        }
      ]
    }
  }
}
```

## Term-Level Queries
### Term Query
```
GET bank/account/_search
{
  "query": {
    "term": {
      "account_number": 516
    }
  }
}
```

### Returns null because "state" is a text field (hence not an exact match)
```
GET bank/account/_search
{
  "query": {
    "term": {
      "state": "RI"
    }
  }
}
```

### This works because it uses the "analysis" process
```
GET bank/account/_search
{
  "query": {
    "match": {
      "state": "RI"
    }
  }
}
```

### Terms can return multiple results
```
GET bank/account/_search
{
  "query": {
    "terms": {
      "account_number": [516,851]
    }
  }
}
```

## Range Queries
```
gte = Greater-than or equal to
gt = Greater-than
lte = Less-than or equal to
lt = Less-than
```

### Show all accounts between 516 and 851, boosting the importance
```
GET bank/account/_search
{
  "query": {
    "range": {
      "account_number": {
        "gte": 516,
        "lte": 851,
        "boost": 2
      }
    }
  }
}
```

### Show all account holders older than 35
```
GET bank/account/_search
{
  "query": {
    "range": {
      "age": {
        "gt": 35
      }
    }
  }
}
```

## Basic aggregation
### Count of Accounts by State (Must be keyword field)
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}

### Add average balance in each state
Nesting the metric inside the agg
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "avg_bal": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
```

### Breakdown further with Nesting
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "avg_bal": {
          "avg": {
            "field": "balance"
          }
        },
        "gender":{
          "terms": {
            "field": "gender.keyword"
          }
        }
      }
    }
  }
}
```

### Add avg_price metric to lowest level
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "avg_bal": {
          "avg": {
            "field": "balance"
          }
        },
        "gender":{
          "terms": {
            "field": "gender.keyword"
          },
          "aggs": {"avg_bal": {"avg": {"field": "balance"} }
          }
        }
      }
    }
  }
}
```

### Get stats about bank balances
Size=1 to omit search results
```
GET bank/account/_search
{
  "size": 1,
  "aggs": {
    "balance-stats": {
      "stats": {
        "field": "balance"
      }
    }
  }
}
```

## Filtering aggregation
### Count of Accounts by State(Must be keyword field)
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```

### This is the equivalent of using match_all
```
GET bank/account/_search
{
  "size": 0,
  "query": {
    "match_all": {}
  },
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```

### Aggs work in the context of the query, so apply a filter like normal
```
GET bank/account/_search
{
  "size": 0,
  "query": {
    "match": {
      "state.keyword": "CA"
    }
  },
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```

### You can also filter on terms
```
GET bank/account/_search
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {"match": {"state.keyword": "CA"}},
        {"range": {"age": {"gt": 35}}}
      ]
    }
  },
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```

### Lets add a metric back in
```
GET bank/account/_search
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {"match": {"state.keyword": "CA"}},
        {"range": {"age": {"gt": 35}}}
      ]
    }
  },
  "aggs": {
    "states": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {"avg_bal": {"avg": {"field": "balance"} }}
    }
  }
}
```

### You can also just filter the results
```
GET bank/account/_search
{
  "size": 0,
  "query": {
    "match": {"state.keyword": "CA"}
  },
  "aggs": {
    "over35":{
      "filter": {
        "range": {"age": {"gt": 35}}
      },
    "aggs": {"avg_bal": {"avg": {"field": "balance"} }}
    }
  }
}
```

### Look at state avg and global average
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "state_avg": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {"avg_bal": {"avg": {"field": "balance"}}}
    },
    "global_avg": {
      "global": {},
      "aggs": {"avg_bal": {"avg": {"field": "balance"}}}
    }
  }
}
```

## Percentiles and Histrograms
### Look at the percentiles for the balances
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "pct_balances": {
      "percentiles": {
        "field": "balance",
        "percents": [
          1,
          5,
          25,
          50,
          75,
          95,
          99
        ]
      }
    }
  }
}
```

### Can also calculate High Dynamic Range (HDR) Historgram
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "pct_balances": {
      "percentiles": {
        "field": "balance",
        "percents": [
          1,
          5,
          25,
          50,
          75,
          95,
          99
        ],
        "hdr": {
          "number_of_significant_value_digits": 3
        }
      }
    }
  }
}
```

### We can use the percentile ranks agg for checking a individual values
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "bal_outlier": {
      "percentile_ranks": {
        "field": "balance",
        "values": [35000,50000],
        "hdr": {
          "number_of_significant_value_digits": 3
        }
      }
    }
  }
}
```

### Similarly we can create a histogram
```
GET bank/account/_search
{
  "size": 0,
  "aggs": {
    "bals": {
      "histogram": {
        "field": "balance",
        "interval": 500
      }
    }
  }
}
```
