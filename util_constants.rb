module UtilConstants
  NGRAM_FILTER = {
    "ngram_filter" => {
      "type" => "ngram",
      "min_gram" => 2,
      "max_gram" => 7
    }
  }
  ANALYZER = {
    "ngram_analyzer" => {
      "type" => "custom",
      "tokenizer" => "standard",
      "filter" => [
        "lowercase",
        "ngram_filter"
      ]
    }
  }
end
