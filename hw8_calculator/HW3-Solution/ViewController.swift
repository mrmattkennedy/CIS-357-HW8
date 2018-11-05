//
//  ViewController.swift
//  HW3-Solution
//
//  Created by Jonathan Engelsma on 9/7/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, SettingsViewControllerDelegate, HistoryTableViewControllerDelegate {
    
    
    struct Conversion {
        /*Value entered*/
        var fromVal: Double
        /*Value converted to*/
        var toVal: Double
        /*mode the calculator is currently in*/
        var mode: CalculatorMode
        /*Unit converted from*/
        var fromUnits: String
        /*Unit converted to*/
        var toUnits: String
        /*Time of the entered conversion - used for History storage*/
        var recordedTime: Date
        
        init(fromVal:Double, toVal:Double, mode:CalculatorMode, fromUnits:String, toUnits:String, recordedTime:Date) {
            self.fromVal = fromVal
            self.toVal = toVal
            self.mode = mode
            self.fromUnits = fromUnits
            self.toUnits = toUnits
            self.recordedTime = recordedTime
        }
    }    //Struct logic worked on in class with Justin
    var entries:[Conversion] = []

    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var fromUnits: UILabel!
    @IBOutlet weak var toUnits: UILabel!
    @IBOutlet weak var calculatorHeader: UILabel!
    
    var currentMode : CalculatorMode = .Length
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toField.delegate = self
        fromField.delegate = self
        self.view.backgroundColor = BACKGROUND_COLOR
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @IBAction func calculatePressed(_ sender: UIButton) {
        // determine source value of data for conversion and dest value for conversion
        var dest : UITextField?

        var val = ""
        if let fromVal = fromField.text {
            if fromVal != "" {
                val = fromVal
                dest = toField
            }
        }
        if let toVal = toField.text {
            if toVal != "" {
                val = toVal
                dest = fromField
            }
        }
        if dest != nil {
            switch(currentMode) {
            case .Length:
                var fUnits, tUnits : LengthUnit
                if dest == toField {
                    fUnits = LengthUnit(rawValue: fromUnits.text!)!
                    tUnits = LengthUnit(rawValue: toUnits.text!)!
                } else {
                    fUnits = LengthUnit(rawValue: toUnits.text!)!
                    tUnits = LengthUnit(rawValue: fromUnits.text!)!
                }
                if let fromVal = Double(val) {
                    let convKey =  LengthConversionKey(toUnits: tUnits, fromUnits: fUnits)
                    let toVal = fromVal * lengthConversionTable[convKey]!;
                    dest?.text = "\(toVal)"
                }
            case .Volume:
                var fUnits, tUnits : VolumeUnit
                if dest == toField {
                    fUnits = VolumeUnit(rawValue: fromUnits.text!)!
                    tUnits = VolumeUnit(rawValue: toUnits.text!)!
                } else {
                    fUnits = VolumeUnit(rawValue: toUnits.text!)!
                    tUnits = VolumeUnit(rawValue: fromUnits.text!)!
                }
                if let fromVal = Double(val) {
                    let convKey =  VolumeConversionKey(toUnits: tUnits, fromUnits: fUnits)
                    let toVal = fromVal * volumeConversionTable[convKey]!;
                    dest?.text = "\(toVal)"
                }
            }
        }
        self.view.endEditing(true)
        guard let fVal = Double(fromField.text!), let tVal = Double(toField.text!) else { return }
        entries.append(Conversion(fromVal: fVal, toVal: tVal, mode: currentMode, fromUnits: fromUnits.text!, toUnits: toUnits.text!, recordedTime: Date()))
        print("\(entries.count)")
    }
    //Clears the fields when clear button pressed
    @IBAction func clearPressed(_ sender: UIButton) {
        self.fromField.text = ""
        self.toField.text = ""
        self.view.endEditing(true)
    }
    //Changes the mode when the mode button is pressed
    @IBAction func modePressed(_ sender: UIButton) {
        clearPressed(sender)
        switch (currentMode) {
        case .Length:
            currentMode = .Volume
            fromUnits.text = VolumeUnit.Gallons.rawValue
            toUnits.text = VolumeUnit.Liters.rawValue
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        case .Volume:
            currentMode = .Length
            fromUnits.text = LengthUnit.Yards.rawValue
            toUnits.text = LengthUnit.Meters.rawValue
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        }

        calculatorHeader.text = "\(currentMode.rawValue) Conversion Calculator"
        
    }
    //Load units / conversion algorithm based on mode
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            //clearPressed(sender as! UIButton)
            if let  target = segue.destination as? SettingsViewController {
                target.mode = currentMode
                target.fUnits = fromUnits.text
                target.tUnits = toUnits.text
                target.delegate = self
            }
        } else if segue.identifier == "historySegue" {
            //clearPressed(sender as! UIButton)
            if let  target = segue.destination as? HistoryTableViewController {
                for i in entries{
                    target.entries.append(i)
                }
                target.historyDelegate = self
                //logic for this worked on in class w/ other classmates (Justin, Kaylin)
            }
        }
    }
    
    func selectEntry(entry: ViewController.Conversion) {
        self.fromUnits.text = entry.fromUnits
        self.toUnits.text = entry.toUnits
        self.fromField.text = String(entry.fromVal)
        self.toField.text = String(entry.toVal)
    }
    
    func settingsChanged(fromUnits: LengthUnit, toUnits: LengthUnit)
    {
        self.fromUnits.text = fromUnits.rawValue
        self.toUnits.text = toUnits.rawValue
    }
    
    func settingsChanged(fromUnits: VolumeUnit, toUnits: VolumeUnit)
    {
        self.fromUnits.text = fromUnits.rawValue
        self.toUnits.text = toUnits.rawValue
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == toField) {
            fromField.text = ""
        } else {
            toField.text = ""
        }
    }
}
