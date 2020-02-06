//
//  ProductCell.swift
//  MDT
//
//  Created by Maksym Kershengolts on 20.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    @IBOutlet private var imgView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var brandLabel: UILabel!
    @IBOutlet private var originalPriceLabel: UILabel!
    @IBOutlet private var currentPriceLabel: UILabel!
    @IBOutlet private var noteLabel: UILabel!

    override func prepareForReuse() {
        nameLabel.text = nil
        brandLabel.text = nil
        originalPriceLabel.text = nil
        currentPriceLabel.text = nil
        noteLabel.text = nil
        imgView.image = nil
    }

    func populate(with product: Product) {
        nameLabel.text = product.name
        brandLabel.text = product.brand.flatMap { "by \($0)" }
        originalPriceLabel.text = String(format: "%.2f %@", product.originalPrice, product.currency ?? "")
        currentPriceLabel.text = String(format: "%.2f %@", product.currentPrice, product.currency ?? "")
        currentPriceLabel.isHidden = (product.originalPrice == product.currentPrice)
        noteLabel.text = product.note
        product.downloadImage { [weak self] image in
            self?.imgView.image = image
        }
    }
}
