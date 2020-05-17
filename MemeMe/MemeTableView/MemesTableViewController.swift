//
//  MemeTableTableViewController.swift
//  MemeMe
//
//  Created by Simon Italia on 5/16/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class MemesTableViewController: UITableViewController {
    
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
        tableView.reloadData()
        print("tableView data refreshed")
    }
    
    
    func configureUI() {
        
        //nav bar setup
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table View loaded Memes array with \(memes.count) items")
        return memes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !memes.isEmpty else {
            print("No Memes exist, returning empty table")
            return UITableViewCell()
        }
        
        //get meme object
        let meme = memes[indexPath.row]
        
        //cell configuration
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.memeTableViewCell, for: indexPath) as! MemeTableViewCell
        let text = meme.topText + "..." + meme.bottomText
        cell.memeLabel.text = text
        cell.memeImageView.image = meme.memedImage

        return cell
    }
    
    
    //Navigation to DetailVC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: StoryboardIdentifier.memeDetailViewController) as! MemeDetailViewController

           //Populate view controller with data from the selected item
           vc.meme = memes[(indexPath as NSIndexPath).row]

           // Present the view controller using navigation
           navigationController!.pushViewController(vc, animated: true)
    }


    //Table Row Edit methods
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}
