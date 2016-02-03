//
//  ActivityFooterTableDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A datasource that manages a single section (usually the last section) of a table view
/// and provides a cell with some indication of acitivty to show that a next page is loading
class ActivityFooterTableDataSource: NSObject, UITableViewDataSource {
    
    let identifier = "ActivityIndicatorTableCell"
    
    weak private var cell: UITableViewCell? {
        didSet {
            cell?.hidden = hidden
        }
    }
    
    var hidden: Bool = true {
        didSet {
            cell?.hidden = hidden
        }
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        // Hides the separator for this cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        
        self.cell = cell
        return cell
    }
    
    func registerCells( tableView: UITableView ) {
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: ActivityIndicatorTableCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.hidden ? 0.0 : 50.0
    }
}
