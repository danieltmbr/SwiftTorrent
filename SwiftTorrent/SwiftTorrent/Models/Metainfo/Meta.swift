//
//  Metainfo.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 15..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

private struct Keys {
    static let info = "info"
    static let announce = "announce"
    static let announceList = "announce-list"
    static let creationDate = "creation date"
    static let comment = "comment"
    static let createdBy = "created by"
    static let encoding = "encoding"
}

struct Meta {
    
    // MARK: - Properties
    
    /** Info describes the file(s) of the torrent.
     There are two possible forms: one for the case of a 'single-file'
     torrent with no directory structure, and one for the case of
     a 'multi-file' torrent */
    let info: Info
    
    /** The announce URL of the tracker */
    let announce: String
    
    /** This is an extention to the official specification,
     offering backwards-compatibility */
    let announceList: [String]?
    
    /* The creation time of the torrent, in standard UNIX
     epoch format (integer, seconds since 1-Jan-1970 00:00:00 UTC) */
    let creationDate: Date?
    
    /** Free-form textual comments of the author */
    let comment: String?
    
    /** Name and version of the program used to create the .torrent */
    let createdBy: String?
    
    /** The string encoding format used to generate
     the pieces part of the info dictionary */
    let encoding: String?
    
    // MARK: - Init
    
    init?(bencode: Bencode) {
        
        guard let infoBencode = bencode[Keys.info].bencode,
            let info = Info(bencode: infoBencode),
            let announce = bencode[Keys.announce].string
            else { return nil }

        self.info = info
        self.announce = announce
        
        announceList = bencode[Keys.announceList]
            .list?.joined().flatMap({ $1.string })
        createdBy = bencode[Keys.createdBy].string
        comment = bencode[Keys.comment].string
        encoding = bencode[Keys.encoding].string
        if let timestamp = bencode[Keys.creationDate].int {
            creationDate =  Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            creationDate = nil
        }
    }
    
    init?(file url: URL) {
        guard let decoded = Bencode(file: url)
            else { return nil }
        self.init(bencode: decoded)
    }
}
