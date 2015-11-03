require 'httparty'
require 'yaml'
require 'json'
require 'pry'

class EsClient
  include HTTParty
  base_uri "http://localhost:9200"
  headers "Accept" => "application/json"
end

INDEX_URL = "/emails"

def create_index
  res = EsClient.head(INDEX_URL)
  if res.code == 200
    EsClient.delete(INDEX_URL)
  end
  res = EsClient.post(INDEX_URL, body: File.read("settings.json"))
  raise "Could not create index" if res.code != 200
  puts "Index emails successfully created"
end

def populate_data
  emails = YAML.load_file("emails.yml")
  emails.each_with_index do |email, ind|
    res = EsClient.put("#{INDEX_URL}/email/#{ind}", body: email.to_json)
    raise "Data index failure" unless (res.code == 201 || res.code == 200)
  end
end

def query_highlight(term)
  return {
    "size" => 100,
    "query" => {
      "multi_match" => {
        "query" => term,
        "fields" => ["subject", "text"]
      }
    },
    "highlight" => {
      "fields" => {"*" => {}}
    }
  }.to_json
end

def query_constant_score(term)
  return {
    "size" => 100,
    "query" => {
      "constant_score" => {
        "query" => {
          "bool": {
            "disable_coord" => true,
            "should" => [
              {"match" => { "subject" => {"query"=> term, "_name"=> "subject"}}},
              {"match" => { "text" => {"query"=> term, "_name"=> "text"}}}
            ]
          }
        }
      }
    }
  }.to_json
end

def msearch(terms, request_body, search_type)
  responses = EsClient.post("/_msearch", body: request_body)
  raise "Something went wrong with the query" unless responses.code == 200
  responses["responses"].each_with_index do |response, ind|
    send("parse_#{search_type}".to_sym, terms[ind], response)
  end
end

def parse_highlight(term, response)
  field_hits = Hash.new(0)
  document_hits = response["hits"]["total"]
  response["hits"]["hits"].each do |hit|
    hit["highlight"].each do |field, values|
      field_hits[field] += values.count
    end
  end
  puts "*********** Query term: #{term} **********"
  puts "Field hits: " unless field_hits.empty?
  field_hits.each do |field, count|
    puts "  #{field} => #{count}"
  end
  total_field_hits = field_hits.empty?? 0 : field_hits.values.reduce(&:+)
  puts "Document hits: #{document_hits}"
  puts "Total field hits: #{total_field_hits}"
  puts "Time taken: #{response['took']}"
end

def parse_constant_score(term, response)
  document_hits = response["hits"]["total"]
  field_hits = Hash.new(0)
  response["hits"]["hits"].each do |hit|
    hit["matched_queries"].each do |field|
      field_hits[field] += 1
    end
  end
  puts "*********** Query term: #{term} **********"
  puts "Field hits: " unless field_hits.empty?
  field_hits.each do |field, count|
    puts "  #{field} => #{count}"
  end
  total_field_hits = field_hits.empty?? 0 : field_hits.values.reduce(&:+)
  puts "Document hits: #{document_hits}"
  puts "Total field hits: #{total_field_hits}"
  puts "Time taken: #{response['took']}"
end

def search(terms, search_type)
  queries = []
  index_query = { "index" => "emails" }
  terms.each do |term|
    queries << index_query.to_json
    query = send("query_#{search_type}".to_sym, term)
    queries << query
  end
  formatted_queries = queries.join("\n")
  formatted_queries += "\n"
  msearch(terms, formatted_queries, search_type) 
end

#create_index
#populate_data
#sleep 5
terms = YAML.load_file("terms.yml")["terms"]
puts "************************ Multi Search by highlight ************************\n\n"
search(terms, "highlight")
puts "************************ Multi Search by constant score ************************\n\n"
search(terms, "constant_score")
