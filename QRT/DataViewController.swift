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
    var power = "0"
    
    
    
    var objectData = ["Sun", "Moon", "Jupiter", "Mercury", "Venus", "Mars", "Saturn", "Uranus", "Neptune", "Pluto", "Phobos", "Deimos", "Io", "Europa", "Ganymede", "Callisto", "Mimas", "Enceladus", "Tethys", "Dione", "Rhea", "Titan", "Hyperion", "Ariel", "Umbriel", "Titania", "Oberon", "Miranda"]
    
    
    // called when login is successful
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sorts the lsit of objects
        objectData = objectData.sorted() { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

        print(session.checkConnection())
        print(session.checkAuthorization())
        
        // called to initialize values
        raDecTabButton()
        
        // keyboard dismisser
        let keyboardHide: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardHide))
        view.addGestureRecognizer(keyboardHide)
        
        //update data every second
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DataViewController.updateData), userInfo: nil, repeats: true)
        
        // immediately update data when view opens
        updateData()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////
    
    // POWER CONTROL //
    
    ///////////////////

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
    
    
    ///////////////////
    
    // MOTOR CONTROL //
    
    ///////////////////
    
    func getSelectedUnits() -> Int {
        return objectSegmentedController.selectedSegmentIndex
    }
    
    // checks to make sure the ra/dec values are satisfactory
    
    // temporarily deprecated as checking is handled entirely server-side -- may be reused
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
    
    var motorMessage = ""
    
    // sends command to Pi/Pyro to initiate scanning
    func motorScan() {
        /*if !checkMotorBoxes() {
            let alert = UIAlertController(title: "Enter a Number", message: "Please enter proper numbers in integer or decimal form in each field.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else */
        
        if getSelectedUnits() == 0 {
            let ra = getDecimalRaDec()[0]
            let dec = getDecimalRaDec()[1]
            motorMessage = session.sendCommandWithResponse("cd Documents/QRT-nonfunctional/software; python2.7 SSHtoPyroController.py " + String(ra) + " " + String(dec) + " raDecScan")
        } else if getSelectedUnits() == 1 {
            let alt = Double(text1.text!)!
            let az = Double(text4.text!)!
            motorMessage = session.sendCommandWithResponse("cd Documents/QRT-nonfunctional/software; python2.7 SSHtoPyroController.py " + String(alt) + " " + String(az) + " altAzPoint")
        } else if getSelectedUnits() == 2 {
            let in1 = Double(text1.text!)!
            let in2 = Double(text4.text!)!
            motorMessage = session.sendCommandWithResponse("cd Documents/QRT-nonfunctional/software; python2.7 SSHtoPyroController.py " + String(in1) + " " + String(in2) + " inchesPoint")
        } else if getSelectedUnits() == 3 {
            let ct1 = Double(text1.text!)!
            let ct2 = Double(text4.text!)!
            motorMessage = session.sendCommandWithResponse("cd Documents/QRT-nonfunctional/software; python2.7 SSHtoPyroController.py " + String(ct1) + " " + String(ct2) + " countsPoint")
        } else if getSelectedUnits() == 4 {
            let selectedObject = objectData[objectPicker.selectedRow(inComponent: 0)]
            motorMessage = session.sendCommandWithResponse("cd Documents/QRT-nonfunctional/software; python2.7 SSHtoPyroController.py " + selectedObject + " 0 objectScan")
        }
        
        if motorMessage != "" {
            let alert = UIAlertController(title: "Error from Server", message: motorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        motorMessage = ""
    }
    
    // sends command to Pi/Pyro to reset the motor's position
    func motorReset() {
        session.sendCommand("cd QRT/software; python2.7 SSHtoPyroController.py 0 0 reset")
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
    
    
    //////////////////
    
    // DATA CONTROL //
    
    //////////////////

    //outlets in data, fields
    
    @IBOutlet weak var dataPower: UILabel!
    @IBOutlet weak var dataTime: UILabel!
    @IBOutlet weak var dataMotorOne: UILabel!
    @IBOutlet weak var dataMotorTwo: UILabel!
    
    var time = "00:00:00"
    var hours = 0
    var mins = 0
    var secs = 0
    var m1extension = "0"
    var m2extension = "0"
    var hoursString = ""
    var minsString = ""
    var secsString = ""
    var intTime = 0
    
    // called by background thread to continuously update data fields
    // uses response to populate the data UILabels with some data
    func updateData(){
        let message = session.sendCommandWithResponse("cd Documents/QRT-nonfunctional/software; python2.7 SSHtoPyroController.py 0 0 getOutput")
        
        if message != "none" && message.characters.count < 64 && message != ""{
            print(message)
            var output = message.components(separatedBy: ";")
            print("output:")
            print(output)
            
            // last output comes out with some random-ish characters, this removes all the known possibilities of those characters
            output[output.count - 1] = output[output.count - 1].replacingOccurrences(of: "\r\n", with: "")
            output[output.count - 1] = output[output.count - 1].replacingOccurrences(of: "\n", with: "")
            output[output.count - 1] = output[output.count - 1].replacingOccurrences(of: "\r", with: "")
            
            // format the time
            print(Int(Double(output[0])!))
            intTime = Int(Double(output[0])!)
            hours = Int(intTime / 3600)
            if (hours < 10) {
                hoursString = "0" + String(hours)
            } else {
                hoursString = String(hours)
            }
            mins = Int(intTime / 60) % 60
            if (mins < 10) {
                minsString = "0" + String(mins)
            } else {
                minsString = String(mins)
            }
            secs = intTime % 60
            if (secs < 10) {
                secsString = "0" + String(secs)
            } else {
                secsString = String(secs)
            }
            time = hoursString + ":" + minsString + ":" + secsString
            
            // format the power
            power = output[1]
            
            // format motor 1 extension
            m1extension = String(Int(Double(output[2])!))
            
            // format motor 2 extension
            m2extension = String(Int(Double(output[3])!))
            
            
        } else {
            power = "NAN"
            time = "NAN"
            m1extension = "NAN"
            m2extension = "NAN"
        }
        
        dataPower.text = power
        dataTime.text = time
        dataMotorOne.text = m1extension
        dataMotorTwo.text = m2extension
    }
    
}
