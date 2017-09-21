//
//  UInt8Extension.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 20..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation


extension Data: QueryParam {
    
    var urlEncoded: String? {
        return self
            .map {
                switch $0 {
                case UInt8(ascii: " "):
                    return "+"
                case UInt8(ascii: "."), UInt8(ascii: "-"), UInt8(ascii: "_"), UInt8(ascii: "~"),
                     UInt8(ascii: "a")...UInt8(ascii: "z"),
                     UInt8(ascii: "A")...UInt8(ascii: "Z"),
                     UInt8(ascii: "0")...UInt8(ascii: "9"):
                    return String(Character(UnicodeScalar(UInt32($0))!))
                default:
                    return String(format:"%%%02x", $0)
                }
            }
            .joined()
    }
    
}
