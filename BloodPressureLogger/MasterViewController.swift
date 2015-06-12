//
//  MasterViewController.swift
//  BloodPressureLogger
//
//  Created by tommy trojan on 6/10/15.
//  Copyright (c) 2015 Chris Mendez. All rights reserved.
//

import UIKit
import HealthKit
import SystemConfiguration

class MasterViewController: UITableViewController {

    var objects = [AnyObject]()
        
    //Instance of Healthkit store
    var healthStore:HKHealthStore? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    //See custome code below
    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    */

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as! BloodPressureItem
            (segue.destinationViewController as! DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    /*
    //See Custom Code Below
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}

/** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
Custom Development
** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **/
extension MasterViewController: EntryViewControllerDelegate{
    
    /** ** ** ** ** ** ** ** ** ** **
    On click, load viewController
    ** ** ** ** ** ** ** ** ** ** **/
    //Show EntryViewController from MasterViewController. We'll do this from "insertNewObject"
    func insertNewObject(sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("entryViewController") as! EntryViewController
        //Tell EntryViewController that you are the delegate
        viewController.delegate = self
        
        self.navigationController?.presentViewController(viewController, animated: true, completion: nil)
    }
    
    /** ** ** ** ** ** ** ** ** ** ** 
    Delegate: This tells the compiler that the class now confirms
              to this protocol.
    ** ** ** ** ** ** ** ** ** ** **/
    //Save data to the healthStore. Once the data is saved, the in-memory objects will be updated and tableView will show the rendered
    func entryViewControllerDidSave(viewController: EntryViewController) {
        let values = viewController.bloodPressureValues()
        let bloodPressureItem = BloodPressureItem(systolic: values.systolic, pressureDiastolic: values.diastolic)
        let bloodPressureCorrelation = bloodPressureItem.asCorrelation()
        
        self.healthStore!.saveObject(bloodPressureCorrelation, withCompletion: {[unowned self](success, error) -> Void in
            if success{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let indexPath = NSIndexPath(forRow: self.objects.count, inSection: 0)
                    //Add to the objects
                    self.objects.append(bloodPressureItem as BloodPressureItem)
                    //Add to the table row
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            }
        })
    }
    //Don't do a damn thing
    func entryViewControllerDidCancel(viewController: EntryViewController) {
        println("User canceled, not saving data")
    }
    
    /** ** ** ** ** ** ** ** ** ** **
    Init
    ** ** ** ** ** ** ** ** ** ** **/
    private func load(){
        //A. Check that said iOS device supports Healthkit and that health data is available
        let healthDataAvailable = HKHealthStore.isHealthDataAvailable()

        //B. Request permission
        if healthDataAvailable {
            self.requestAuthorizationAndLoadData()
        }
    }
    
    //Mark: Healthkit
    private func readDataTypes() -> NSSet{
        let heightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        let weightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let bloodPressureSystolic = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
        let bloodPressureDiastolic = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)
        
        let birthDayType = HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)
        let biologicalSetType = HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)
        return NSSet(objects: heightType, weightType, heartRateType, bloodPressureSystolic, bloodPressureDiastolic, birthDayType, biologicalSetType)
    }
    
    private func writeDataTypes() -> NSSet{
        let heightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        let weightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let bloodPressureSystolic = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
        let bloodPressureDiastolic = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)
        
        return NSSet(objects: heightType, weightType, heartRateType, bloodPressureSystolic, bloodPressureDiastolic)
    }
    
    //Get the read/write permissions and them request authorization. Users of the app have the option to
    //  grant permission for each type you ask for but you may not get all the permissions you requested
    private func requestAuthorizationAndLoadData(){
        self.healthStore = HKHealthStore()
        
        let readDataTypes = self.readDataTypes() as NSSet as Set<NSObject>
        let writeDataTypes = self.writeDataTypes() as NSSet as Set<NSObject>
        
        self.healthStore?.requestAuthorizationToShareTypes(
            writeDataTypes,
            readTypes: readDataTypes,
            completion: { [unowned self] (success, error) -> Void in
                
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadData()
                })
            }else{
                println("You did not allow health store access")
            }
        })
    }
    
    private func loadData(){
        //Format Calendar Picker
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let dateComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear |
            NSCalendarUnit.CalendarUnitMonth |
            NSCalendarUnit.CalendarUnitDay,
            fromDate: now)
        let startDate = calendar.dateFromComponents(dateComponents)
        let endDate = calendar.dateByAddingUnit(
                NSCalendarUnit.CalendarUnitDay,
                value: 1, toDate: startDate!,
                options: NSCalendarOptions(0)
        )
        
        //Get the data for one day from the calendar picker
        let bloodPressure = HKCorrelationType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        //Create a query using HKSample Query. All data loaded from Healthkit must come from a query
        let sampleQuery = HKSampleQuery(
            sampleType: bloodPressure as HKSampleType,
            predicate: predicate,
            limit: 0,
            sortDescriptors: nil)
            { [unowned self](query, bloodPressureResults, error) -> Void in

                if let results = bloodPressureResults{
                self.objects.removeAll(keepCapacity: false)
                for result in results{
                    let bpitem = result as! HKCorrelation
                    let item = BloodPressureItem(correlation: bpitem)
                    self.objects.append(item)
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        self.healthStore?.executeQuery(sampleQuery)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let item = objects[indexPath.row] as! BloodPressureItem
        cell.textLabel!.text = String("\(item.pressureSystolic)/\(item.pressureDiastolic)")
        return cell
    }
    
}
