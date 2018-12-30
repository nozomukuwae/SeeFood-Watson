//
//  ViewController.swift
//  SeeFood-Watson
//
//  Created by Nozomu Kuwae on 2018/12/25.
//  Copyright © 2018 NKCompany. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "Your API Key"
    let version = "2018-12-27"
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
        imagePicker.delegate = self
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        shareButton.isHidden = true
        cameraButton.isEnabled = false
        SVProgressHUD.show()

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            let imageData = image.jpegData(compressionQuality: 0.01)
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL)
            
            visualRecognition.classify(imagesFile: fileURL) { (response, error) in
                if let e = error {
                    print(e)
                } else {
                    if let res = response {
                        self.classificationResults.removeAll()
                        let classes = res.result!.images.first!.classifiers.first!.classes
                        
                        for index in 0..<classes.count {
                            self.classificationResults.append(classes[index].className)
                        }
                        
                        print(self.classificationResults)
                        
                        DispatchQueue.main.async {
                            self.cameraButton.isEnabled = true
                            self.shareButton.isHidden = false
                            SVProgressHUD.dismiss()
                        }
                        
                        if self.classificationResults.contains("hotdog") {
                            DispatchQueue.main.async {
                                self.navigationItem.title = "Hotdog!"
                                self.navigationController?.navigationBar.barTintColor = UIColor.green
                                self.navigationController?.navigationBar.isTranslucent = false
                                self.topBarImageView.image = UIImage(named: "hotdog")
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.navigationItem.title = "Not Hotdog!"
                                self.navigationController?.navigationBar.barTintColor = UIColor.red
                                self.navigationController?.navigationBar.isTranslucent = false
                                self.topBarImageView.image = UIImage(named: "not-hotdog")
                            }
                        }
                    }
                }
            }
        } else {
            print("There was an error picking the image")
        }
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        
        let share = [UIImage(named: "hotdogBackground") as Any, "MY food is \(String(describing: navigationItem.title ?? ""))"] as [Any]
        let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

