//
//  FilterImagePresenter.swift
//  test CFT
//
//  Created by Leonid on 27.05.2018.
//  Copyright © 2018 Leonid Team. All rights reserved.
//

import UIKit

enum Filter:Int {
    case rotate, blackWhite, mirror
}

protocol FilterImageView: NSObjectProtocol {
    func startLoadImage()
    func setLoadingImage(_ procent: Float)
    func stopLoadingImage()
    
    func setOriginalImage(_ image: UIImage)
    
    func updateFilterImagesData()
    
    func showChooseImageDataProvider()
    func showImagePickerController(at type: UIImagePickerControllerSourceType)
    func showTextFieldAlert()
    func showChooseDoWithResult(at index: Int)
    
    func showError(at message: String)
    
    func updateCell(_ index: Int)
    func insertCell(_ index: Int)
    func deleteCell(_ index: Int)
}

class FilterImagePresenter {
    
    fileprivate let filterImageService: FilterImageService
    weak fileprivate var filterImageView : FilterImageView?
    fileprivate var filterImagesToDisplay = [FilterImageViewData]()
    var originalImage: UIImage?
    
    fileprivate var maxIndex: Int64
    
    init(_ filterImageService:FilterImageService) {
        self.filterImageService = filterImageService
        maxIndex = 0
    }
    
    func viewIsReady() {
        filterImagesToDisplay = filterImageService.getImages().compactMap { filterImageEntity -> FilterImageViewData? in
            if let data = filterImageEntity.image {
                let filterImageViewData = FilterImageViewData(image: UIImage(data: data), procent: 0.0, index: maxIndex)
                if filterImageEntity.id >= maxIndex {
                    maxIndex = filterImageEntity.id
                }
                return filterImageViewData
            } else {
                return nil
            }
        }
        filterImageView?.updateFilterImagesData()
    }
    
    func attachView(_ view:FilterImageView){
        filterImageView = view
    }
    
    func detachView() {
        filterImageView = nil
    }
    
    func filterImagesCount() -> Int {
        return filterImagesToDisplay.count
    }
    
    func filterImageModel(_ index: Int) -> FilterImageViewData? {
        if index > filterImagesToDisplay.count {
            return nil
        }
        return filterImagesToDisplay[index]
    }
    
    func downLoadImage(at text: String) {
        if let url = URL(string: text) {
            filterImageView?.startLoadImage()
            filterImageService.loadImage(at: url, completionHandler: { image in
                DispatchQueue.main.async {
                    if let image = image {
                        self.filterImageView?.setOriginalImage(image)
                    } else {
                        self.filterImageView?.showError(at: "Oooops...")
                    }
                    self.filterImageView?.stopLoadingImage()
                }
            }) { procent in
                DispatchQueue.main.async {
                    self.filterImageView?.setLoadingImage(procent)
                }
            }
        } else {
            filterImageView?.showError(at: "Ooooops...")
        }
    }
    
    func addImage() {
        filterImageView?.showChooseImageDataProvider()
    }
    
    func selectDataProvider(at type: UIImagePickerControllerSourceType) {
        filterImageView?.showImagePickerController(at: type)
    }
    
    func loadImage(_ image: UIImage) {
        originalImage = image
        filterImageView?.setOriginalImage(image)
    }
    
    func getFilterName(_ tag: Int) -> String {
        if let filter = Filter(rawValue: tag) {
            switch filter {
            case .rotate:
                return "Rotate"
            case .blackWhite:
                return "Black&White"
            case .mirror:
                return "Mirror"
            }
        }
        return ""
    }
    
    func applyFilter(_ tag: Int) {
        if let image = originalImage {
            if let filter = Filter(rawValue: tag) {
                var filterImageViewData = FilterImageViewData(image: nil, procent: 0.0, index: self.maxIndex)
                self.maxIndex += 1
                self.filterImagesToDisplay.insert(filterImageViewData, at: 0)
                self.filterImageView?.insertCell(0)
                switch filter {
                case .rotate:
                    DispatchQueue.global(qos: .default).async {
                        self.filterImageService.applyRotateFilter(image, completionHandler: { newImage in
                            self.updateImage(&filterImageViewData, newImage: newImage)
                        }, progressHandler: { progress in
                            self.updateProgress(&filterImageViewData, progress: progress)
                        })
                    }
                    break
                case .blackWhite:
                    DispatchQueue.global(qos: .default).async {
                        self.filterImageService.applyBlackWhiteFilter(image, completionHandler: { newImage in
                            self.updateImage(&filterImageViewData, newImage: newImage)
                        }, progressHandler: { progress in
                            self.updateProgress(&filterImageViewData, progress: progress)
                        })
                    }
                    break
                case .mirror:
                    DispatchQueue.global(qos: .default).async {
                        self.filterImageService.applyMirrorFilter(image, completionHandler: { newImage in
                            self.updateImage(&filterImageViewData, newImage: newImage)
                        }, progressHandler: { progress in
                            self.updateProgress(&filterImageViewData, progress: progress)
                        })
                    }
                    break
                }
            } else {
                filterImageView?.showError(at: "Oooops...")
            }
        } else {
            filterImageView?.showError(at: "Please, add image")
        }
    }
    
    private func updateImage( _ filterImageViewData: inout FilterImageViewData, newImage: UIImage?) {
        if let index = self.filterImagesToDisplay.index(of: filterImageViewData) {
            if let newImage = newImage {
                filterImageViewData.image = newImage
                self.filterImagesToDisplay[index] = filterImageViewData
                self.filterImageView?.updateCell(index)
                self.filterImageService.insertImage(newImage, id: filterImageViewData.index)
            } else {
                self.filterImageView?.showError(at: "Oooops...")
                if let index = self.filterImagesToDisplay.index(of: filterImageViewData) {
                    self.filterImagesToDisplay.remove(at: index)
                }
            }
        }
    }
    
    private func updateProgress( _ filterImageViewData: inout FilterImageViewData, progress: Float) {
        if let index = self.filterImagesToDisplay.index(of: filterImageViewData) {
            filterImageViewData.procent = progress
            self.filterImagesToDisplay[index] = filterImageViewData
            self.filterImageView?.updateCell(index)
        }
    }
    
    func selectItem(at index: Int) {
        filterImageView?.showChooseDoWithResult(at: index)
    }
    
    func tapSaveImage(at index: Int) {
        if let image = filterImageModel(index)?.image {
            filterImageService.saveImage(image)
        } else {
            filterImageView?.showError(at: "Image not load")
        }
    }
    
    func tapReuseImage(at index: Int) {
        if let image = filterImageModel(index)?.image {
            filterImageView?.setOriginalImage(image)
            originalImage = image
        } else {
            filterImageView?.showError(at: "Image not load")
        }
    }
    
    func tapDeleteImage(at index: Int) {
        if index < filterImagesToDisplay.count {
            let filterImageViewData = filterImagesToDisplay[index]
            let id = filterImageViewData.index
            filterImageService.deleteImage(at: id)
            filterImagesToDisplay.remove(at: index)
            filterImageView?.deleteCell(index)
        } else {
            filterImageView?.showError(at: "Oooops...")
        }
    }
    
    func selectDownloadImage() {
        filterImageView?.showTextFieldAlert()
    }
}
