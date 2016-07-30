//
//  DataViewController.swift
//  QRT
//
//  Class that controls the control menu view controller.
//
//  Created by Lucas McDonald on 7/22/16.
//  Copyright © 2016 Lucas McDonald. All rights reserved.
//

import UIKit
import Foundation

class DataViewController: UIViewController, UIScrollViewDelegate{
    
    // variables to have entire scope of class
    var session = SSHConnection.init()
    var username = ""
    var ip = ""
    var password = ""
    
    var scrollView: UIScrollView!
    var containerView = UIView()

    // called when login is successful
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // recreates ssh session from login screen
        session = SSHConnection.init(username: username, ip: ip, password: password, connect: true)
        print(session.checkConnection())
        print(session.checkAuthorization())

        
        // keyboard dismisser
        let keyboardHide: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardHide))
        view.addGestureRecognizer(keyboardHide)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // called from shutdown button
    @IBAction func shutDown(sender: UIButton) {
        session.sendCommand("sudo shutdown now")
    }
    
    // called from reboot button
    @IBAction func restart(sender: UIButton) {
        session.sendCommand("sudo reboot now")
    }
    
    // called from command field info button
    @IBAction func sendCommandInfo(sender: UIButton) {
        let alert = UIAlertController(title: "Command Line", message: "Enter a command to send to the Pi via command line. Multiple separate commands must be separated by a semicolon.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // command field text field
    @IBOutlet weak var sendCommandField: UITextField!
    
    // send command from keyboard
    @IBAction func sendCommandBox(sender: UITextField) {
        session.sendCommand(sendCommandField.text!)
    }
    
    // send command from send button
    @IBAction func sendCommandButton(sender: UIButton) {
        session.sendCommand(sendCommandField.text!)
        print(session.returnSSHOutput())
    }
    
    func sendMotorLength() {
        if Double(motorOneText.text!) == nil || Double(motorTwoText.text!) == nil || motorOneText.text! == "" || motorTwoText.text == "" {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter a number in integer or decimal form in each field.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if Double(motorOneText.text!)! >= 0 && Double(motorTwoText.text!)! >= 0 {
            session.sendCommand("cd Desktop; python setRaDecSSH.py " + motorOneText.text! + " " + motorTwoText.text! + " 1")
        }
        
        /* attempts were made to give a message stating that the RA/DEC is too high; attempts will be made later
            
         else if !(Int(motorOneText.text!)! >= 0 && Int(motorOneText.text!)! <= 1340) {
            let alert = UIAlertController(title: "Motor 1 Error", message: "The Right Ascension value is too large for the motor.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if !(Int(motorTwoText.text!)! >= 0 && Int(motorTwoText.text!)! <= 670) {
            let alert = UIAlertController(title: "Motor 2 Error", message: "The declination value is too large for the motor.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        */
    }
    
    func motorScan() {
        if Double(motorOneText.text!) == nil || Double(motorTwoText.text!) == nil || motorOneText.text! == "" || motorTwoText.text == "" {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter a number in integer or decimal form in each field.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if Double(motorOneText.text!)! >= 0 && Double(motorTwoText.text!)! >= 0 {
            session.sendCommand("cd Desktop; python setRaDecSSH.py " + motorOneText.text! + " " + motorTwoText.text! + " 3")
        }
    }
    
    func motorReset() {
        session.sendCommand("cd Desktop; python setRaDecSSH.py 1 1 2")
    }
    
    @IBOutlet weak var motorOneText: UITextField!
    
    @IBAction func motorOneDisappear(sender: UITextField) {
        motorOneText.resignFirstResponder()
    }
    
    @IBOutlet weak var motorTwoText: UITextField!
    
    
    @IBAction func motorTwoDisappear(sender: UITextField) {
        motorTwoText.resignFirstResponder()
    }
    
    @IBAction func motorOneNext(sender: UITextField) {
        motorOneText.resignFirstResponder()
        motorTwoText.becomeFirstResponder()
    }
    
    @IBAction func motorTwoGo(sender: UITextField) {
        sendMotorLength()
    }
    @IBAction func motorControlSend(sender: UIButton) {
        sendMotorLength()
    }
    
    @IBAction func positionResetPressed(sender: UIButton) {
        motorReset()
    }
    
    
    
    @IBAction func motorInfoButton(sender: UIButton) {
        let alert = UIAlertController(title: "Set Motor Position", message: "Set an RA/Dec coordinate to point the telescope to. If the coordinate is out of the telescope's range of motion, the telescope will not move. Using scan sets the telescope to track the object.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func scanButton(sender: UIButton) {
        motorScan()
    }
    
    
    
    // function called when keyboard is dismissed
    func keyboardHide() {
        view.endEditing(true)
    }
    
}

