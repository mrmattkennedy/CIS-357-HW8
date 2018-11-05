//
//  HistoryTableViewController.swift
//  HW3-Solution
//
//  Created by Tyler Bruder / Matthew Kennedy on 11/02/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import UIKit

protocol HistoryTableViewControllerDelegate{
    func selectEntry(entry: ViewController.Conversion)
}

class HistoryTableViewController: UITableViewController {
    
    var entries : [ViewController.Conversion] = []
    var historyDelegate:HistoryTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortIntoSections(entries: self.entries)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData?.count ?? 0
    }
    //Table view of the entries
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData?[section].entries.count ?? 0
    }

    //Method from project description
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FancyCell", for: indexPath) as! HistoryTableViewCell
        if let entry = self.tableViewData?[indexPath.section].entries[indexPath.row] {
            cell.conversionLabel.text = "\(entry.fromVal) \(entry.fromUnits) = \(entry.toVal) \(entry.toUnits)"
            cell.timestampLabel.text = "\(entry.recordedTime.description)"
            cell.thumbnail.image = UIImage(imageLiteralResourceName: entry.mode == .Volume ? "volume" : "length")
        }
        return cell
    }

 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // use the historyDelegate to report back entry selected to the calculator scene
        if let del = self.historyDelegate {
            if let conv = self.tableViewData?[indexPath.section].entries[indexPath.row] {
                del.selectEntry(entry: conv)
            }
        }
        
        // Line used from project description used to pop back to main controller
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    var tableViewData: [(sectionHeader: String, entries: [ViewController.Conversion])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    //Function that sorts the history data in sections
    func sortIntoSections(entries: [ViewController.Conversion]) {
        
        var tmpEntries : Dictionary<String,[ViewController.Conversion]> = [:]
        var tmpData: [(sectionHeader: String, entries: [ViewController.Conversion])] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        // partition into sections
        for entry in entries {
            let shortDate = dateFormatter.string(from: entry.recordedTime)
            if var bucket = tmpEntries[shortDate] {
                bucket.append(entry)
                tmpEntries[shortDate] = bucket
            } else {
                tmpEntries[shortDate] = [entry]
            }
        }
        
        // breakout into our preferred array format
        let keys = tmpEntries.keys
        for key in keys {
            if let val = tmpEntries[key] {
                tmpData.append((sectionHeader: key, entries: val))
            }
        }
        
        // sort by increasing date.
        tmpData.sort { (v1, v2) -> Bool in
            if v1.sectionHeader < v2.sectionHeader {
                return true
            } else {
                return false
            }
        }
        
        self.tableViewData = tmpData
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) ->
        String? {
            return self.tableViewData?[section].sectionHeader
    }
    //Setting the height for the rows
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->
        CGFloat {
            return 80.0
    }
    //Setting the colors of the history table view
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection
        section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = BACKGROUND_COLOR
        header.contentView.backgroundColor = FOREGROUND_COLOR
    }
    
    //Setting the colors of the history table view
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView,
                            forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = BACKGROUND_COLOR
        header.contentView.backgroundColor = FOREGROUND_COLOR
    }
}
