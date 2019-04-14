from .base import Base
import deoplete.logger
import socket
import json

# Create a class to perform completions, inherit from Deoplete's Base class.
class Source(Base):
  def __init__(self, vim):
    # Setup the source, we rank it highly so it appears above other results.
    Base.__init__(self, vim)
    self.name = "conjure"
    self.filetypes = ['clojure']
    self.rank = 500

  def on_init(self, context):
    # I _think_ init is when you're in a Clojure file, so we defer connecting
    # until the user wants to edit some Clojure.

    # This call fetches the port for the JSON RPC TCP server. Acronyms!
    rpc_port = vim.api.call_function("conjure#get_rpc_port", [])

    # Create the socket and connect it to the RPC server.
    self.sock = socket.socket()
    self.sock.connect(("localhost", rpc_port))

  def gather_candidates(self, context):
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
