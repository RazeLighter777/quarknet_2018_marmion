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
    
    var objectData = ["Sun", "Moon", "Jupiter", "Mercury", "Venus", "Mars", "Saturn", "Uranus", "Neptune", "Pluto", "Phobos", "Deimos", "Io", "Europa", "Ganymede", "Callisto", "Mimas", "Enceladus", "Tethys", "Dione", "Rhea", "Titan", "Hyperion", "Ariel", "Umbriel", "Titania", "Oberon", "Miranda"]
    
    
    // called when login is successful
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectData = objectData.sort() { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }

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
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field. Hours should be between 0 and 24; minutes and seconds should be between 0 and 60.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else  {
            let ra = getDecimalRaDec()[0]
            let dec = getDecimalRaDec()[1]
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + String(ra) + " " + String(dec) + " control")
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
    
    // checks to make sure the ra/dec values are satisfactory
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
    
    //converts hr/min/sec to doubles
    func getDecimalRaDec() -> [Double]{
        let ra = Double(RaHr.text!)! + Double(RaMin.text!)!/60.0 + Double(RaSec.text!)!/3600.0
        let dec = Double(DecHr.text!)! + Double(DecMin.text!)!/60.0 + Double(DecSec.text!)!/3600.0
        return [ra, dec]
    }
    
    // sends command to Pi/Pyro to initiate scanning
    func motorScan() {
        
        
        if !checkMotorBoxes() {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field. Hours should be between 0 and 24; minutes and seconds should be between 0 and 60.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let ra = getDecimalRaDec()[0]
            let dec = getDecimalRaDec()[1]
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + String(ra) + " " + String(dec) + " radecScan")
        }
    }
    
    // sends command to Pi/Pyro to reset the motor's position
    func motorReset() {
        session.sendCommand("cd QRT/software; python SSHtoPyroController.py 0 0 reset")
    }
    
    // different text fields for RA/Dec inputs
    @IBOutlet weak var RaHr: UITextField!
    @IBOutlet weak var RaMin: UITextField!
    @IBOutlet weak var RaSec: UITextField!
    @IBOutlet weak var DecHr: UITextField!
    @IBOutlet weak var DecMin: UITextField!
    @IBOutlet weak var DecSec: UITextField!
    
    //handling of next buttons in each text field
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
        motorScan()
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
        let alert = UIAlertController(title: "Set Motor Position", message: "To control the telescope, either set an RA/Dec coordinate for it to scan or select a body for it to track. If the telescope does not move, it is likely that the body is outside of the motors' range of motion.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // send radec to scan
    @IBAction func scanButton(sender: UIButton) {
        motorScan()
        sleep(5)
        session.resetConnection()
    }
    
    //picker view delegation
    @IBOutlet weak var objectPicker: UIPickerView!
    
    //returns number of columns in picker view (1)
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //returns numbers of items in picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return objectData.count
    }
    
    //returns object currently picked
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return objectData[row]
    }
    
    // tracks an object based on the string
    func trackObject() {
        let selectedObject = objectData[objectPicker.selectedRowInComponent(0)]
        
        session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + selectedObject + " 0 objectScan")
    }
    
    // button to the right of the object picker
    @IBAction func trackObjectButton(sender: UIButton) {
        trackObject()
    }
    
    
    // function called when keyboard is dismissed
    func keyboardHide() {
        view.endEditing(true)
    }
    
}

