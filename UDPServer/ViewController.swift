//
//  ViewController.swift
//  UDPServer
//
//  Created by Stanislav Sidelnikov on 17/02/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

class ViewController: NSViewController, GCDAsyncUdpSocketDelegate {
    private var _socket: GCDAsyncUdpSocket?
    
    private var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                _socket = getNewSocket()
            }
            return _socket
        }
        set {
            if _socket != nil {
                _socket?.close()
            }
            _socket = newValue
        }
    }

    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet var infoTextView: NSTextView!
    
    private func getNewSocket() -> GCDAsyncUdpSocket? {
        let port = UInt16(self.portTextField.integerValue)
        guard port > 0 else {
            return nil
        }
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try sock.bindToPort(port)
            try sock.enableBroadcast(true)
        } catch _ as NSError {
            self.log(">>>Issue with setting up listener")
            return nil
        }
        return sock
    }
    
    @IBAction func portChanged(sender: NSTextField) {
        socket = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startServer(sender: AnyObject) {
        guard portTextField.intValue > 0 else {
            return
        }
        do {
            try socket?.beginReceiving()
        } catch _ as NSError {
            print("Issue starting listener")
            return
        }
        setControlsStateCanStartServer(false)
        
        log(">> Server started")

    }
    
    private func log(text: String) {
        let trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        infoTextView.textStorage?.appendAttributedString(NSAttributedString(string: "\(trimmedText)\n"))
    }
    
    private func setControlsStateCanStartServer(canStart: Bool) {
        startButton.enabled = canStart
        stopButton.enabled = !canStart
        portTextField.enabled = canStart
    }

    @IBAction func stopServer(sender: AnyObject) {
        if socket != nil {
            socket?.pauseReceiving()
            setControlsStateCanStartServer(true)
            log(">> Server stopped")
        }

    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        var response = "No data recieved"
        if let str = NSString(data: data, encoding: NSUTF8StringEncoding) {
            log("Received: \(str)")
            response = "You sent: \(str)"
        }
    sock.sendData(response.dataUsingEncoding(NSUTF8StringEncoding), toAddress: address, withTimeout: 2, tag: 0)
        log("Sent: \(response)")
    }

}

