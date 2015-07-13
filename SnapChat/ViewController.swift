//
//  ViewController.swift
//  SnapChat
//
//  Created by Mac on 09/07/15.
//  Copyright (c) 2015 cz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBAction func signIn(sender: AnyObject) {
        
        //parse signing in Users
        
        PFUser.logInWithUsernameInBackground(username.text, password: "mypass") {                    (user: PFUser?, signupError: NSError?) -> Void in
            if user != nil {
                
                println("logged in")
                
                self.performSegueWithIdentifier("showUsers", sender: self)
                
            
            } else {
            
                
                var user = PFUser()
                user.username = self.username.text
                user.password = "mypass"
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        println("signedup")
                        self.performSegueWithIdentifier("showUsers", sender: self)
                        
                    } else {
                    println(error)
                    }
                }
            
            }
        
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
        self.performSegueWithIdentifier("showUsers", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

