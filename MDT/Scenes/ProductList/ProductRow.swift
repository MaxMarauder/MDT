//
//  ProductRow.swift
//  MDT — Presentation / ProductList
//

import SwiftUI
import CachedAsyncImage

// MARK: - ProductRow
//
// A pure, "dumb" view: it receives a ready-to-render `ProductListItem` and binds
// its already-formatted strings to `Text`. No domain types and no formatting logic
// live here, which keeps the row trivially previewable (see `#Preview`) and keeps
// formatting testable without SwiftUI.
struct ProductRow: View {
    let item: ProductListItem

    var body: some View {
        HStack(alignment: .top) {
            CachedAsyncImage(url: item.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } placeholder: {
                ProgressView()
                    .frame(width: 120, height: 120)
            }

            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)
                Text(item.byBrandText)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color(.lightGray))
                Text(item.priceText)
                    .font(.system(size: item.isDiscounted ? 12 : 16))
                    .strikethrough(item.isDiscounted)
                if let discountedPriceText = item.discountedPriceText {
                    Text(discountedPriceText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.systemRed))
                }
                Text(item.noteText)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.systemBlue))
            }
            .padding(.leading, 8)

            Spacer()
        }
    }
}
