//
//  FileInfo.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 15..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

private struct Keys {
    static let path = "path"
    static let name = "name"
    static let length = "length"
    static let md5sum = "md5sum"
}

struct FileInfo {
    
    // MARK: - Properties
    
    /** Length of the file in bytes  */
    let length: Int
    
    /** A 32-character hexadecimal string
     corresponding to the MD5 sum of the file */
    let md5sum: String?
    
    /** Contains directories name (optional)
     and the filename with extension */
    let path: String
    
    // MARK: - Init
    
    init?(bencode: Bencode) {
        guard let length = bencode[Keys.length].int
            else { return nil }
        
        let paths = bencode[Keys.path].flatMap({ $1.string })
        if paths.count > 0 {
            path = paths.joined(separator: "/")
        } else if let name = bencode[Keys.name].string {
            path = name
        } else {
            return nil
        }
        
        self.length = length
        md5sum = bencode["md5sum"].string
    }
}
