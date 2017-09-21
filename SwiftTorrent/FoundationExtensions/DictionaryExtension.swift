//
//  DictionaryExtension.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 18..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func addOptional(value: Value?, for key: Key) {
        guard let value = value else { return }
        self[key] = value
    }
    
}
