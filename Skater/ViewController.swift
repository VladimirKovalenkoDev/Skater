//
//  ViewController.swift
//  Skater
//
//  Created by Владимир Коваленко on 14.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func playButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "playGame", sender: self)
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
