import zmq
socketContext = zmq.Context()
socket = socketContext.socket(zmq.REQ)
socket.connect("tcp://localhost:%s" % '5556')

socket.send_string("hello from python")
print(socket.recv_string())

