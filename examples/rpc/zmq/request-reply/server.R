library(rzmq)
library(jsonlite)
context = init.context()
socket = init.socket(context,"ZMQ_REP")
bind.socket(socket,"tcp://*:5556")

while(TRUE) {
  printf("top of receive/send loop")
  request = receive.string(socket)
  printf("class of request: %s", class(request))
  response <- toupper(request)
  send.raw.string(socket, response)
  Sys.sleep(1)
  }
