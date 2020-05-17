//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Simon Italia on 5/17/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    //properties
    var meme: Meme!
    
    
    //storyboard outlets
    @IBOutlet weak var memeImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    func configureUI() {
        //check meme property is set to avoid app crash
        guard meme != nil else {
            print("meme object not set, no data to show")
            return
        }
        
        //configure and set imageView image to memed image
        memeImageView.image = meme.memedImage
        memeImageView.contentMode = .scaleAspectFit
    }
}
