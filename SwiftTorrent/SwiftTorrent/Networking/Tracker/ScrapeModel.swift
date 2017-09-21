//
//  ScrapeModel.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 21..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

struct ScrapeModel: Bencodeable {
    
    /** a dictionary containing one key/value pair for each torrent
     for which there are stats. If info_hash was supplied and was valid,
     this dictionary will contain a single key/value.
     Each key consists of a 20-byte binary info_hash */
    let files: [String: ScrapeFileModel]
    
    init?(bencode: Bencode) {
        guard let filesBencodeDict = bencode["files"].dict
            else { return nil }
        
        var filesDict = [String: ScrapeFileModel]()
        filesBencodeDict.forEach { (bKey, bValue) in
            guard let value = ScrapeFileModel(bencode: bValue)
                else { return }
            filesDict[bKey.key.hexString] = value
        }
        self.files = filesDict
    }
}

struct ScrapeFileModel {
    
    private struct Keys {
        let complete = "complete"
        let downloaded = "downloaded"
        let incomplete = "incomplete"
        let name = "name"
    }
    
    /** number of peers with the
     entire file, i.e. seeders */
    let complete: Int
    
    /** total number of times the tracker
     has registered a completion */
    let downloaded: Int
    
    /** number of non-seeder peers, aka "leechers" */
    let incomplete: Int
    
    /** the torrent's internal name, as
     specified by the "name" file in the
     info section of the .torrent file */
    let name: String?
    
    init?(bencode: Bencode) {
        let keys = Keys()
        guard let complete = bencode[keys.complete].int,
        let downloaded = bencode[keys.downloaded].int,
        let incomplete = bencode[keys.incomplete].int
            else { return nil }
        
        self.complete = complete
        self.downloaded = downloaded
        self.incomplete = incomplete
        self.name = bencode[keys.name].string
    }
}
