//
//  Torrent.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 18..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation


// TODO: Rewrite as mutable struct
final class Torrent {
    
    /** Decoded content of the '.torrent' file */
    let metaInfo: Meta
    
    /** The date when the '.torrent' file was opend. */
    let created: Date
    
    /** The date when the client first sent the 'started'
     event to the tracker and got a valid response. */
    private(set) var started: Date? = nil
    
    /** The date when downloading finished. */
    private(set) var completed: Date? = nil
    
    /**  The total number of bytes downloaded, since the
     client sent the 'started' event to the tracker */
    private(set) var downloaded: Int = 0 // TODO: Should be computed?
    
    /**  The total number of bytes uploaded, since the
     client sent the 'started' event to the tracker */
    private(set) var uploaded: Int = 0
    
    /** The number of bytes this client
     still has to download until 100% */
    var left: Int {
        return metaInfo.info.size - downloaded
    }
    
    /** Interval in seconds that the client should wait
     between sending regular requests to the tracker */
    private var waitInterval: TimeInterval = 0
    
    /**  A string that the client should
     send back on its next announcements. */
    private(set) var trackerId: String? = nil
    
    /** Number of peers with the entire file */
    private(set) var seedersCount: Int = 0
    
    /** Number of non-seeder peers */
    private(set) var leechersCount: Int = 0
    
    /** Peer info (peerId, ip, port) list */
    private(set) var peers: [PeerInfo] = []
    
    // MARK: - Init
    
    convenience init?(url: URL) {
        guard let meta = Meta(file: url)
            else { return nil }
        self.init(meta: meta)
    }
    
    init(meta: Meta) {
        metaInfo = meta
        created = Date()
    }
    
    // MARK: - Methods
    
    func update(trackerResponse resp: TrackerResponseModel) {
        
        if nil == started {
            started = Date()
        }
        if nil == trackerId {
            trackerId = resp.trackerId
        }
        
        waitInterval = TimeInterval(resp.minInterval ?? resp.interval)
        seedersCount = resp.complete ?? 0
        leechersCount = resp.incomplete ?? 0
        peers = resp.peers
    }
}
