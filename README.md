# es-substring-search
Elasticsearch substring search exercise

## List of files
* settings.json: Settings for mapping and ngram analyzer.
* emails.yml: Sample email data for indexing. Consists of 1000 emails from the enron email corpus.
* es_client.rb: Elasticsearch client with methods to create index, index data and query.

## Instructions
Run the es_client.rb to create an index named "emails", index sample data using the data from emails.yml file. Compares the multi search results obtained through highlighting and constant score query methods. 

```
bundle exec
```

```
ruby es_client.rb
```
