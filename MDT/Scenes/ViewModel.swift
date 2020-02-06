//
//  ViewModel.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import Reusable

protocol ViewModel: Coordinated {
}

protocol ViewModelBased: class {
    associatedtype T: ViewModel
    var viewModel: T! { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
    static func instantiate(with viewModel: T) -> Self {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
