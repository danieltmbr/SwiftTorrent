//
//  TrackerService.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 16..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

enum TrackerError: Error {
    case invalidResponse
    case invalidRequest
    case failure(TrackerResponseFailure)
}

final class TrackerService: TrackerServiceProtocol {
    
    func getInfo(for torrent: Torrent, callback: TrackerServiceProtocol.InfoResponse?) {
        
        let path = torrent.metaInfo.announce
        let requestModel = TrackerRequestModel(torrent: torrent)
        
        get(
            path: path,
            params: requestModel.parameters,
            callback: callback
        )
    }
    
    func scrape(for torrent: Torrent, callback: TrackerServiceProtocol.ScrapeResponse?) {
        
        let path = getScrapeUrl(from: torrent)?.absoluteString ?? ""
        let requestModel = TrackerRequestModel(torrent: torrent)
        
        get(
            path: path,
            params: requestModel.parameters,
            callback: callback
        )
    }
}

// MARK: - Helper private functions

fileprivate extension TrackerService {
    
    private func get<T>(path: String, params: [String: QueryParam], callback: ((T?, Error?) -> Void)?)
        where T: Bencodeable {
            
            let session = URLSession(
                configuration: URLSessionConfiguration.default
            )
            //            URLSessionConfiguration.background(
            //                withIdentifier: torrent.metaInfo.info.files[0].path
            //            )
            
            guard let urlRequest = URLRequest(
                method: .get,
                path: path,
                parameters: params,
                headers: nil)
                else {
                    callback?(nil, TrackerError.invalidRequest)
                    return
            }
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                
                guard nil == error else {
                    callback?(nil, error!)
                    return
                }
                guard let responseData = data,
                    let responseString = String(data: responseData, encoding: .ascii),
                    let bencode = Bencode(bencodedString: responseString)
                    else {
                        callback?(nil, TrackerError.invalidResponse)
                        return
                }
                
                if let trackerResponse = T(bencode: bencode) {
                    callback?(trackerResponse, nil)
                } else if let failure = TrackerResponseFailure(bencode: bencode) {
                    callback?(nil, TrackerError.failure(failure))
                } else {
                    callback?(nil, TrackerError.invalidResponse)
                }
            }
            
            task.resume()
    }
    
    
    private func getScrapeUrl(from torrent: Torrent) -> URL? {
        let announce = torrent.metaInfo.announce
        var components = announce.split(separator: "/").map{ String($0) }
        
        guard let last = components.last,
            last.contains("announce")
            else { return nil }
        
        components[components.count - 1] = last
            .replacingOccurrences(of: "announce", with: "scrape")
        
        return URL(string: components.joined(separator: "/"))
    }
    
}
