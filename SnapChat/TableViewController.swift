//
//  TableViewController.swift
//  SnapChat
//
//  Created by Mac on 09/07/15.
//  Copyright (c) 2015 cz. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var myTableview: UITableView!
    var userArray: [String] = []
    
    var activeRecipient = 0
    
    var timer = NSTimer()
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("Image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Upload to Parse
        
        var imageToSend = PFObject(className:"image")
        
        imageToSend["photo"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))
        imageToSend["senderUsername"] = PFUser.currentUser()!.username
        imageToSend["recipientUsername"] = userArray[activeRecipient]
        imageToSend.save()
        
        
        
    }
    
    @IBAction func pickImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        
        
        
        //var users = query!.findObjects()
        
        query!.findObjectsInBackgroundWithBlock {
        (users: [AnyObject]?, error: NSError?) -> Void in
        
        if error == nil {
        // The find succeeded.
        println("Successfully retrieved \(users!.count) users.")
        // Do something with the found objects
        if let users = users as? [PFObject] {
        for user in users {
        var names = user["username"] as! NSString
            
            self.userArray.append(names as String)
            
            //self.userArray.append(user["username"])
            
            self.myTableview.reloadData()
        }
        }
        } else {
        // Log details of the failure
        println("Error: \(error!) \(error!.userInfo!)")
        }
        }

        
        /*for user in users {
            
            println(user.username)
        
            
        }*/
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: true)
        
    }
    
    func checkForMessage() {
        
        println("checking for message...")
        
        var query = PFQuery(className: "image")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        //var images = query.findObjects()
        
        var done = false
        
        query.findObjectsInBackgroundWithBlock {
            (images: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(images!.count) images.")
                // Do something with the found objects
                if let images = images as? [PFObject] {
                    for image in images {
                        println(image.objectId)
                        
                        if done == false {
                            
                            var imageView:PFImageView = PFImageView()
                            imageView.file = image["photo"] as? PFFile
                            imageView.loadInBackground({ (photo, error) -> Void in
                                
                                if error == nil {
                                    
                                    var senderUsername = ""
                                    
                                    if image["senderUsername"] != nil {
                                        
                                        senderUsername = image["senderUsername"]! as! NSString as String
                                        
                                    } else {
                                        
                                        senderUsername = "unknown user"
                                        
                                    }
                                    
                                    
                                    
                                    var alert = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                                        (action) -> Void in
                                        
                                        var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                        backgroundView.backgroundColor = UIColor.blackColor()
                                        backgroundView.alpha = 0.8
                                        backgroundView.tag = 3
                                        self.view.addSubview(backgroundView)
                                        
                                        var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                        displayedImage.image = photo
                                        displayedImage.tag = 3
                                        displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                        self.view.addSubview(displayedImage)
                                        
                                        image.delete()
                                        
                                        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                                        
                                    }))
                                    
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    
                                    
                                }
                                
                                
                            })
                            
                            
                            
                            
                            
                            done = true
                        }
                        
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }

        
       /* for image in images {
            
        
        }*/
        
    }
    
    func hideMessage() {
        
        for subview in self.view.subviews {
            
            if subview.tag == 3 {
                
                subview.removeFromSuperview()
                
            }
            
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = userArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        activeRecipient = indexPath.row
        
        pickImage(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logout" {
            
            PFUser.logOut()
            
        }
        
    }
    
}
