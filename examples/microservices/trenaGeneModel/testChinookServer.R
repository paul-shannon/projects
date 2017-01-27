library(RUnit)
library(rzmq)
library(jsonlite)
#------------------------------------------------------------------------------------------------------------------------
context = init.context()
socket = init.socket(context,"ZMQ_REQ")
connect.socket(socket,"tcp://localhost:5557")
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
    test_ping()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
test_ping <- function()
{
   msg = list(cmd="ping", status="request", callback="", payload="");
   msg.json <- toJSON(msg)
   send.raw.string(socket, msg.json)
   response <- fromJSON(receive.string(socket))
   checkEquals(response$payload, "pong")

} # test_ping
#------------------------------------------------------------------------------------------------------------------------
test_createGeneModel <- function()
{
   msg = list(cmd="createGeneModel", status="request", callback="",
               payload=list(targetGene="VGF", footprintRegion="7:101,165,577-101,165,615"))
   msg.json <- toJSON(msg)
   send.raw.string(socket, msg.json)
   response <- fromJSON(receive.string(socket))
   checkEquals(response$payload, "pong")


} # test_createGeneModel
#------------------------------------------------------------------------------------------------------------------------
