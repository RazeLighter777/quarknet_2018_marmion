//
//  LoginViewController.swift
//  QRT
//
//  Class that controls the view of the login screen. Creates an SSH connection then hands it to the next view controller.
//
//  Created by Lucas McDonald on 7/22/16.
//  Copyright © 2016 Lucas McDonald. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {
    
    // dummy variable for class scopae
    var session = SSHConnection.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call last successful login info for easier login
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if !(userDefaults.valueForKey("userKey") == nil) {
            usernameField.text = userDefaults.stringForKey("userKey")
            ipField.text = userDefaults.stringForKey("ipKey")
            passwordField.text = userDefaults.stringForKey("passKey")
            
        }
        
        // keyboard dismisser
        let keyboardHide: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        view.addGestureRecognizer(keyboardHide)
    }
        
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func usernameDisappear(sender: UITextField) {
        usernameField.resignFirstResponder()
    }
    
    @IBOutlet weak var ipField: UITextField!
    
    @IBAction func ipDisappear(sender: UITextField) {
        ipField.resignFirstResponder()
    }
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func passwordDisappear(sender: UITextField) {
        passwordField.resignFirstResponder()
    }
    
    // next button between username field and ip field
    @IBAction func userToIP(sender: UITextField) {
        usernameField.resignFirstResponder()
        ipField.becomeFirstResponder()
    }
    
    // next button between ip field and password field
    @IBAction func ipToPassword(sender: UITextField) {
        ipField.resignFirstResponder()
        passwordField.becomeFirstResponder()
    }

    
    // called when the user attempts to login with the entered information
    func attemptLogin(){
        
        // initializes session with new info
        session = SSHConnection.init(username: usernameField.text!, ip: ipField.text!, password: passwordField.text!, connect: true)
        
        // checks if connection was successful
        if session.checkConnection(){
            //checks if password authentication was successful
            if session.checkAuthorization() {
                
                // store login info for next time
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(usernameField.text, forKey: "userKey")
                userDefaults.setValue(ipField.text, forKey: "ipKey")
                userDefaults.setValue(passwordField.text, forKey: "passKey")
                userDefaults.synchronize()
                
                // switch view to DataViewController
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let menu = storyBoard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
                
                // give DataVC the data it needs to reinitialize the ssh connection
                menu.username = self.usernameField.text!
                menu.ip = self.ipField.text!
                menu.password = self.passwordField.text!
                self.presentViewController(menu, animated:true, completion:nil)
                

            } else {
                // case for correct login information but incorrect password
                let alert = UIAlertController(title: "Incorrect Password", message: "Connected to the Pi properly, but with an incorrect password.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            // case for incorrect login information
            let alert = UIAlertController(title: "Connection Failed", message: "Failed to connect to the Pi. Your username/IP may be wrong or the Pi may be offline.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    // called from passwordfield's go button
    @IBAction func loginFromGoKeyboard(sender: AnyObject) {
        attemptLogin()
    }

    // called from the login button on the screen
    @IBAction func loginButton(sender: UIButton) {
        attemptLogin()
    }
    
    
    func keyboardHide() {
        view.endEditing(true)
    }
}