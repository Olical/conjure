(module conjure.dev.fennel
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core}})

(set nvim.g.conjure#filetype_client
     (a.assoc nvim.g.conjure#filetype_client
              :fennel :conjure.client.fennel.stdio))

(set nvim.g.conjure#debug false)
