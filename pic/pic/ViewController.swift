//
//  ViewController.swift
//  pic
//
//  Created by Adrian Lim on 25/8/15.
//  Copyright © 2015 Adrian Lim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func click(sender: AnyObject) {
        let image = imgView.image
        let edge = TestOpenCV.DetectEdgeWithImage(image)
        imgView.image = edge as UIImage
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

