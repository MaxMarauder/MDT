//
//  ProductListView.swift
//  MDT
//
//  Created by Maksym Kershengolts on 11.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel
    
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.products, id: \.listID) { product in
                    NavigationLink {
                        viewModel.coordinator?.view(for: .productDetails(product: product))
                    } label: {
                        ProductRow(product: product)
                    }
                }
            }
            .listStyle(.plain)
            .animation(.default, value: viewModel.products)
            .navigationTitle("MDT")
            .navigationBarTitleDisplayMode(.inline)
        } detail: {
            Text("Select a product")
        }
        .refreshable {
            viewModel.refresh { }
        }
        .searchable(text: $viewModel.searchText)
    }
}

#Preview {
}
