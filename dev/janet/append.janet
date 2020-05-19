(-> (file/open "triforce.txt" :a)
    (file/write "Janet!\n")
    (file/flush)
    (file/close))
