//
//  ViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 21/04/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
// import CoreData

class ViewController: UIViewController {

    
    @IBOutlet var firstLaunchLabel: UILabel!
    
    @IBAction func goToCardsIsClicked(sender: AnyObject) {
        performSegueWithIdentifier("goToAllCardsSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Test for first launch
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if firstLaunch {
            print("Not first launch")
            firstLaunchLabel.text = "Not first launch"
            
        } else {
            print("First launch")
            firstLaunchLabel.text = "First Launch"
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            
            performSegueWithIdentifier("goToIntro", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

