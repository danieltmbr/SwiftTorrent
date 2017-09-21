//
//  StringExtension.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 20..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

extension String {
    
    var hexArray: [String] {
        return self.unicodeScalars.flatMap {
            return String(format: "%02x", $0.value)
        }
    }
    
    var hexString: String {
        return hexArray.joined()
    }
}

extension String: QueryParam {
    
    var urlEncoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
