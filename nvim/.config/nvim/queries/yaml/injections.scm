(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "query" "sql")
  value: (block_node
    (block_scalar) @injection.content
    (#set! injection.language "sql")
    (#offset! @injection.content 0 1 0 0)))

