//
//  FilterImageService.swift
//  test CFT
//
//  Created by Leonid on 27.05.2018.
//  Copyright © 2018 Leonid Team. All rights reserved.
//

import UIKit
import CoreData

class FilterImageModel {
    var timer: Timer?
    var compeletion: ((UIImage?) -> Void)?
    var progress: ((Float) -> Void)?
    var image: UIImage?
    var allTimeRender: Float = 0.0
    var currentTimeRender: Float = 0.0
}

class FilterImageService {
    
    fileprivate let timeInterval: Float = 0.3
    
    fileprivate func getRandomTime() -> Float {
        return Float(arc4random_uniform(26)) + 5
    }
    
    func loadImage(at url:URL, completionHandler: @escaping (UIImage?) -> Void, progressHandler: @escaping (Float) -> Void) {
        let urlSession = FilterImageUrlSession(url: url)
        urlSession.compeletion = completionHandler
        urlSession.progress = progressHandler
    }
    
    func applyRotateFilter(_ image: UIImage, completionHandler: @escaping (UIImage?) -> Void, progressHandler: @escaping (Float) -> Void) {
        
        let model = FilterImageModel()
        DispatchQueue.main.async {
            let timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(self.timerHundler(timer:)), userInfo: model, repeats: true)
            model.timer = timer
        }
        model.compeletion = completionHandler
        model.allTimeRender = getRandomTime()
        model.progress = progressHandler
        
        let size = image.size
        let rotatedSize = CGSize(width: size.height, height: size.width)
        
        UIGraphicsBeginImageContext(rotatedSize)
        if let bitmap: CGContext = UIGraphicsGetCurrentContext() {
            bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            bitmap.rotate(by: (90.0 * .pi / 180.0))
            bitmap.scaleBy(x: 1.0, y: -1.0)
            
            let origin = CGPoint(x: -size.width / 2, y: -size.height / 2)
            if let cgImage = image.cgImage {
                bitmap.draw(cgImage, in: CGRect(origin: origin, size: size))
                let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                bitmap.clear(CGRect(origin: origin, size: rotatedSize))
                UIGraphicsEndImageContext()
                model.image = newImage
            } else {
                UIGraphicsEndImageContext()
            }
        } else {
            UIGraphicsEndImageContext()
        }
    }
    
    func applyBlackWhiteFilter(_ image: UIImage, completionHandler: @escaping (UIImage?) -> Void, progressHandler: @escaping (Float) -> Void) {
        let model = FilterImageModel()
        DispatchQueue.main.async {
            let timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(self.timerHundler(timer:)), userInfo: model, repeats: true)
            model.timer = timer
        }
        
        model.compeletion = completionHandler
        model.allTimeRender = getRandomTime()
        model.progress = progressHandler
        
        if let filter = CIFilter(name: "CIPhotoEffectMono") {
            let ciInput = CIImage(image: image)
            filter.setValue(ciInput, forKey: "inputImage")
            
            if let ciOutput = filter.outputImage {
                let ciContext = CIContext(options: nil)
                if let cgImage = ciContext.createCGImage(ciOutput, from: ciOutput.extent) {
                    model.image = UIImage(cgImage: cgImage)
                }
            }
        }
    }
    
    func applyMirrorFilter(_ image: UIImage, completionHandler: @escaping (UIImage?) -> Void, progressHandler: @escaping (Float) -> Void) {
        let model = FilterImageModel()
        DispatchQueue.main.async {
            let timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(self.timerHundler(timer:)), userInfo: model, repeats: true)
            model.timer = timer
        }
        model.compeletion = completionHandler
        model.allTimeRender = getRandomTime()
        model.progress = progressHandler
        
        let size = image.size
        UIGraphicsBeginImageContext(size)
        if let bitmap: CGContext = UIGraphicsGetCurrentContext() {
            bitmap.translateBy(x: size.width, y: size.height)
            bitmap.scaleBy(x: -1.0, y: -1.0)
            
            if let cgImage = image.cgImage {
                bitmap.draw(cgImage, in: CGRect(origin: .zero, size: size))
                
                let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                model.image = newImage
            }
        }
    }
    
    @objc func timerHundler(timer: Timer) {
        if let filterImageModel = timer.userInfo as? FilterImageModel {
            filterImageModel.currentTimeRender += timeInterval
            if filterImageModel.currentTimeRender >= filterImageModel.allTimeRender {
                if let completionHundler = filterImageModel.compeletion {
                    completionHundler(filterImageModel.image)
                }
                timer.invalidate()
            }
            
            let progress = filterImageModel.currentTimeRender/filterImageModel.allTimeRender
            if let progressHundler = filterImageModel.progress {
                progressHundler(progress)
            }
        } else {
            timer.invalidate()
        }
    }
    
    func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func getImages() -> [FilterImageEntity] {
        var array: [FilterImageEntity] = []
        let request = NSFetchRequest<FilterImageEntity>(entityName: "FilterImageEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            array = try DataBase.instance.managedObjectContext.fetch(request)
        } catch {
        }
        
        return array
    }
    
    func insertImage(_ image: UIImage, id: Int64) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FilterImageEntity", in: DataBase.instance.managedObjectContext) else {
            return
        }
        let filterImageEntity = FilterImageEntity(entity: entity, insertInto: DataBase.instance.managedObjectContext)
        filterImageEntity.image = UIImagePNGRepresentation(image)
        filterImageEntity.id = id
        DataBase.instance.saveContext()
    }
    
    func deleteImage(at id: Int64) {
        var array: [FilterImageEntity] = []
        let request = NSFetchRequest<FilterImageEntity>(entityName: "FilterImageEntity")
        let predicate = NSPredicate(format: "id == %d", id)
        request.predicate = predicate
        do {
            array = try DataBase.instance.managedObjectContext.fetch(request)
        } catch {
        }
        for filterImageEntity in array {
            DataBase.instance.managedObjectContext.delete(filterImageEntity)
        }
        DataBase.instance.saveContext()
    }
}
