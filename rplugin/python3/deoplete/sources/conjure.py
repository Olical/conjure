from .base import Base
import deoplete.logger

class Source(Base):
  def __init__(self, vim):
    Base.__init__(self, vim)

    self.vim = vim

    self.name = "conjure"
    self.filetypes = vim.exec_lua("return require('conjure.config').filetypes()")
    self.rank = 500

  def gather_candidates(self, context):
    p = self.vim.exec_lua("return require('conjure.eval')['completions-promise'](...)", context["complete_str"])
    self.vim.exec_lua("require('conjure.promise').await(...)", p)
    return self.vim.exec_lua("return require('conjure.promise').close(...)", p) or []
