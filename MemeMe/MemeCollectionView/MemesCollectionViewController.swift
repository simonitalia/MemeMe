//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Simon Italia on 5/16/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class MemesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    //computed property for storing (shared) Meme objects
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    
    //reload data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        print("collectionView data refreshed")
    }
    
    
    func configureUI() {
        configureCollectionViewFlowLayout()
    }
    
    
    func configureCollectionViewFlowLayout() {
        let layout = configureCompositionalLayout()
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !memes.isEmpty else {
            print("No Memes exist, returning empty collection")
            return UICollectionViewCell()
        }
        
        //get meme object
        let meme = memes[indexPath.row]
        
        //configure cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.memeCollectionViewCell, for: indexPath) as! MemeCollectionViewCell
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    
    //Navigation to DetailVC
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: StoryboardIdentifier.memeDetailViewController) as! MemeDetailViewController

        //Populate view controller with data from the selected item
        vc.meme = memes[indexPath.item]

        // Present the view controller using navigation
        navigationController!.pushViewController(vc, animated: true)
    }
}
