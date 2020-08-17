//
//  ViewController.swift
//  Skater
//
//  Created by Владимир Коваленко on 14.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import WebKit
class MainViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deepLinkbutton: UIButton!
    
    @IBAction func deepButtonPressed(_ sender: UIButton) {
         performSegue(withIdentifier: "goLink", sender: self)
    }
    @IBAction func playButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "playGame", sender: self)
       
    }
    

}
