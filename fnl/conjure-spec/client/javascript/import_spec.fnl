(local {: describe : it } (require :plenary.busted))
(local assert (require :luassert.assert))
(local replacer (require :conjure.client.javascript.import-replacer))

(describe "conjure.client.javascript.import-replacer" 
  (fn [] 
    (it "replace import correctly"
        (fn []
          (let [tests
                [["import defaultExport from \"module-name\";"
                  "const defaultExport = require(\"module-name\");"]
                 ["import * as name from \"module-name\";"
                  "const name = require(\"module-name\");"]
                 ["import { export1 } from \"module-name\";"
                  "const { export1 } = require(\"module-name\");"]
                 ["import { export1 as alias1 } from \"module-name\";"
                  "const { export1: alias1 } = require(\"module-name\");"]
                 ["import { default as alias } from \"module-name\";"
                  "const { default: alias } = require(\"module-name\");"]
                 ["import { export1, export2 } from \"module-name\";"
                  "const { export1, export2 } = require(\"module-name\");"]
                 ["import { export1, export2 as alias2, some_other_export } from \"module-name\";"
                  "const { export1, export2: alias2, some_other_export } = require(\"module-name\");"]
                 ["import { \"string name\" as alias } from \"module-name\";"
                  "const { \"string name\": alias } = require(\"module-name\");"]
                 ["import defaultExport, { export1, export2 as alias2 } from \"module-name\";"
                  "const {defaultExport, export1, export2: alias2 } = require(\"module-name\");"]
                 ["import defaultExport, * as name from \"module-name\";"
                  "const name = require(\"module-name\");\nconst defaultExport = name.default;"]
                 ["import \"module-name\";"
                  "require(\"module-name\");"]
                 ["import { func } from './utils';"
                  "const { func } = require(\"./utils\");"]
                 ["export default function() {}"
                  "export default function() {}"]]]
            (each [_i  [act exp] (ipairs tests)]
              (assert.same (replacer.replace-imports-regex act) exp)))))))
