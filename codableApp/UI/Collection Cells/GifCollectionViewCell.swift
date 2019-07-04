//
//  gifCollectionViewCell.swift
//  codableApp
//
//  Created by or paztal on 02/07/2019.
//  Copyright © 2019 Or paz tal. All rights reserved.
//

import UIKit

class GifCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    static let identifier = "GifCollectionViewCell"
    var data: ItemMetaData?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        shouldDisplayIndicator(shouldDisplay: true)
        cellImageView.image = #imageLiteral(resourceName: "loading")
    }

    func configureCell(withData data: ItemMetaData, indexPath: IndexPath) {
        self.data = data
        
        GifDownloadManager.shared.downloadImage(data, indexPath: indexPath) {
            (image, url, indexPath, error) in
            if let indexPathNew = indexPath, indexPathNew == indexPath {
                DispatchQueue.main.async {
                    self.cellImageView.image = image
                    self.shouldDisplayIndicator(shouldDisplay: false)
                }
            }
        }
    }
    
    func shouldDisplayIndicator(shouldDisplay: Bool) {
        if shouldDisplay {
            indicator.startAnimating()
            cellImageView.image = #imageLiteral(resourceName: "loading")
        } else {
            indicator.stopAnimating()
        }
        indicator.isHidden = !shouldDisplay
    }
}
