//
//  FilterImageCollectionViewCell.swift
//  test CFT
//
//  Created by Leonid on 27.05.2018.
//  Copyright © 2018 Leonid Team. All rights reserved.
//

import UIKit

class FilterImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    func configure(_ model: FilterImageViewData?) {
        if let model = model {
            if let image = model.image {
                imageView.image = image
                imageView.isHidden = false
                progressView.isHidden = true
            } else {
                progressView.progress = model.procent
                progressView.isHidden = false
                imageView.isHidden = true
            }
        } else {
            imageView.image = nil
            progressView.progress = 0
        }
    }
}
