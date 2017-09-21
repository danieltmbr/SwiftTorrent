//
//  IntExtension.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 18..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

extension Int: QueryParam {
    
    var urlEncoded: String? {
        return "\(self)"
    }
}
