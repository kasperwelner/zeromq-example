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
import ZeroMQ

/* --- SERVER --- */

func useSwiftAPI(portString:String) {
    
    do {
        let context = try Context()
        
        let inbound = try context.socket(.Rep)
        try inbound.bind(portString)
        
        while let data = try inbound.receiveString() {
            print(data)
            _ = try inbound.sendString("World")
        }
    } catch {
        print(error)
    }
}

func useCAPI(portString:String) {
    
    //  Socket to talk to clients
    let context = zmq_ctx_new()
    let responder = zmq_socket (context, ZMQ_REP)
    var optval = Int32(2)
    var optsize = sizeofValue(optval)
    
    if (zmq_setsockopt(responder, ZMQ_LINGER, &optval, optsize) == -1) {
        perror("setsockopt");
        exit(1);
    }

    let rc = zmq_bind (responder, portString)
    if rc != 0 {
        perror("zmq_bind")
        exit(1)
    }
    
    func input() -> String {
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        return String(data: inputData, encoding:String.Encoding.utf8) ?? ""
    }
    
    while true {
        let buffer:Array<CChar> = Array(repeating: 32, count: 100)
        let bufferPointer = UnsafeMutablePointer<CChar>(buffer)
        zmq_recv (responder, bufferPointer, 10, 0)
        print ("Hello")
        zmq_send (responder, "World", 5, 0)
    }
}

guard ProcessInfo.processInfo.arguments.count > 1 else { print("Please specify port");exit(1) }
let port = ProcessInfo.processInfo.arguments[1]
let portString = "tcp://127.0.0.1:\(port)"
print ("Listening on \(portString)\n")
if ProcessInfo.processInfo.arguments.count > 2, let useC:String = ProcessInfo.processInfo.arguments.last, useC == "c" {
    print("Using legacy API")
    useCAPI(portString: portString)
} else {
    print("Using Swift API")
    useSwiftAPI(portString: portString)
}
