//
//  EntryViewController.swift
//  BloodPressureLogger
//
//  Created by tommy trojan on 6/11/15.
//  Copyright (c) 2015 Chris Mendez. All rights reserved.
//

import UIKit

//
protocol EntryViewControllerDelegate {
    func entryViewControllerDidCancel(viewController: EntryViewController)
    func entryViewControllerDidSave(viewController: EntryViewController)
}

class EntryViewController: UIViewController {

    var delegate: EntryViewControllerDelegate? = nil

    @IBOutlet weak var systolicField: UITextField!
    
    @IBOutlet weak var diastolicField: UITextField!

    @IBAction func cancel(sender: AnyObject) {
        self.delegate?.entryViewControllerDidCancel(self)
        //Dismiss the EntryViewController once the values have been added
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        self.delegate?.entryViewControllerDidSave(self)
        //Dismiss the EntryViewController once the values have been added
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //Let's add a function to the EntryViewController that will return values as saved
    func bloodPressureValues() -> (systolic: Double, diastolic: Double){
        let systolicString = systolicField.text as NSString?
        let diastolicString = diastolicField.text as NSString?
        
        var systolic = 0.0
        var diastolic = 0.0
        
        if let systolicValue = systolicString{
            systolic  = systolicValue.doubleValue
        }
        if let diastolicValue = diastolicString{
            diastolic = diastolicValue.doubleValue
        }
        return (systolic, diastolic)
    }
    
    
}
