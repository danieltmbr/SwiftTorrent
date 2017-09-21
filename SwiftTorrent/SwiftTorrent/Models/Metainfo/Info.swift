//
//  FilesInfo.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 15..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

private struct Keys {
    static let pieceLength = "piece length"
    static let pieces = "pieces"
    static let isPrivate = "private"
    static let name = "name"
    static let files = "files"
}

struct Info {
    
    // MARK: - Properties
    
    /** Number of bytes in each piece */
    let pieceLength: Int
    
    /** sring consisting of the concatenation of all
     20-byte SHA1 hash values, one per piece
     (byte string, i.e. not urlencoded) */
    let pieces: String
    
    /** "private" may be read as "no external peer source" */
    let isPrivate: Bool
    
    /** The name of the directory in which to store all the files*/
    let directory: String?
    
    /** List of files */
    let files: [FileInfo]
    
    /** Original decoded value */
    private let bencode: Bencode
    
    /** Original encoded string content */
    var hash: Data {
        return bencode.asciiEncoding.sha1()
    }
    
    /** Accumulated size of the files */
    var size: Int {
        return files.reduce(0, { $0 + $1.length })
    }
    
    // MARK: - Inits
    
    init?(bencode: Bencode) {
        guard let pieceLength = bencode[Keys.pieceLength].int,
            let pieces = bencode[Keys.pieces].string,
            let name = bencode[Keys.name].string
            else { return nil }
        
        let files = bencode[Keys.files].flatMap({ FileInfo(bencode: $1) })

        if files.count > 0 {
            // Multiple file mode
            self.files = files
            directory = name
        } else if let file = FileInfo(bencode: bencode) {
            // Single File mode
            self.files = [file]
            directory = nil
        } else {
            // No files...
            return nil
        }
        
        self.bencode = bencode
        self.pieceLength = pieceLength
        self.pieces = pieces
        self.isPrivate = (bencode[Keys.isPrivate].int ?? 0) == 1
    }
}
