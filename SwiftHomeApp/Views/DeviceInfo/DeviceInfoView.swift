//
//  DeviceInfoView.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/13.
//

import SwiftUI

struct DeviceInfoView: View {
    @ObservedObject private var viewModel = DeviceInfoViewModel()

    func listItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .regular))
            Text(value)
                .font(.system(size: 18, weight: .regular))
                .padding(.leading, 4)
        }
    }

    var body: some View {
        List {
            Section {
                listItem(title: "Latitude", value: String(viewModel.userCoordinate.latitude))
                listItem(title: "Longitude", value: String(viewModel.userCoordinate.longitude))
            } header: {
                Text("Location information")
            }
            Section {
                listItem(title: "Absolute Altimeter", value: String(viewModel.absoluteAltimeterValue))
                listItem(title: "Relative Altimeter", value: String(viewModel.relativeAltimeterValue))
                listItem(title: "Atmospheric Pressure", value: String(viewModel.atmosphericPressure))
            } header: {
                Text("Altitude information")
            }

            Section {
                listItem(title: "Saved Latitude", value: String(viewModel.savedUserCoordinate.latitude))
                listItem(title: "Saved Longitude", value: String(viewModel.savedUserCoordinate.longitude))
                listItem(title: "Saved Absolute Altimeter", value: String(viewModel.savedAbsoluteAltimeterValue))
            } header: {
                Text("Saved information")
            }

            Button {
                viewModel.saveData()
            } label: {
                Text("Save Data")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Button {
                viewModel.resetSavedData()
            } label: {
                Text("Reset Data")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Device Info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.onClose()
        }
    }
}

struct DeviceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoView()
    }
}
