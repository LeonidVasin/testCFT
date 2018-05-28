//
//  FilterImageViewData.swift
//  test CFT
//
//  Created by Leonid on 27.05.2018.
//  Copyright © 2018 Leonid Team. All rights reserved.
//

import UIKit

struct FilterImageViewData {
    var image: UIImage?
    var procent: Float
    var index: Int64
}

extension FilterImageViewData: Equatable {
    static func ==(lhs: FilterImageViewData, rhs: FilterImageViewData) -> Bool {
        if lhs.index == rhs.index {
            return true
        } else {
            return false
        }
    }
}
