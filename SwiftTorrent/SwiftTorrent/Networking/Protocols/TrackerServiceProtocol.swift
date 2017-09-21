//
//  TrackerServiceProtocol.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 21..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

protocol TrackerServiceProtocol {
    
    typealias InfoResponse = (TrackerResponseModel?, Error?) -> Void
    
    typealias ScrapeResponse = (ScrapeModel?, Error?) -> Void
    
    func getInfo(for torrent: Torrent, callback: InfoResponse?)
    
    func scrape(for torrent: Torrent, callback: ScrapeResponse?)
}
