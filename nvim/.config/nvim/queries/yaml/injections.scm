(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "query")
  value: (block_node
    (block_scalar) @injection.content
    (#set! injection.language "sql")
    (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "query")
  value: (flow_node
    (double_quote_scalar) @injection.content
    (#set! injection.language "sql")
    (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node (plain_scalar (string_scalar) @injection.language)) 
  value: (block_node
    (block_scalar) @injection.content
    (#offset! @injection.content 0 1 0 0)))

