((comment) @injection.content (#offset! @injection.content 0 2 0 0)
           (import_declaration (import_spec path: (interpreted_string_literal
                                                    (interpreted_string_literal_content)
                                                    @package (#eq? @package
                                                              "C")))) (#set!
                                                                       injection.language
                                                                       "c"))
