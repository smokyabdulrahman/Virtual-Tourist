//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by ABDULRAHMAN ALRAHMA on 2/2/19.
//  Copyright © 2019 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.kf.indicatorType = .activity
    }
}
