//
//  ViewController.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 15..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import UIKit
import Bencode
import CryptoSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        guard let url = Bundle.main.url(forResource: "Baywatch", withExtension: "torrent"),
            let torrent = Torrent(url: url)
            else { return }

        let service = TrackerService()
        
        service.getInfo(for: torrent) { (response, error) in
            guard let model = response
                else { return print(error) }
            print(model)
        }

        service.scrape(for: torrent) { (response, error) in
            guard let model = response
                else { return print(error) }
            print(model)
        }

    }
}
