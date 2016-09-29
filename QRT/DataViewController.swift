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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class DataViewController: UIViewController {
    
    // different text fields for inputs
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    @IBOutlet weak var text4: UITextField!
    @IBOutlet weak var text5: UITextField!
    @IBOutlet weak var text6: UITextField!
    
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var text1units: UILabel!
    @IBOutlet weak var text2units: UILabel!
    @IBOutlet weak var text3units: UILabel!
    
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var text4units: UILabel!
    @IBOutlet weak var text5units: UILabel!
    @IBOutlet weak var text6units: UILabel!
    
    @IBOutlet weak var trackButton: UIButton!
    
    //picker view delegation
    @IBOutlet weak var objectPicker: UIPickerView!
    
    // fields for SSH session
    var session = SSHConnection.init()
    var username = ""
    var ip = ""
    var password = ""
    
    var objectData = ["Sun", "Moon", "Jupiter", "Mercury", "Venus", "Mars", "Saturn", "Uranus", "Neptune", "Pluto", "Phobos", "Deimos", "Io", "Europa", "Ganymede", "Callisto", "Mimas", "Enceladus", "Tethys", "Dione", "Rhea", "Titan", "Hyperion", "Ariel", "Umbriel", "Titania", "Oberon", "Miranda"]
    
    
    // called when login is successful
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectData = objectData.sorted() { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

        print(session.checkConnection())
        print(session.checkAuthorization())
        
        raDecTabButton()

        
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
    @IBAction func shutDown(_ sender: UIButton) {
        session.sendCommand("sudo shutdown now")
    }
    
    // called from reboot button
    @IBAction func restart(_ sender: UIButton) {
        session.sendCommand("sudo reboot now")
    }
    
    // called from command field info button
    @IBAction func sendCommandInfo(_ sender: UIButton) {
        let alert = UIAlertController(title: "Command Line", message: "Enter a command to send to the Pi via command line. Multiple separate commands must be separated by a semicolon.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field. Hours should be between 0 and 24; minutes and seconds should be between 0 and 60.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
    
    func getSelectedUnits() -> Int {
        return objectSegmentedController.selectedSegmentIndex
    }
    
    // checks to make sure the ra/dec values are satisfactory
    func checkMotorBoxes() -> Bool {
        if getSelectedUnits() == 0 { // radec
            let text1num = Double(text1.text!)
            let text2num = Double(text2.text!)
            let text3num = Double(text3.text!)
            let text4num = Double(text4.text!)
            let text5num = Double(text5.text!)
            let text6num = Double(text6.text!)
            
            if  (text1num != nil) && (text2num != nil) && (text3num != nil) &&  (text4num != nil) && (text5num != nil) && (text6num != nil) && (text1num >= 0 && text1num < 24) && (text2num >= 0 && text2num < 60) && (text3num >= 0 && text3num < 60) && (text4num >= 0 && text4num < 24) && (text5num >= 0 && text5num < 60) && (text6num >= 0 && text6num < 60){
                return true
            } else {
                return false
            }
        } else if getSelectedUnits() == 1 { // altaz
            let text1num = Double(text1.text!)
            let text4num = Double(text4.text!)
            if  (text1num != nil) &&  (text4num != nil) {
                return true
            } else {
                return false
            }
        } else if getSelectedUnits() == 2 { // inches
            let text1num = Double(text1.text!)
            let text4num = Double(text4.text!)
            if  (text1num != nil) &&  (text4num != nil) {
                return true
            } else {
                return false
            }
        } else if getSelectedUnits() == 3 { // counts
            let text1num = Double(text1.text!)
            let text4num = Double(text4.text!)
            if  (text1num != nil) &&  (text4num != nil) {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    //converts hr/min/sec to doubles
    func getDecimalRaDec() -> [Double]{
        let ra = Double(text1.text!)! + Double(text2.text!)!/60.0 + Double(text3.text!)!/3600.0
        let dec = Double(text4.text!)! + Double(text5.text!)!/60.0 + Double(text6.text!)!/3600.0
        return [ra, dec]
    }
    
    // sends command to Pi/Pyro to initiate scanning
    func motorScan() {
        if !checkMotorBoxes() {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if getSelectedUnits() == 0 {
            let ra = getDecimalRaDec()[0]
            let dec = getDecimalRaDec()[1]
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + String(ra) + " " + String(dec) + " raDecScan")
        } else if getSelectedUnits() == 1 {
            let alt = Double(text1.text!)!
            let az = Double(text4.text!)!
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + String(alt) + " " + String(az) + " altAzPoint")
        } else if getSelectedUnits() == 2 {
            let in1 = Double(text1.text!)!
            let in2 = Double(text4.text!)!
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + String(in1) + " " + String(in2) + " inchesPoint")
        } else if getSelectedUnits() == 3 {
            let ct1 = Double(text1.text!)!
            let ct2 = Double(text4.text!)!
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + String(ct1) + " " + String(ct2) + " countsPoint")
        } else if getSelectedUnits() == 4 {
            let selectedObject = objectData[objectPicker.selectedRow(inComponent: 0)]
            
            session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + selectedObject + " 0 objectScan")
        }
    }
    
    // sends command to Pi/Pyro to reset the motor's position
    func motorReset() {
        session.sendCommand("cd QRT/software; python SSHtoPyroController.py 0 0 reset")
    }
    
    
    @IBAction func sendMotor(_ sender: UIButton) {
        motorScan()
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        motorReset()
    }
    
    
    //handling of next buttons in each text field
    
    @IBAction func text1end(_ sender: UITextField) {
        text1.resignFirstResponder()
        if getSelectedUnits() == 0 {
            text2.becomeFirstResponder()
        } else {
            text4.becomeFirstResponder()
        }
    }
    
    @IBAction func text2end(_ sender: UITextField) {
        text2.resignFirstResponder()
        text3.becomeFirstResponder()
    }
    
    @IBAction func text3end(_ sender: UITextField) {
        text3.resignFirstResponder()
        text4.becomeFirstResponder()
    }
    
    @IBAction func text4end(_ sender: UITextField) {
        text4.resignFirstResponder()
        if getSelectedUnits() == 0 {
            text5.becomeFirstResponder()
        }
    }

    @IBAction func text5end(_ sender: UITextField) {
        text5.resignFirstResponder()
        text6.becomeFirstResponder()
    }
    
    @IBAction func text6end(_ sender: UITextField) {
        text6.resignFirstResponder()
    }
    
    
    
    // buttons below text fields to send commands to Pyro
    
    
    
    
    
    // provides info on how to operate the motor position
    @IBAction func motorInfoButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Set Motor Position", message: "Use this to control the telescope's motors. If the telescope does not move, check the Pyro console; it's likely that the position it is moving to is out of the motors' range.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    

    
    //returns number of columns in picker view (1)
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //returns numbers of items in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return objectData.count
    }
    
    //returns object currently picked
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return objectData[row]
    }
    
    // tracks an object based on the string
    func trackObject() {
        let selectedObject = objectData[objectPicker.selectedRow(inComponent: 0)]
        
        session.sendCommand("cd QRT/software; python SSHtoPyroController.py " + selectedObject + " 0 objectScan")
    }
    @IBOutlet weak var objectSegmentedController: UISegmentedControl!
    
    
    
    
    func raDecTabButton() {
        
        objectPicker.isHidden = true
        
        text1.resignFirstResponder()
        text2.resignFirstResponder()
        text3.resignFirstResponder()
        text4.resignFirstResponder()
        text5.resignFirstResponder()
        text6.resignFirstResponder()
        
        name1.isHidden = false
        name2.isHidden = false
        text1.isHidden = false
        text2.isHidden = false
        text3.isHidden = false
        text4.isHidden = false
        text5.isHidden = false
        text6.isHidden = false
        text1units.isHidden = false
        text2units.isHidden = false
        text3units.isHidden = false
        text4units.isHidden = false
        text5units.isHidden = false
        text6units.isHidden = false
        
        name1.text = "RA:"
        name2.text = "Dec:"
        text1units.text = "hr"
        text2units.text = "min"
        text3units.text = "sec"
        text4units.text = "hr"
        text5units.text = "min"
        text6units.text = "sec"
        
        text1.text = ""
        text2.text = ""
        text3.text = ""
        text4.text = ""
        text5.text = ""
        text6.text = ""
        
        trackButton.setTitle("Scan", for: .normal)
        
        text4.returnKeyType = UIReturnKeyType.next
        text6.returnKeyType = UIReturnKeyType.go
        
    }
    
    
    func altAzTabButton() {
        
        objectPicker.isHidden = true
        
        text1.resignFirstResponder()
        text2.resignFirstResponder()
        text3.resignFirstResponder()
        text4.resignFirstResponder()
        text5.resignFirstResponder()
        text6.resignFirstResponder()
        
        name1.isHidden = false
        name2.isHidden = false
        text1.isHidden = false
        text2.isHidden = true
        text3.isHidden = true
        text4.isHidden = false
        text5.isHidden = true
        text6.isHidden = true
        text1units.isHidden = false
        text2units.isHidden = true
        text3units.isHidden = true
        text4units.isHidden = false
        text5units.isHidden = true
        text6units.isHidden = true
        
        name1.text = "Altitude:"
        name2.text = "Azimuth:"
        text1units.text = "\u{00B0}"
        text4units.text = "\u{00B0}"
        
        text1.text = ""
        text2.text = ""
        text3.text = ""
        text4.text = ""
        text5.text = ""
        text6.text = ""
        
        trackButton.setTitle("Move", for: .normal)
        
        text4.returnKeyType = UIReturnKeyType.go

    }
    
    func inchesTabButton() {
        
        objectPicker.isHidden = true
        
        text1.resignFirstResponder()
        text2.resignFirstResponder()
        text3.resignFirstResponder()
        text4.resignFirstResponder()
        text5.resignFirstResponder()
        text6.resignFirstResponder()
        
        name1.isHidden = false
        name2.isHidden = false
        text1.isHidden = false
        text2.isHidden = true
        text3.isHidden = true
        text4.isHidden = false
        text5.isHidden = true
        text6.isHidden = true
        text1units.isHidden = false
        text2units.isHidden = true
        text3units.isHidden = true
        text4units.isHidden = false
        text5units.isHidden = true
        text6units.isHidden = true
        
        name1.text = "Motor 1:"
        name2.text = "Motor 2:"
        text1units.text = "inches"
        text4units.text = "inches"
        
        text1.text = ""
        text2.text = ""
        text3.text = ""
        text4.text = ""
        text5.text = ""
        text6.text = ""
        
        trackButton.setTitle("Move", for: .normal)
        
        text4.returnKeyType = UIReturnKeyType.go
        
    }
    
    func countsTabButton() {
        
        objectPicker.isHidden = true
        
        text1.resignFirstResponder()
        text2.resignFirstResponder()
        text3.resignFirstResponder()
        text4.resignFirstResponder()
        text5.resignFirstResponder()
        text6.resignFirstResponder()
        
        name1.isHidden = false
        name2.isHidden = false
        text1.isHidden = false
        text2.isHidden = true
        text3.isHidden = true
        text4.isHidden = false
        text5.isHidden = true
        text6.isHidden = true
        text1units.isHidden = false
        text2units.isHidden = true
        text3units.isHidden = true
        text4units.isHidden = false
        text5units.isHidden = true
        text6units.isHidden = true
        
        name1.text = "Motor 1:"
        name2.text = "Motor 2:"
        text1units.text = "counts"
        text4units.text = "counts"
        
        text1.text = ""
        text2.text = ""
        text3.text = ""
        text4.text = ""
        text5.text = ""
        text6.text = ""
        
        trackButton.setTitle("Move", for: .normal)
        
        text4.returnKeyType = UIReturnKeyType.go
        
    }
    
    func bodyTabButton() {
        
        objectPicker.isHidden = false
        
        text1.resignFirstResponder()
        text2.resignFirstResponder()
        text3.resignFirstResponder()
        text4.resignFirstResponder()
        text5.resignFirstResponder()
        text6.resignFirstResponder()
        
        name1.isHidden = true
        name2.isHidden = true
        text1.isHidden = true
        text2.isHidden = true
        text3.isHidden = true
        text4.isHidden = true
        text5.isHidden = true
        text6.isHidden = true
        text1units.isHidden = true
        text2units.isHidden = true
        text3units.isHidden = true
        text4units.isHidden = true
        text5units.isHidden = true
        text6units.isHidden = true
        
        trackButton.setTitle("Scan", for: .normal)

    }
    
    @IBAction func valueSelected(_ sender: UISegmentedControl) {
        if objectSegmentedController.selectedSegmentIndex == 0 {
            raDecTabButton()
        } else if objectSegmentedController.selectedSegmentIndex == 1 {
            altAzTabButton()
        } else if objectSegmentedController.selectedSegmentIndex == 2 {
            inchesTabButton()
        } else if objectSegmentedController.selectedSegmentIndex == 3 {
            countsTabButton()
        } else if objectSegmentedController.selectedSegmentIndex == 4 {
            bodyTabButton()
        }
    }
    
    
    
    
    // button to the right of the object picker
    @IBAction func trackObjectButton(_ sender: UIButton) {
        trackObject()
    }
    
    
    // function called when keyboard is dismissed
    func keyboardHide() {
        view.endEditing(true)
    }
    
}

