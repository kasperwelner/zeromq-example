//
//  main.swift
//  zeromqcli
//
//  Created by Kasper Welner on 07/08/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import CZeroMQ
import Darwin.C
import Dispatch

//  Socket to talk to clients
let context = zmq_ctx_new()
let responder = zmq_socket (context, ZMQ_REP)
var optval = Int32(2)
var optsize = sizeofValue(optval)

if (zmq_setsockopt(responder, ZMQ_LINGER, &optval, optsize) == -1) {
    perror("setsockopt");
    exit(1);
}
guard Process.arguments.count > 1, let port = Process.arguments.last else { print("Please specify port");exit(1) }
let portString = "tcp://127.0.0.1:\(port)"

portString.withCString { pointer in
    let rc = zmq_bind (responder, pointer)
    if rc != 0 {
        perror("zmq_bind")
        exit(1)
    }
}

func input() -> String {
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    return String(data: inputData, encoding:String.Encoding.utf8) ?? ""
}

print("Listening on \(portString)")

while input() == "" {
    var buffer:Array<CChar> = Array(repeating: 32, count: 100)
    var bufferPointer = UnsafeMutablePointer<CChar>(buffer)
    zmq_recv (responder, bufferPointer, 10, 0)
    print ("Received Hello\n")
    sleep (1)          //  Do some 'work'
    zmq_send (responder, "World", 5, 0)
}

zmq_close(responder)
zmq_ctx_destroy(context)
