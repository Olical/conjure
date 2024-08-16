(fn viml->lua [m f opts]
  (.. "lua require('" m "')['" f "']("
      (or (and opts opts.args) "") ")"))

{: viml->lua}
