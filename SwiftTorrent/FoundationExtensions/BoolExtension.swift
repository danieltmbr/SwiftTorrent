//
//  BoolExtension.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 18..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

extension Bool: QueryParam {
    
    var urlEncoded: String? {
        return "\(self.int)"
    }
    
    var int: Int {
        return self ? 1 : 0
    }
}
