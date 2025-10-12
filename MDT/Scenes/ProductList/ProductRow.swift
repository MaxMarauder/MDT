//
//  ProductRow.swift
//  MDT
//
//  Created by Maksym Kershengolts on 11.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import SwiftUI
import CachedAsyncImage

struct ProductRow: View {
    var product: Product
    
    var body: some View {
        HStack(alignment: .top) {
            CachedAsyncImage(url: URL(string: product.image?.url ?? ""), content: { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }, placeholder: {
                ProgressView()
                    .frame(width: 120, height: 120)
            })
            VStack(alignment: .leading) {
                Text(product.name ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)
                Text(product.brand.flatMap { "by \($0)" } ?? "")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color(.lightGray))
                Text(String(format: "%.2f %@", product.originalPrice, product.currency ?? ""))
                    .font(.system(size: product.isDiscounted ? 12 : 16))
                    .strikethrough(product.isDiscounted)
                if (product.isDiscounted) {
                    Text(String(format: "%.2f %@", product.currentPrice, product.currency ?? ""))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.systemRed))
                }
                Text(product.note ?? "")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.systemBlue))
            }
            .padding(.leading, 8)
            Spacer()
        }
    }
}

#Preview {
    let product = ProductPreview()
    ProductRow(product: product)
}
