((comment) @injection.content (#offset! @injection.content 0 2 0 0)
           (import_declaration (import_spec path: (interpreted_string_literal
                                                    (interpreted_string_literal_content)
                                                    @package (#eq? @package
                                                              "C")))) (#set!

                                                                       "c"))

(call_expression
    function:
    (selector_expression
        field: (field_identifier) @_ident)(#any-of? @_ident "Exec" "Query" "QueryRow")
        arguments: (
            (argument_list (raw_string_literal (raw_string_literal_content) @injection.content)))
    (#set! injection.language "sql")
    )
