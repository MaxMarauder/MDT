//
//  Coordinator.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit

protocol CoordinatorType: class {
    var children: [CoordinatorType] { get set }
    var repositories: Repositories { get }
    var rootController: UIViewController { get }
    func navigate(to state: AppState)
}

protocol ChildCoordinatorType: CoordinatorType {
    var parent: CoordinatorType { get }
    func removeFromParent()
}

extension ChildCoordinatorType {
    var repositories: Repositories {
        return parent.repositories
    }

    func removeFromParent() {
        parent.children = parent.children.filter { $0 !== self }
    }
}

protocol Coordinated {
    var coordinator: CoordinatorType? { get }
}
