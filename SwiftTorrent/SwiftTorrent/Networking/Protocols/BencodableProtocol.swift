//
//  BencodableProtocol.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 22..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation
import Bencode

protocol Bencodeable {
    init?(bencode: Bencode)
}
