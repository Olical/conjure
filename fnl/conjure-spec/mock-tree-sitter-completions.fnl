(var mock-completions [])

(fn set-mock-completions [r]
  (set mock-completions r))

(fn get-completions-at-cursor [_ _]
  mock-completions)

{: get-completions-at-cursor
 : set-mock-completions }

