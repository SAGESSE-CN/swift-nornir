//
//  SAPSelectionable.swift
//  SAC
//
//  Created by SAGESSE on 9/27/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import Foundation


internal protocol SAPSelectionable: class {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPAsset) -> Int
   
    // check whether item can select
    func selection(_ selection: Any, shouldSelectItemFor photo: SAPAsset) -> Bool
    func selection(_ selection: Any, didSelectItemFor photo: SAPAsset)
    
    // check whether item can deselect
    func selection(_ selection: Any, shouldDeselectItemFor photo: SAPAsset) -> Bool
    func selection(_ selection: Any, didDeselectItemFor photo: SAPAsset)
    
    // editing
    func selection(_ selection: Any, willEditing sender: Any)
    func selection(_ selection: Any, didEditing sender: Any)
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SAPAsset, with sender: Any)
}

public extension Notification.Name {
    
    public static let SAPSelectionableDidSelectItem = Notification.Name(rawValue: "SAPSelectionableDidSelectItem")
    public static let SAPSelectionableDidDeselectItem = Notification.Name(rawValue: "SAPSelectionableDidDeselectItem")
}
