//
//  PeerInfo.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 16..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

struct PeerInfo {
    
    // MARK: - Constants
    
    private struct Keys {
        let peerId = "peer id"
        let ip = "ip"
        let port = "port"
    }
    
    // MARK: - Properties
    
    /** Peer's self-selected ID */
    let id: String?
    
    /** Peer's IP address either IPv6 (hexed) or
     IPv4 (dotted quad) or DNS name (string) */
    let address: PeerAddress
    
    /** Peer's port number */
    let port: Int
    
    // MARK: - Init
    
    init?(bencode: Bencode) {
        let keys = Keys()
        guard let ip = bencode[keys.ip].string,
            let address = PeerInfo.decodeAddress(string: ip),
            let port = bencode[keys.port].int
            else { return nil }
        
        id = bencode[keys.peerId].string
        self.address = address
        self.port = port
    }
    
    init(address: PeerAddress, port: Int) {
        self.address = address
        self.port = port
        self.id = nil
    }
}

fileprivate extension PeerInfo {

    static func decodeAddress(string: String) -> PeerAddress? {
        
        if string.hexArray.count == 4 {
            return PeerAddress(ipv4: string.hexArray)
        }
        else if string.split(separator: ".").count == 4 {
            return PeerAddress(ipv4:
                string.split(separator: ".").map{ String($0) }
            )
        }
        else if let address = PeerAddress(dns: string) {
            return address
        }
        else {
            // TODO: Try decoding ipv6
            return nil
        }
    }
}

// MARK: - Peer address

enum PeerAddress {
    
    case ipv4([UInt8])
    case ipv6([String])
    case dns(URL)
    
    init?(ipv4 array: [String]) {
        let values = array.flatMap { UInt8($0, radix: 16) }
        guard values.count == 4 else { return nil }
        self = .ipv4(values)
    }
    
    init?(ipv6 array: [String]) {
        return nil
    }
    
    init?(dns: String) {
        guard let url = URL(string: dns) else { return nil }
        self = .dns(url)
    }
}

extension PeerAddress {
 
    var dotted: String? {
        switch self {
        case .ipv4(let array): return array.map{ "\($0)" }.joined(separator: ".")
        case .ipv6(let array): return array.joined(separator: ":")
        default: return nil
        }
    }
}
