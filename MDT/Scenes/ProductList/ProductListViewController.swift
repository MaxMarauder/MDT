//
//  ProductListViewController.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import Reusable
import AMScrollingNavbar

class ProductListViewController: UITableViewController, StoryboardBased, ViewModelBased {
    @IBOutlet private var searchBar: UISearchBar!

    var viewModel: ProductListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        viewModel.onProductsFetched = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.refresh() { }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 50.0)
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.refresh() {
            refreshControl.endRefreshing()
        }
    }
}

extension ProductListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            fatalError("Failed to dequeue ProductCell")
        }
        let product = viewModel.products[indexPath.row]
        cell.populate(with: product)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.openDetails(product: viewModel.products[indexPath.row])
    }
}

extension ProductListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(with: searchText)
    }
}
