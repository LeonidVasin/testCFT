//
//  ViewController.swift
//  test CFT
//
//  Created by Leonid on 27.05.2018.
//  Copyright © 2018 Leonid Team. All rights reserved.
//

import UIKit

class FilterImaViewController: UIViewController {
    
    fileprivate var filterImages: [FilterImageViewData] = []
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var selectionImageButton: UIButton!
    @IBOutlet fileprivate weak var originalImageView: UIImageView!
    
    @IBOutlet fileprivate weak var loadImageProgress: UIProgressView!
    @IBOutlet fileprivate var filterButtons: Array<UIButton> = []
    
    fileprivate let filterImagePresenter = FilterImagePresenter(FilterImageService())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterImagePresenter.attachView(self)
        filterImagePresenter.viewIsReady()
        
        setupInitialState()
    }
    
    @IBAction private func applyFilter(_ sender: UIButton) {
        filterImagePresenter.applyFilter(sender.tag)
    }
    
    @IBAction private func addOriginalImageAction(_ sender: UIButton) {
        filterImagePresenter.addImage()
    }
    
    private func configureFilterButton() {
        for (index, button) in filterButtons.enumerated() {
            let butotnTitle = filterImagePresenter.getFilterName(index)
            button.setTitle(butotnTitle, for: .normal)
            button.tag = index
            button.layer.borderColor = UIColor.borderButton
        }
    }
    
    private func setupInitialState() {
        originalImageView.isHidden = true
        selectionImageButton.isHidden = false
        loadImageProgress.isHidden = true
        
        configureFilterButton()
        selectionImageButton.setTitle("Select image", for: .normal)
        
        let tapGestureOriginalImage = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureOriginalImage))
        originalImageView.addGestureRecognizer(tapGestureOriginalImage)
        originalImageView.isUserInteractionEnabled = true
    }
    
    @objc private func handleTapGestureOriginalImage() {
        filterImagePresenter.addImage()
    }
}

extension FilterImaViewController: FilterImageView {
    func startLoadImage() {
        selectionImageButton.isHidden = true
        originalImageView.isHidden = true
        loadImageProgress.isHidden = false
        loadImageProgress.progress = 0.0
    }
    
    func stopLoadingImage() {
        originalImageView.isHidden = false
        loadImageProgress.isHidden = true
    }
    
    func setLoadingImage(_ procent: Float) {
        loadImageProgress.progress = procent
    }
    
    func updateFilterImagesData() {
        collectionView.reloadData()
    }
    
    func setOriginalImage(_ image: UIImage) {
        originalImageView.image = image
        selectionImageButton.isHidden = true
        originalImageView.isHidden = false
    }
    
    func showChooseImageDataProvider() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: "Photo", style: .default) { (action) in
            self.filterImagePresenter.selectDataProvider(at: .camera)
        }
        alertController.addAction(photoAction)
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { (action) in
            self.filterImagePresenter.selectDataProvider(at: .photoLibrary)
        }
        alertController.addAction(libraryAction)
        
        let loadAction = UIAlertAction(title: "Download image", style: .default) { (action) in
            self.filterImagePresenter.selectDownloadImage()
        }
        alertController.addAction(loadAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showChooseDoWithResult(at index: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            self.filterImagePresenter.tapSaveImage(at: index)
        }
        alertController.addAction(saveAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.filterImagePresenter.tapDeleteImage(at: index)
        }
        alertController.addAction(deleteAction)
        
        let reuseAction = UIAlertAction(title: "Reuse", style: .default) { (action) in
            self.filterImagePresenter.tapReuseImage(at: index)
        }
        alertController.addAction(reuseAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    func showImagePickerController(at type: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = type
        if type == .camera {
            imagePickerController.cameraCaptureMode = .photo
            imagePickerController.videoQuality = .typeHigh
            imagePickerController.showsCameraControls = true
        }
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func showError(at message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    func updateCell(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func insertCell(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.insertItems(at: [indexPath])
    }
    
    func deleteCell(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func showTextFieldAlert() {
        let alert = UIAlertController(title: "Enter image URL", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "image URL"
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                self.filterImagePresenter.downLoadImage(at: text)
            }
        }
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension FilterImaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterImagePresenter.filterImagesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        if let cell = cell as? FilterImageCollectionViewCell {
            cell.configure(filterImagePresenter.filterImageModel(indexPath.row))
        }
        return cell
    }
}

extension FilterImaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterImagePresenter.selectItem(at: indexPath.row)
    }
}

extension FilterImaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 200.0)
    }
}

extension FilterImaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            filterImagePresenter.loadImage(image.fixOrientation())
        } else {
            showError(at: "Ooooops...")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
