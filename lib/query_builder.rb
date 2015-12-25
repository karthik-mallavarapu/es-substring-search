class QueryBuilder

  attr_reader :doc_types, :index, :field_types, :query_string

  def initialize(field_types, config)
    @field_types = field_types
    @index = config[:index]
    @doc_types = field_types.keys
    @query_string = config[:query]
  end

  def constant_score_query(source=false, size=100)
    request_body = {
      '_source' => source,
      'size' => size
    }
    request_body['query'] = {
     'constant_score' => {
        'query' => { 'bool' => { 'disable_coord' => true, 'should' => [] } }
     }
    }
    match_queries = []
    field_types.each do |doc_type, fields|
      fields.each do |field|
        match_queries << match_named_query(doc_type, field)
      end
    end
    request_body['query']['constant_score']['query']['bool']['should'] = match_queries
    return request_body
  end

  def search_url
    doc_types_string = doc_types.join(',')
    return "#{index}/#{doc_types_string}/_search"
  end

  private

  def match_named_query(doc_type, field)
    return {
      "match" => {
        field => { 'query' => query_string, '_name' => "#{doc_type}_#{field}" }
      }
    }
  end
end
