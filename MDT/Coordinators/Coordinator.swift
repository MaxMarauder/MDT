//
//  Coordinator.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import SwiftUI

protocol CoordinatorType: AnyObject {
    var children: [CoordinatorType] { get set }
    var repositories: Repositories { get }
    var rootView: AnyView { get }
    
    func view(for state: AppState) -> AnyView
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
