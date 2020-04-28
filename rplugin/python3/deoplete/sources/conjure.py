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
    return self.vim.exec_lua("return require('conjure.eval')['completions-sync'](...)", context["complete_str"])
