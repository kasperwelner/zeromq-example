//
//  main.swift
//  zmqclient
//
//  Created by Kasper Welner on 07/08/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import CZeroMQ
import ZeroMQ

/* --- CLIENT --- */

func useSwiftAPI(portString:String) {
    do {
        let context = try Context()
        
        let outbound = try context.socket(.Req)
        try outbound.connect(portString)
        
        _ = try outbound.sendString("Hello")
        if let response = try outbound.receiveString() {
            print(response)
        }
    } catch {
        print(error)
    }
}

func useCAPI(portString:String) {
    let context = zmq_ctx_new()
    guard let requester = zmq_socket (context, ZMQ_REQ) else { perror("zmq_socket"); exit(1) }
    
    var optval = Int32(0)
    let optsize = sizeofValue(optval)
    if (zmq_setsockopt(requester, ZMQ_LINGER, &optval, optsize) == -1) {
        perror("setsockopt");
        exit(1);
    }
    
    let result = zmq_connect (requester, portString)
    if result != 0 {
        perror("zmq_connect")
        exit(1)
    }
    
    let res = zmq_send (requester, "Hello", 5, 0);
    if res == -1 {
        perror("zmq_send");
        sleep(1)
        exit(1)
    }
    let inString = Array(repeating: CChar(), count: 256)
    zmq_recv (requester, UnsafeMutablePointer<CChar>(inString), 256, 0);
    print("World");
    
    zmq_close (requester);
    zmq_ctx_destroy (context);
}

guard ProcessInfo.processInfo.arguments.count > 1 else { print("Please specify port");exit(1) }
let port = ProcessInfo.processInfo.arguments[1]
let portString = "tcp://127.0.0.1:\(port)"
print ("Connecting to server on \(portString)\n")
if ProcessInfo.processInfo.arguments.count > 2, let useC:String = ProcessInfo.processInfo.arguments.last, useC == "c" {
    print("Using legacy API")
    useCAPI(portString: portString)
} else {
    print("Using Swift API")
    useSwiftAPI(portString: portString)
}



