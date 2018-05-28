//
//  FilterImageUrlSession.swift
//  test CFT
//
//  Created by Leonid on 28.05.2018.
//  Copyright © 2018 Leonid Team. All rights reserved.
//

import UIKit

class FilterImageUrlSession: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var compeletion: ((UIImage?) -> Void)?
    var progress: ((Float) -> Void)?
    
    init(url: URL) {
        super.init()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            if let compeletionHundler = compeletion {
                let data = try Data(contentsOf: location)
                let image = UIImage(data: data)
                compeletionHundler(image)
            }
        } catch {
            if let compeletionHundler = compeletion {
                compeletionHundler(nil)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let progressHundler = progress {
            let procent = Float(Float64(bytesWritten)/Float64(totalBytesWritten))
            progressHundler(procent)
        }
    }
    
}
