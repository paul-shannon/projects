import zmq
import json
socketContext = zmq.Context()
socket = socketContext.socket(zmq.REQ)
socket.connect("tcp://localhost:%s" % '5557')

msg = {"cmd": "ping", "status": "request", "callback": "", "payload": ""}
msg_json = json.dumps(msg)
socket.send_string(msg_json)
print(json.loads(socket.recv_string()))

