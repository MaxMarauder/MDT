//
//  ProductDetailsView.swift
//  MDT — Presentation / ProductDetails
//

import SwiftUI
import CachedAsyncImage
import Zoomable

// MARK: - ProductDetailsView
//
// Detail screen. Because its view model uses the `@Observable` macro (not
// `ObservableObject`), the ownership/binding wrappers differ from `ProductListView`:
//   - `@State` owns an `@Observable` object (instead of `@StateObject`).
//   - `@Bindable` produces bindings into it (instead of `$` on an `@ObservedObject`).
struct ProductDetailsView: View {

    // `@State` is how a view owns an `@Observable` reference type in iOS 17+.
    @State private var viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // `@Bindable` exposes two-way bindings (`$viewModel.noteText`) to an
        // `@Observable` object — the `@Observable` counterpart to `@ObservedObject`'s `$`.
        @Bindable var viewModel = viewModel
        let state = viewModel.viewState

        ZStack {
            CachedAsyncImage(url: state.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .zoomable()
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack {
                VStack(alignment: .leading) {
                    Text(state.name)
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 8)
                    Text(state.byBrandText)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color(.lightGray))
                    Text(state.priceText)
                        .font(.system(size: state.isDiscounted ? 12 : 16))
                        .strikethrough(state.isDiscounted)
                    if let discountedPriceText = state.discountedPriceText {
                        Text(discountedPriceText)
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
        // `.onChange` is the lifecycle hook that turns an edit into a persist call.
        // Keeping the trigger here (View) and the work in the view model keeps each
        // layer's responsibility clear.
        .onChange(of: viewModel.noteText) {
            viewModel.commitNote()
        }
    }
}
