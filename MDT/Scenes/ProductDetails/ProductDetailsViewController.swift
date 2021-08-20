//
//  ProductDetailsViewController.swift
//  MDT
//
//  Created by Maksym Kershengolts on 20.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import Reusable
import AMScrollingNavbar

final class ProductDetailsViewController: UIViewController, StoryboardBased, ViewModelBased, UIScrollViewDelegate {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imgView: UIImageView!
    @IBOutlet private var infoView: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var brandLabel: UILabel!
    @IBOutlet private var originalPriceLabel: UILabel!
    @IBOutlet private var currentPriceLabel: UILabel!
    @IBOutlet private var noteTextField: UITextField!

    var viewModel: ProductDetailsViewModel!
    var onNoteEdited: ((String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        infoView.layer.cornerRadius = 5.0
        infoView.layer.borderColor = UIColor.lightGray.cgColor
        infoView.layer.borderWidth = 1.0
        nameLabel.text = viewModel.product.name
        brandLabel.text = viewModel.product.brand.flatMap { "by \($0)" }
        originalPriceLabel.text = String(format: "%.2f %@", viewModel.product.originalPrice, viewModel.product.currency ?? "")
        currentPriceLabel.text = String(format: "%.2f %@", viewModel.product.currentPrice, viewModel.product.currency ?? "")
        currentPriceLabel.isHidden = (viewModel.product.originalPrice == viewModel.product.currentPrice)
        noteTextField.text = viewModel.product.note
        viewModel.product.downloadImage { [weak self] image in
            self?.imgView.image = image
            self?.updateZoom()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.showNavbar()
        }
    }
    
    private func updateZoom() {
        guard let image = imgView.image else {
            return
        }
        let containerSize = self.scrollView.bounds.size
        let scaleH = containerSize.width / image.size.width
        let scaleV = containerSize.height / image.size.height
        self.scrollView.minimumZoomScale = min(scaleH, scaleV, 1)
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        let insetH = containerSize.width * (1 - min(scaleV / scaleH, 1)) / 2
        let insetV = containerSize.height * (1 - min(scaleH / scaleV, 1)) / 2
        self.scrollView.contentInset = UIEdgeInsets(top: insetV, left: insetH, bottom: insetV, right: insetH)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
}

extension ProductDetailsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.set(note: textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
