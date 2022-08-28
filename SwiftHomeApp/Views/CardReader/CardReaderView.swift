//
//  CardReaderView.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/28.
//

import SwiftUI
import Combine

struct CardReaderView: View {
    @ObservedObject private var viewModel = CardReaderViewModel()

    var body: some View {
        VStack {
            Button {
                viewModel.readCard()
            } label: {
                Text("Read Suica")
            }

            if !viewModel.suicaId.isEmpty {
                Text("SuicaID: \(viewModel.suicaId)")
                Button {
                    viewModel.postCardId()
                } label: {
                    Text("Post SuicaID")
                }
            }
        }
    }
}

struct CardReaderView_Previews: PreviewProvider {
    static var previews: some View {
        CardReaderView()
    }
}
