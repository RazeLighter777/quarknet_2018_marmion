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

class DataViewController: UIViewController {
    
    // fields for SSH session
    var session = SSHConnection.init()
    var username = ""
    var ip = ""
    var password = ""
    
    
    
    // called when login is successful
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    
    // POWER MENU

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
    
    
    
    // SEND COMMAND FIELD: REMOVED
    
    /*
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
    */
    
    
    
    // MOTOR CONTROLLER
    
    // sends command to Pi/Pyro to set the motor length
    func sendMotorLength() {
        
        
        if !checkMotorBoxes() {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else  {
            let ra = getDecimalRaDec()[0]
            let dec = getDecimalRaDec()[1]
            session.sendCommand("cd QRT/software; python setRaDecSSH.py " + String(ra) + " " + String(dec) + " 1")
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
    
    func checkMotorBoxes() -> Bool {
        let RaHrNum = Double(RaHr.text!)
        let RaMinNum = Double(RaMin.text!)
        let RaSecNum = Double(RaSec.text!)
        let DecHrNum = Double(DecHr.text!)
        let DecMinNum = Double(DecMin.text!)
        let DecSecNum = Double(DecSec.text!)
        
        if  (RaHrNum != nil) && (RaMinNum != nil) && (RaSecNum != nil) &&  (DecHrNum != nil) && (DecMinNum != nil) && (DecSecNum != nil) && (RaHrNum >= 0 && RaHrNum < 24) && (RaMinNum >= 0 && RaMinNum < 60) && (RaSecNum >= 0 && RaSecNum < 60) && (DecHrNum >= 0 && DecHrNum < 24) && (DecMinNum >= 0 && DecMinNum < 60) && (DecSecNum >= 0 && DecSecNum < 60){
            return true
        } else {
            return false
        }
    }
    
    func getDecimalRaDec() -> [Double]{
        let ra = Double(RaHr.text!)! + Double(RaMin.text!)!/60.0 + Double(RaSec.text!)!/3600.0
        let dec = Double(DecHr.text!)! + Double(DecMin.text!)!/60.0 + Double(DecSec.text!)!/3600.0
        return [ra, dec]
    }
    
    // sends command to Pi/Pyro to initiate scanning
    func motorScan() {
        
        
        if !checkMotorBoxes() {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let ra = getDecimalRaDec()[0]
            let dec = getDecimalRaDec()[1]
            session.sendCommand("cd QRT/software; python setRaDecSSH.py " + String(ra) + " " + String(dec) + " 3")
        }
    }
    
    // sends command to Pi/Pyro to reset the motor's position
    func motorReset() {
        session.sendCommand("cd QRT/software; python setRaDecSSH.py 0 0 2")
    }
    
    // different text fields for RA/Dec inputs
    @IBOutlet weak var RaHr: UITextField!
    @IBOutlet weak var RaMin: UITextField!
    @IBOutlet weak var RaSec: UITextField!
    @IBOutlet weak var DecHr: UITextField!
    @IBOutlet weak var DecMin: UITextField!
    @IBOutlet weak var DecSec: UITextField!
    
    @IBAction func RaHrToRaMin(sender: UITextField) {
        RaHr.resignFirstResponder()
        RaMin.becomeFirstResponder()
    }
    
    @IBAction func RaMinToRaSec(sender: UITextField) {
        RaMin.resignFirstResponder()
        RaSec.becomeFirstResponder()
    }
    
    @IBAction func RaSecToDecHr(sender: UITextField) {
        RaSec.resignFirstResponder()
        DecHr.becomeFirstResponder()
    }
    
    @IBAction func DecHrToDecMin(sender: UITextField) {
        DecHr.resignFirstResponder()
        DecMin.becomeFirstResponder()
    }
    
    @IBAction func DecMinToDecSec(sender: UITextField) {
        DecMin.resignFirstResponder()
        DecSec.becomeFirstResponder()
    }
    
    
    @IBAction func DecSecDisappear(sender: UITextField) {
        DecSec.resignFirstResponder()
    }
    
    // buttons below text fields to send commands to Pyro
    
    
    @IBAction func motorControlSend(sender: UIButton) {
        sendMotorLength()
    }
    
    @IBAction func positionResetPressed(sender: UIButton) {
        motorReset()
    }
    
    @IBAction func scanPressed(sender: UIButton) {
        motorScan()
    }
    
    
    
    // provides info on how to operate the motor position
    @IBAction func motorInfoButton(sender: UIButton) {
        let alert = UIAlertController(title: "Set Motor Position", message: "Set an RA/Dec coordinate to point the telescope to. If the coordinate is out of the telescope's range of motion, the telescope will not move. Using scan sets the telescope to track the object.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func scanButton(sender: UIButton) {
        motorScan()
        sleep(5)
        session.resetConnection()
    }
    
    
    
    // function called when keyboard is dismissed
    func keyboardHide() {
        view.endEditing(true)
    }
    
}

