//
//  SSHConnection.swift
//  QRT
//
//  Class that adds a bit more utility to the NMSSH framework for the QRT controller's usage.
//
//  Created by Lucas McDonald on 7/23/16.
//  Copyright © 2016 Lucas McDonald. All rights reserved.
//

import Foundation
import UIKit

class SSHConnection {
    
    // create an NMSSHSession for use by the class and various data fields
    var NMsession = NMSSHSession(host: "", andUsername: "")
    var username = ""
    var ip = ""
    var password = ""
    
    // login with username, ip, and password. if connect is true, a login will be attempted. if connect is false, the login will not be attempted.
    init (username: String, ip: String, password: String, connect: Bool) {
        // store data for access
        self.username = username
        self.ip = ip
        self.password = password
        
        // define and connect to session
        self.NMsession = NMSSHSession(host: self.ip, andUsername: self.username)
        
        // attempt connection if connect is true
        if connect == true {
            NMsession?.connect()
            if (self.checkConnection()) {
                NMsession?.authenticate(byPassword: self.password)
            }
        }
        
    }
    
    
    // constructor for dummy variables
    init () {
        NMsession = NMSSHSession(host: "", andUsername: "")
    }
    
    // reconnect to the session; currently unused
    func reconnect(){
        NMsession = NMSSHSession(host: self.ip, andUsername: self.username)
        NMsession?.connect()
        NMsession?.authenticate(byPassword: self.password)
    }
    
    // check the connection
    func checkConnection() -> Bool {
        //cases for handling login errors/successes
        if NMsession?.isConnected == true {
            return true
        } else {
            return false
        }
    }
    
    // check if connection is password-authorized
    func checkAuthorization() -> Bool {
        if NMsession?.isAuthorized == true {
            return true
        } else {
            return false
        }
    }
    
    // send an SSH command; print output, but otherwise essentially ignore it
    func sendCommand(_ command: String) {
        if self.checkAuthorization() {
            let errorOut:NSErrorPointer = nil
            print(NMsession?.channel.execute(command, error: errorOut, timeout: 2)! as Any)
        }
    }
    
    // send SSH command; output response from terminal
    func sendCommandWithResponse(_ command: String) -> String {
        var message = "none"
        if self.checkConnection() {
            let errorOut:NSErrorPointer = nil
            message = (NMsession?.channel.execute(command, error: errorOut, timeout: 5))!
        }
        return message
    }
    
    
    // resets the connection (if a command runs too long, timed checks to see if connection has changed, etc.)
    // may be used to support background multitasking in the future
    func resetConnection(){
        NMsession?.disconnect()
        NMsession?.connect()
    }


    
}
