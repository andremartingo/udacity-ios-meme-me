//
//  MemeEditViewController.swift
//  meme-me
//
//  Created by Patrick Paechnatz on 18.10.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //
    // MARK: EditViewController Outlets
    //
    
    @IBOutlet weak var toolBarBottom: UIToolbar!
    @IBOutlet weak var toolBarTop: UIToolbar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoLibButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var inputFieldTop: MemeTextView!
    @IBOutlet weak var inputFieldBottom: MemeTextView!
    
    //
    // MARK: EditViewController Internal Variables And Constants
    //
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let memeFontNames = ["Impact", "Futura-CondensedExtraBold", "HelveticaNeue-CondensedBlack"]
    let memeFontNameFailback = "Arial"
    let memeTextViewTopDefault = "TOP"
    let memeTextViewBottomDefault = "BOTTOM"
    let memeFontSize: CGFloat = 32.0
    let memeFontSizeMinimum: CGFloat = 10.0
    let memeTextViewDelegate = MemeTextViewDelegate()
    let memeImageContentMode: UIViewContentMode = .scaleAspectFit
    let imagePickerController = UIImagePickerController()
    
    var imagePickerSuccess: Bool = false
    var usedMemeFontName: String!
    var memeTextViewAttributedText: NSMutableAttributedString!
    var memeTextViewAttributes: [String : Any]!
    var memeTextViewCurrent: MemeTextView!
    var memeParagraphStyle: NSMutableParagraphStyle!
    var editMode: Bool = false
    var currentMeme: Meme?
    var currentMemeRowIndex: Int?
    
    //
    // MARK: EditViewController Overrides, LifeCycle Methods
    //

    override func viewDidLoad() {
        
        super.viewDidLoad()

        prepareControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        unSubscribeToKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()

        updateInputControls()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        if (imagePickerSuccess || editMode) {
            return
        }
        
        imagePickerView.contentMode = .scaleAspectFill
        imagePickerView.image = UIImage(named: "WelcomeMemeCreatePortrait")
        
        if (toInterfaceOrientation.isLandscape) {
            imagePickerView.image = UIImage(named: "WelcomeMemeCreateLandscape")
        }
    }
    
    // set orientation to portrati (fix) in editView
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if (!imagePickerSuccess || !editMode) {
            return UIInterfaceOrientationMask.all
        }
        
        return UIInterfaceOrientationMask.portrait
    }
    
    // disable orientation switch in editView
    override var shouldAutorotate: Bool {
        
        if (!imagePickerSuccess || !editMode) {
            return true
        }
        
        return false
    }
    
    //
    // MARK: Actions
    //
    
    @IBAction func saveMeme(_ sender: AnyObject) {
        
        saveImageModel(memedImage: imagePickerView.image!)
        
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func cancelEditMeme(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exportImage(_ sender: AnyObject) {
        
        // generate our memed image
        let sourceImage: UIImage = renderMemedImage()
        
        // Create the subMenu controller (using alertViewController)
        let alertController = UIAlertController(
            title: "Export Your Meme",
            message: "Choose your export method",
            preferredStyle: .alert)
        
        let normalExportAction = UIAlertAction(title: "Save Meme", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.saveImage(renderedImage: sourceImage)
        }
        
        let sharedExportAction = UIAlertAction(title: "Share Meme", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.shareImage(renderedImage: sourceImage)
        }
        
        // Add Basic actions
        alertController.addAction(normalExportAction)
        alertController.addAction(sharedExportAction)
        
        // Add Cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in return
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pickCameraImage(_ sender: AnyObject) {
    
        imagePickerController.sourceType = .camera
        loadImagePickerSource()
    }
    
    @IBAction func pickLocalImageStock(_ sender: AnyObject) {
        
        // Create the subMenu controller (using alertViewController)
        let alertController = UIAlertController(
            title: "Pick an image",
            message: "Choose your image location",
            preferredStyle: .alert)
        
        // Create the photo selection related actions
        if isPhotoLibrarayAvailable() {
            
            let photoLibAction = UIAlertAction(title: "From Photos", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.imagePickerController.sourceType = .photoLibrary
                self.loadImagePickerSource()
            }
            
            alertController.addAction(photoLibAction)
        }
        
        if isSavedPhotosAlbumAvailable() {
            
            let photoAlbumAction = UIAlertAction(title: "From Album", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.imagePickerController.sourceType = .savedPhotosAlbum
                self.loadImagePickerSource()
            }
            
            alertController.addAction(photoAlbumAction)
        }
        
        // Add Cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in return
        })
        
        present(alertController, animated: true, completion: nil)
    }
}
