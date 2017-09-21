//
//  TrackerResponse.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 15..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

enum PeerError: Error {
    case invalidHexValue(String)
    case invalidHexLength(Int)
}

// MARK: - Tracker Response Model

struct TrackerResponseModel: Bencodeable {
    
    // MARK: - Constants
    
    private struct Keys {
        let warningMessage = "warning message"
        let interval = "interval"
        let minInterval = "min interval"
        let trackerId = "tracker id"
        let complete = "complete"
        let incomplete = "incomplete"
        let peers = "peers"
    }
    
    // MARK: - Properties
    
    /** Similar to failure reason, but the response
     still gets processed normally */
    let warningMessage: String?
    
    /**  Interval in seconds that the client should wait
     between sending regular requests to the tracker */
    let interval: Int
    
    /** Minimum announce interval. If present clients
     must not reannounce more frequently than this. */
    let minInterval: Int?
    
    /** A string that the client should send back on its next
     announcements. If absent and a previous announce sent a
     tracker id, do not discard the old value; keep using it. */
    let trackerId: String?
    
    /** Number of peers with the entire file, i.e. seeders */
    let complete: Int?
    
    /** Number of non-seeder peers, aka "leechers" */
    let incomplete: Int?
    
    /** List of Peers info */
    private(set) var peers: [PeerInfo]
    
    /** the peers value may be a string consisting of multiples of
     6 bytes. First 4 bytes are the IP address and last 2 bytes
     are the port number. All in network (big endian) notation */
    let peersBinary: String?
    
    // MARK: - Init
    
    init?(bencode: Bencode) {
        let keys = Keys()
        
        guard let interval = bencode[keys.interval].int
            else { return nil }
        
        peers = bencode[keys.peers].flatMap({ PeerInfo(bencode: $1) })
        peersBinary = bencode[keys.peers].string
        
        if peers.count <= 0, let binary = peersBinary {
            peers = TrackerRequestModel.decodePeersBinary(peers: binary)
        }
        
        guard peers.count > 0
            else { return nil }
        
        self.interval = interval
        complete = bencode[keys.complete].int
        incomplete = bencode[keys.incomplete].int
        minInterval = bencode[keys.minInterval].int
        trackerId = bencode[keys.trackerId].string
        warningMessage = bencode[keys.warningMessage].string
    }
    
}

// MARK: - Peers decoding functions

fileprivate extension TrackerRequestModel {
    
    static func decodePeersBinary(peers: String) -> [PeerInfo] {
        
        if let ipv4Peers = TrackerRequestModel.decodeIPv4Peers(binaryString: peers) {
            return ipv4Peers
        } else {
            // TODO: Try decode ipv6 & dns domains as well....
            return []
        }
    }
    
    static func decodeIPv4Peers(binaryString: String) -> [PeerInfo]? {
        
        let hexArray = binaryString.hexArray
        guard hexArray.count % 6 == 0
            else { return nil }
        
        let numberOfPeers = hexArray.count/6
        var peers: [PeerInfo] = []
        
        for i in 0..<numberOfPeers {
            let offset = i*6
            guard let address = PeerAddress(ipv4: Array(hexArray[offset..<offset+4])),
                let port = try? decodePort(hexArray: Array(hexArray[offset+4..<offset+6]))
                else { continue }
            
            peers.append(PeerInfo(address: address, port: port))
        }
        
        return peers.count > 0 ? peers : nil
    }
    
    static private func decodePort(hexArray: [String]) throws -> Int  {
        guard hexArray.count <= 2
            else { throw PeerError.invalidHexLength(hexArray.count) }
        
        return try hexArray.reduce(0) {
            guard let value = Int($1, radix: 16)
                else { throw PeerError.invalidHexValue($1)}
            return $0 * Int(UInt8.max) +  value
        }
    }
}

// MARK: - Tracker Failure response

struct TrackerResponseFailure {
    
    private static let failureReason = "failure reason"
    
    /** Human readable error message.
     If present, then no other keys may be present. */
    let failureReason: String
    
    init?(bencode: Bencode) {
        guard let failure = bencode[TrackerResponseFailure.failureReason].string
            else { return nil }
        failureReason = failure
    }
}
