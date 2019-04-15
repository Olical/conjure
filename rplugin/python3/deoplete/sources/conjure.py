from .base import Base
import deoplete.logger
import socket
import json
import os

# This disables the global Conjure Deoplete source while in development.
# So the only one that'll return results will be the local development version.
allowed_dir = os.environ.get("CONJURE_ALLOWED_DIR", "/")
current_path = os.path.realpath(__file__)
is_enabled = current_path.startswith(allowed_dir)

# Create a class to perform completions, inherit from Deoplete's Base class.
class Source(Base):
  def __init__(self, vim):
    # Configure the source.
    Base.__init__(self, vim)
    self.name = "conjure"
    self.filetypes = ['clojure']
    self.rank = 500

    # Store a reference to the vim API for later use.
    self.vim = vim

  def gather_candidates(self, context):
    if is_enabled:
      # Connect if we haven't already.
      if not hasattr(self, "sock"):
        # This call fetches the port for the JSON RPC TCP server. Acronyms!
        rpc_port = self.vim.api.call_function("conjure#get_rpc_port", [])

        # Create the socket and connect it to the RPC server.
        self.sock = socket.socket()
        self.sock.connect(("localhost", rpc_port))


      # Build a JSON RPC message with a new line at the end.
      # The 0 at the front indicates an RPC request.
      # The 1 is the request ID, you'll get that back in the response.
      # If you'll be running multiple requests in parallel you'll need to manage that ID!
      # "completions" is the RPC request we want to execute, checkout conjure.main to see them all.
      # The list on the end is the arguments you wish to give to the request.
      msg = json.dumps([0, 1, "completions", [context["complete_str"]]]) + "\n"

      # Send the JSON through the socket.
      self.sock.send(msg.encode())

      # Read a line from the socket.
      res = json.loads(self.sock.makefile().readline())

      # 0th index is the type of RPC message, should be 1 which is a response.
      # 1st index is the request ID from earlier, it'll be 1 in this case.
      # 2nd index is an error, if there was one (or null).
      # 3rd index is the result, for us that's the autocompletion esults.
      return res[3]
    else:
      return []
