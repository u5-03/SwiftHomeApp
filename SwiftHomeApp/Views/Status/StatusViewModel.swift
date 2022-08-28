//
//  StatusViewModel.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/29.
//

import Foundation
import SwiftHomeCredentials
import SwiftHomeCore
import Vapor

final class StatusViewModel: ObservableObject {
    @Published private(set) var isInHome = false
    @Published private(set) var isRaspiberryPiOnline = false
    private let serverConfig: ServerConfiguration = .server
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    private var inHomeWebSocket: WebSocket?
    private var isRaspberryPiOnlineWebSocket: WebSocket?

    func setup() {
        let basicAuthentication = SwiftHomeCredentials.basicAuthentication
        let plainString = "\(basicAuthentication.id):\(basicAuthentication.password)".data(using: String.Encoding.utf8)
        let credential = plainString?.base64EncodedString(options: [])
        let headers: Vapor.HTTPHeaders = [
            "Authorization": "Basic \(credential!)"
        ]
        _ = WebSocket.connect(to: "\(serverConfig.URLString(type: .webSocket))/\(EndPointKind.isInHome.webSocketEndPoint)", headers: headers, on: eventLoopGroup) { [weak self] ws in
            guard let self = self else { return }
            // Called when App-Server WebSocket is connected.
            self.inHomeWebSocket = ws
            ws.onText { ws, text in
                self.isInHome = text == WebSocketStatus.inHome.rawValue
            }
        }
        _ = WebSocket.connect(to: "\(serverConfig.URLString(type: .webSocket))/\(EndPointKind.isWebSocketOnline.webSocketEndPoint)", headers: headers, on: eventLoopGroup) { [weak self] ws in
            guard let self = self else { return }
            // Called when App-Server WebSocket is connected.
            self.isRaspberryPiOnlineWebSocket = ws
            ws.onText { ws, text in
                self.isRaspiberryPiOnline = text == WebSocketStatus.piOnline.rawValue
            }
        }
    }

    func onClose() {
        _ = inHomeWebSocket?.close()
        _ = isRaspberryPiOnlineWebSocket?.close()
    }
}
