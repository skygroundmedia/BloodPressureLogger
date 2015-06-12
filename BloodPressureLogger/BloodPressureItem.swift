//
//  BloodPressureItem.swift
//  BloodPressureLogger
//
//  Created by tommy trojan on 6/10/15.
//  Copyright (c) 2015 Chris Mendez. All rights reserved.
//

import Foundation
import HealthKit

class BloodPressureItem{
    //Using (set) forces creation using init()
    private (set) var pressureSystolic: Double = 2.0
    private (set) var pressureDiastolic: Double = 2.0
    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    var description:NSString{
        return "\(pressureSystolic) / \(pressureDiastolic)"
    }
    
    required init(systolic:Double, pressureDiastolic diastolic:Double){
        self.pressureSystolic  = systolic
        self.pressureDiastolic = diastolic
    }
}

extension BloodPressureItem{
    //This takes the correlation item and creates an instance of BloodPressureItem
    convenience init(correlation: HKCorrelation){
        //Blood Pressure is stored in millimeters of mercury (mmHg)
        let bloodPressureUnit: HKUnit = HKUnit.millimeterOfMercuryUnit()
        //Tapping into HKQuantity class because it has pre-formatted types
        let bloodPressureSystolicType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
        let bloodPressureDiastolicType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)
        //Query the correlation for the needed values –which are stored as sets. There will only be one value but that's OK
        let systolicSet = correlation.objectsForType(bloodPressureSystolicType) as NSSet
        let diastolicSet = correlation.objectsForType(bloodPressureDiastolicType) as NSSet
        //Since you only have one value, it's easy to pull out the object which includes the "quantity", "start date" and "end date"
        let bloodPressureSystolicSample = systolicSet.anyObject() as! HKQuantitySample
        let bloodPressureDiastolicSample = diastolicSet.anyObject()as! HKQuantitySample
        //From within the single value object, you must extract the quantity
        let systolicQuantity = bloodPressureSystolicSample.quantity
        let diastolicQuantity = bloodPressureDiastolicSample.quantity
        //Get the value from the quantity
        let systolic = systolicQuantity.doubleValueForUnit(bloodPressureUnit) as Double
        let diastolic = diastolicQuantity.doubleValueForUnit(bloodPressureUnit) as Double
        //Now you have three items "value for quantity, start and end"
        self.init(systolic: systolic, pressureDiastolic: diastolic)
        self.startDate = bloodPressureSystolicSample.startDate
        self.endDate   = bloodPressureSystolicSample.endDate
    }

    //Reverse the above. Converts BloodPressureItem to a correlation so it can be store in HealthStore
    func asCorrelation() -> HKCorrelation{
        let bloodPressureUnit: HKUnit = HKUnit.millimeterOfMercuryUnit()
        
        let bloodPressureSystolicQuantity:HKQuantity = HKQuantity(unit: bloodPressureUnit, doubleValue: self.pressureSystolic)
        let bloodPressureDiastolicQuanity:HKQuantity = HKQuantity(unit: bloodPressureUnit, doubleValue: self.pressureDiastolic)
        
        let bloodPressureSystolicType:HKQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
        let bloodPressureDiastolicType:HKQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)
        
        let startDate = self.startDate
        let endDate = self.endDate
        
        let bloodPressureSystolicSample = HKQuantitySample(type: bloodPressureSystolicType, quantity: bloodPressureSystolicQuantity, startDate: startDate, endDate: endDate)
        let bloodPressureDiastolicSample = HKQuantitySample(type: bloodPressureDiastolicType, quantity: bloodPressureDiastolicQuanity, startDate: startDate, endDate: endDate)
        
        var objects:NSSet = NSSet(objects: bloodPressureSystolicSample, bloodPressureDiastolicSample)
        var bloodPressureType:HKCorrelationType = HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)
        var bloodPressureCorrelation:HKCorrelation = HKCorrelation(type: bloodPressureType, startDate: startDate, endDate: endDate, objects: objects as Set<NSObject>)
        
        return bloodPressureCorrelation
    }
}

