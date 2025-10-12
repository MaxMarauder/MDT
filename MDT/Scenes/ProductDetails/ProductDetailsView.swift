//
//  ProductDetailsView.swift
//  MDT
//
//  Created by Maksym Kershengolts on 11.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import SwiftUI
import CachedAsyncImage
import Zoomable

struct ProductDetailsView: View {
    @StateObject var viewModel: ProductDetailsViewModel
    
    var body: some View {
        ZStack {
            CachedAsyncImage(url: URL(string: viewModel.product.image?.url ?? ""), content: { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .zoomable()
            }, placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
            VStack {
                VStack(alignment: .leading) {
                    Text(viewModel.product.name ?? "")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 8)
                    Text(viewModel.product.brand.flatMap { "by \($0)" } ?? "")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color(.lightGray))
                    Text(String(format: "%.2f %@", viewModel.product.originalPrice, viewModel.product.currency ?? ""))
                        .font(.system(size: viewModel.product.isDiscounted ? 12 : 16))
                        .strikethrough(viewModel.product.isDiscounted)
                    if (viewModel.product.isDiscounted) {
                        Text(String(format: "%.2f %@", viewModel.product.currentPrice, viewModel.product.currency ?? ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.systemRed))
                    }
                    TextField("Add a note", text: $viewModel.noteText)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.systemBlue))
                        .textFieldStyle(.roundedBorder)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color(.init(white: 1.0, alpha: 0.7)))
                .border(Color(.lightGray), width: 1)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
    }
}

#Preview {
}
