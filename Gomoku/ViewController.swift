//
//  ViewController.swift
//  Gomoku
//
//  Created by Andrew on 1/19/18.
//  Copyright © 2018 PlatformTwo. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    var boardSize:Int = -1;
    
    override func viewDidLoad() {
  
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func press15(_ sender: UIButton) {
        boardSize = 15;
    }
    
    
    @IBAction func press19(_ sender: UIButton) {
        boardSize = 19;
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segue15" {
            boardSize = 15
        }
        else if segue.identifier == "segue19" {
            boardSize = 19
        }
        else{
            print("Error: Segue'd without updating board")
            
        }
        let gameVC = segue.destination as! GameViewController
        gameVC.boardSize = self.boardSize
    }
    
    
}

