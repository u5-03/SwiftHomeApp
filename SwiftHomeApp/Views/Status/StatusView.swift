//
//  StatusView.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/29.
//

import SwiftUI

struct StatusView: View {
    private let viewModel = StatusViewModel()

    var body: some View {
        VStack {
            Text("\(viewModel.isInHome ? "in Home" : "not in Home")")
            Text("\(viewModel.isRaspiberryPiOnline ? "RaspberryPi connected" : "RaspberryPi not connected")")
        }
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.onClose()
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
    }
}
