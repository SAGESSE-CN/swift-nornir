//
//  Array+OptionalGet.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/24/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

internal extension Array {
    
    func ub_get(at index: Index) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
}
