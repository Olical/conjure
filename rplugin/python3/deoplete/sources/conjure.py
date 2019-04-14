from .base import Base
import deoplete.logger
import socket
import json

class Source(Base):
  def __init__(self, vim):
    Base.__init__(self, vim)
    self.name = "conjure"
    self.filetypes = ['clojure']
    self.rank = 500

    rpc_port = vim.api.call_function("conjure#get_rpc_port", [])
    self.sock = socket.socket()
    self.sock.connect(("localhost", rpc_port))

  def gather_candidates(self, context):
    msg = json.dumps([0, 1, "completions", [context["complete_str"]]]) + "\n"
    self.sock.send(msg.encode())
    res = json.loads(self.sock.makefile().readline())
    return res[3]
