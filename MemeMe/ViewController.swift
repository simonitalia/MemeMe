//
//  ViewController.swift
//  MemeMe
//
//  Created by Simon Italia on 5/13/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    //default text
    enum DefaultText {
        static let top = "TOP"
        static let bottom = "BOTTOM"
    }

    //properties
    var imagePicker: UIImagePickerController!
    
    //MARK:- storyboard outlets
    //toolbars
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    //action buttons
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareActionButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //text fieldss
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    //image view
    @IBOutlet weak var imagePickerView: UIImageView!
    
    
    //MARK:- storyboard actions
    //TOP Toolbar actions
    //action to generate and share memed image
    @IBAction func shareActionButtonTapped(_ sender: Any) {
        shareMeme()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        configureUI()
    }
    
    
    //BOTTOM Toolbar actions
    //action to pick imahe from camera roll / albums
    @IBAction func pickAnImage(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //action to pick image from new camarea photo
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //Configure initial UI properties
        configureUI()
        configureTextFieldAttributes()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set camera button state based on device capability
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //subscriobe to notifications
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func setTextFieldAttributes() -> [NSAttributedString.Key : Any] {
        return [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -5
        ]
    }
    
    
    func configureTextFieldAttributes() {
        let textFields = [topTextField, bottomTextField]
        let textFieldAttributes = setTextFieldAttributes()
        
        for textField in textFields {
            if let textField = textField {
                textField.delegate = self
                textField.defaultTextAttributes = textFieldAttributes
                textField.textAlignment = .center
                textField.adjustsFontSizeToFitWidth = true
            }
        }
    }
    
    
    func configureUI() {
        topTextField.text = DefaultText.top
        bottomTextField.text = DefaultText.bottom
        imagePickerView.image = nil
        
        //button states
        shareActionButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    
    
    func toolbarsAre(hidden: Bool) {
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
    
    
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        toolbarsAre(hidden: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        toolbarsAre(hidden: false)
        
        return memedImage
    }
    
    
    func shareMeme() {
        let image = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)

        //Completion handler
        activityVC.completionWithItemsHandler = { (activityType, completed, arrayReturnedItems, error) in
            
            //if share succeeded
            if completed {
                self.save(meme: image)
                print("Success! Share completed")
            
            //if share didnt save (eg. if user exited)
            } else {
                print("User cancelled share")
            }
            
            //if error
            if let error = error {
                print("Error! Reason: \(error.localizedDescription)")
            }
            
            //dismiss activityVC
            activityVC.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func save(meme image: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: image)
        
        //add generated meme to shared meme data array
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //set imageView to image (from camera or selected from album)
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
            
            //enable share action
            shareActionButton.isEnabled = true
            cancelButton.isEnabled = true
        }
        
        //dimiss ImagePickerController
        dismiss(animated: true)
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //only clear text field when text is placeholder text
        guard textField.text == DefaultText.top || textField.text == DefaultText.bottom else { return }
        textField.text = ""
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         return textField.resignFirstResponder()
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //set default texts if text field is empty
        if textField.text!.isEmpty {
            
            switch textField.tag {
            case 0:
                textField.text = DefaultText.top
                
            case 1:
                textField.text = DefaultText.bottom
                
            default:
                break
            }
        }
    
        //set cancel button state
        if imagePickerView.image == nil {
            cancelButton.isEnabled = topTextField.text == DefaultText.top && bottomTextField.text == DefaultText.bottom ? false : true
        }
    }
    
    
    //MARK:- Notification Subscriptions
    
    //Keyboard events
    func subscribeToKeyboardNotifications() {
        
        //subscribe to KB specific notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard bottomTextField.isEditing else { return } //prevent top text field from being pushed out of view
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let kbSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue //of CGRect
        return kbSize.cgRectValue.height
    }
}



