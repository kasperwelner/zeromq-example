//
//  main.swift
//  zmqclient
//
//  Created by Kasper Welner on 07/08/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

import Foundation
import CZeroMQ
import Darwin.C

let context = zmq_ctx_new()
guard let requester = zmq_socket (context, ZMQ_REQ) else { perror("zmq_socket"); exit(1) }
/*
var optval = Int32(0)
var optsize = sizeofValue(optval)
if (zmq_setsockopt(requester, ZMQ_LINGER, &optval, optsize) == -1) {
    perror("setsockopt");
    exit(1);
}
 */
guard Process.arguments.count > 1, let port = Process.arguments.last else { print("Please specify port");exit(1) }
let portString = "tcp://127.0.0.1:\(port)"
print ("Connecting to hello world server on \(portString)\n")
portString.withCString { pointer in
    
    let result = zmq_connect (requester, pointer)
    if result != 0 {
        perror("zmq_connect")
        exit(1)
    }
}

for i in 0..<10 {
    print("Sending Hello \(i)…\n")
    let res = zmq_send (requester, "Hello", 5, 0);
    if res == -1 {
        perror("zmq_send");
        sleep(1)
        break
    }
    print("Waiting for response...")
    var inString = Array(repeating: CChar(), count: 256)
    zmq_recv (requester, UnsafeMutablePointer<CChar>(inString), 256, 0);
    print("Received World \(i): \(String(inString))\n", i);
}

zmq_close (requester);
zmq_ctx_destroy (context);




