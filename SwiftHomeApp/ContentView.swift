//
//  ContentView.swift
//  SwiftHomeApp
//
//  Created by 杉山優悟 on 2022/06/19.
//

import SwiftUI

enum PageType: String, CaseIterable, Identifiable {
    case sensorConfig
    case cardReaderView
    case statusView

    var id: String {
        return rawValue
    }

    var title: String {
        switch self {
        case .sensorConfig:
            return "Device Info"
        case .cardReaderView:
            return "NFC Reader"
        case .statusView:
            return "Status"
        }
    }

    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .sensorConfig:
            DeviceInfoView()
        case .cardReaderView:
            CardReaderView()
        case .statusView:
            StatusView()
        }
    }
}

struct ContentView: View {
    var body: some View {
            VStack {
                List {
                    ForEach(PageType.allCases) { type in
                        NavigationLink {
                            type.destinationView
                        } label: {
                            Text(type.title)
                        }
                    }
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("SwiftHome")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
