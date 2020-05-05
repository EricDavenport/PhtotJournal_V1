//
//  NewEntryViewController.swift
//  PhotoJournal_V1
//
//  Created by Eric Davenport on 5/1/20.
//  Copyright © 2020 Eric Davenport. All rights reserved.
//

import UIKit
import AVFoundation

class NewEntryViewController: UIViewController {

  @IBOutlet weak var newEntryImageView: UIImageView!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  
  private let imagePickerController = UIImagePickerController()
  
  private var entries = [Entry]()
  
  private let dataPersistence = PersistenceHelper(filename: "images.plist")
  
  public var selectedImage: UIImage! {
    didSet {
      print("new image selected")
      newEntryImageView.image = selectedImage
    }
  }
  
  
  // optional init setup
  init?(coder: NSCoder, image: UIImage?) {
    self.selectedImage = image
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  override func viewDidLoad() {
        super.viewDidLoad()
    setUpCamera()
    imagePickerController.delegate = self
    loadEntries()
    }
  
  private func setUpCamera() {
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraButton.isEnabled = false
    }
  }
  
  private func loadEntries() {
    do {
      entries = try dataPersistence.loadEntries()
      print("Entries count = \(entries.count)")
    } catch {
      print("failed to load enties")
    }
  }
    
  @IBAction func cancellButtonPressed(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
  
  @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
    if selectedImage != nil {
    appendToCollection()
      print("saved to DP")
    } else {
      print("nothing to save")
    }
  }
  
  @IBAction func phtotoLibraryButton(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .photoLibrary
    present(imagePickerController, animated: true)
  }
  
  @IBAction func cameraButton(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .camera
    present(imagePickerController, animated: true)
  }
  
  
  private func appendToCollection() {
    
    guard let image = selectedImage,
      let imageData = image.jpegData(compressionQuality: 1.0) else {
        print("image is nil")
        return
    }
    
    let size = UIScreen.main.bounds.size
    print("original size = \(image.size)")
    let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
    
    let resizedImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
    print("resized image size = \(resizedImage.size)")
    guard let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) else {
      return
    }
    
    let newEntry = Entry(imageData: resizedImageData, date: Date())
    entries.insert(newEntry, at: entries.count)
    
//    let indexPath = IndexPath(row: 0, section: 0)
    do {
      try dataPersistence.createEntry(newEntry)
      print("photo added to collection")
    } catch {
      print("saving error: \(error)")
    }
  }
  
  
  
}


extension NewEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    imagePickerController.dismiss(animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      print("image selected not found")
      return
    }
    print("image selected")
    selectedImage = image
    imagePickerController.dismiss(animated: true)
  }
}
