metadata
default_source :supermarket

run_list 'tktm_test::default'
named_run_list :tm_2019, "tktm_test::tm_2019"
named_run_list :tm_shellout, "tktm_test::tm_shellout"
named_run_list :tm_io, "tktm_test::tm_io"
