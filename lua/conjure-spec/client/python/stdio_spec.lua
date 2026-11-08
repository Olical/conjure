-- [nfnl] fnl/conjure-spec/client/python/stdio_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local python = require("conjure.client.python.stdio")
local ts = require("conjure.tree-sitter")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.log"] = mock_log
local fake_python_repl = {"printf '>>> ' >&2", "while IFS= read -r line; do", "  case \"$line\" in", "    *exec\\(*) sleep 0.1; echo None;;", "    *print_prompt*) printf '>>> look\\nNone\\n';;", "  esac", "  printf '>>> ' >&2", "done"}
local function _2_()
  local function _3_()
    local function _4_()
      local function _5_(_)
        return true
      end
      python["str-is-python-expr?"] = _5_
      return assert.same("__file__ = base64.b64decode('L3RtcC9leGFtcGxlLnB5').decode(); __file__\n", python["prep-code"]({code = "__file__", ["file-path"] = "/tmp/example.py"}))
    end
    it("sets __file__ before evaluating expressions on a single line", _4_)
    local function _6_()
      local function _7_(_)
        return false
      end
      python["str-is-python-expr?"] = _7_
      return assert.same("__file__ = base64.b64decode('L3RtcC9leGFtcGxlLnB5').decode(); exec(compile(base64.b64decode('cHJpbnQoX19maWxlX18p'), __file__, 'exec'))\n", python["prep-code"]({code = "print(__file__)", ["file-path"] = "/tmp/example.py"}))
    end
    it("sets __file__ and uses it as the filename for exec evaluations on a single line", _6_)
    local function _8_()
      local function _9_(_)
        return true
      end
      python["str-is-python-expr?"] = _9_
      return assert.same("__file__ = base64.b64decode('PGNvbmp1cmU+').decode(); __file__\n", python["prep-code"]({code = "__file__"}))
    end
    it("uses a fallback filename when no file path is available", _8_)
    local function _10_()
      local function _11_(_)
        return false
      end
      python["str-is-python-expr?"] = _11_
      vim.g["conjure#client#python#stdio#auto_set_file"] = false
      local code = python["prep-code"]({code = "print(1)", ["file-path"] = "/tmp/example.py"})
      vim.g["conjure#client#python#stdio#auto_set_file"] = nil
      return assert.same("exec(compile(base64.b64decode('cHJpbnQoMSk='), base64.b64decode('L3RtcC9leGFtcGxlLnB5').decode(), 'exec'))\n", code)
    end
    return it("does not depend on __file__ being defined when auto_set_file is disabled", _10_)
  end
  describe("prep-code", _3_)
  local function _12_()
    local function _13_()
      do
        local repl_path = vim.fn.tempname()
        local previous_add_language = ts["add-language"]
        local results = {}
        vim.fn.writefile(fake_python_repl, repl_path)
        vim.g["conjure#client#python#stdio#command"] = ("sh " .. repl_path)
        local function _14_()
          return true
        end
        ts["add-language"] = _14_
        python.start()
        for _, _15_ in ipairs({{"print_prompt()", true}, {"slow()", false}, {"slow()", false}}) do
          local code = _15_[1]
          local expr_3f = _15_[2]
          local function _16_(_0)
            return expr_3f
          end
          python["str-is-python-expr?"] = _16_
          local function _17_(_241)
            return table.insert(results, _241)
          end
          python["eval-str"]({code = code, ["file-path"] = "/tmp/example.py", ["on-result"] = _17_})
        end
        local function _18_()
          return (3 == #results)
        end
        vim.wait(3000, _18_)
        python.stop()
        vim.g["conjure#client#python#stdio#command"] = nil
        ts["add-language"] = previous_add_language
        assert.same({"None", "None", "None"}, results)
      end
      return nil
    end
    return it("completes each eval on its own prompt, not an earlier or printed one", _13_)
  end
  return describe("eval-str against a prompt-per-line REPL", _12_)
end
return describe("conjure.client.python.stdio", _2_)
