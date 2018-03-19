#!/usr/bin/env python3

from autobahn.asyncio.websocket import WebSocketServerProtocol
from autobahn.asyncio.websocket import WebSocketServerFactory
import asyncio
import time

class MyServerProtocol(WebSocketServerProtocol):
    
    def onConnect(self, request):
        print("Client connecting: {}".format(request.peer))
    
    def onOpen(self):
        print("WebSocket connection open.")
    
    def onMessage(self, payload, isBinary):
        if isBinary:
            print("Binary message received: {} bytes".format(len(payload)))
        else:
            print("Text message received: {}".format(payload.decode('utf8')))
        # just discard the data
        
        # add some delay to simulate slow network
        time.sleep(0.200)
    
    def onClose(self, wasClean, code, reason):
        print("WebSocket connection closed: {}".format(reason))

if __name__ == "__main__":
    factory = WebSocketServerFactory()
    factory.protocol = MyServerProtocol

    print("starting server")
    loop = asyncio.get_event_loop()
    coro = loop.create_server(factory, '0.0.0.0', 8888)
    server = loop.run_until_complete(coro)
    
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.close()
        loop.close()

