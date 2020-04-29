import time
from .base import Base
import deoplete.logger

class Source(Base):
  def __init__(self, vim):
    Base.__init__(self, vim)

    self.vim = vim

    self.name = "conjure"
    self.filetypes = self.lua("conjure.config", "filetypes")
    self.rank = 500

  def lua(self, module, f, *args):
    return self.vim.exec_lua("return require('" + module + "')['" + f + "'](...)", *args)

  def gather_candidates(self, context):
    p = self.lua("conjure.eval", "completions-promise", context["complete_str"])
    while not self.lua("conjure.promise", "done?", p):
      time.sleep(0.02)
    return self.lua("conjure.promise", "close", p)
