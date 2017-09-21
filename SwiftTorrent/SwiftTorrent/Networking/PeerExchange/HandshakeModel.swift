//
//  HandshakeModel.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 16..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

struct HandshakeModel {
    
    /**  length of <pstr>, as a single raw byte */
    let pstrlen: String
    
    /** identifier of the protocol */
    let pstr: String
    
    /** eight (8) reserved bytes.
     All current implementations use all zeroes. */
    let reserved: UInt8
    
    /** 20-byte SHA1 hash of the info key in the metainfo file.
     This is the same info_hash that is transmitted in tracker requests. */
    let info_hash: String
    
    /** 20-byte string used as a unique ID for the client. */
    let peer_id: String
    
}

/** Notes
 - "reserved": Each bit in these bytes can be used to change the behavior of the protocol. An email from Bram suggests that trailing bits should be used first, so that leading bits may be used to change the meaning of trailing bits.
 - "peer_id": This is usually the same peer_id that is transmitted in tracker requests (but not always e.g. an anonymity option in Azureus).
 */
