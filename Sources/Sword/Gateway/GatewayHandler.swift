//
//  GatewayHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import NIOWebSocket
import NIOWebSocketClient
import NIOSSL

/// Represents a WebSocket session for Discord
protocol GatewayHandler : AnyObject {
  /// Internal WebSocket session
  var session: WebSocketClient.Socket? { get set }

  /// Sword class
  var sword: Sword { get }
  
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to host: String)
  
  /// Disconnects the handler from the gateway
  func disconnect()
  
  /// Defines what to when data is received as binary
  ///
  /// - parameter data: The data that was received from the gateway
  func handleBinary(_ data: Data)
  
  /// Defines what to do when the gateway closes on us
  func handleClose(_ error: WebSocketErrorCode)
  
  /// Defines what to do when data is received as text
  ///
  /// - parameter text: The String that was received from the gateway
  func handleText(_ text: String)
  
  /// Reconnects the handler to the gateway
  func reconnect()
  
  func didConnect()
}

extension GatewayHandler {
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to urlString: String) {
    guard let url = URL(string: urlString), let host = url.host else {
      Sword.log(.error, .invalidURL(urlString))
      return
    }
    
    print("connect: \(urlString)")
    
    var config = WebSocketClient.Configuration(maxFrameSize: 1 << 31)
    
    func _isSSL() -> Bool {
      return url.scheme == "wss"
    }
    
    let isSSL = _isSSL()
    
    func _port() -> Int {
      if let port = url.port {
        return port
      }
      if isSSL {
        return 443
      } else {
        return 80
      }
    }
    
    let port = _port()
    
    config.tlsConfiguration = TLSConfiguration.forClient()
    
    let client = WebSocketClient(
      eventLoopGroupProvider: .shared(sword.worker),
      configuration: config
    )
    
    let ws = client.connect(
      host: host,
      port: port,
      uri: url.absoluteString
    ) { [unowned self] ws in
        print("onUpgrade")
      self.session = ws
      
      ws.onBinary { _, data in
        self.handleBinary(Data(data))
      }
      
      ws.onCloseCode { code in
        self.handleClose(code)
      }
      
      ws.onText { _, text in
        self.handleText(text)
      }
      
      self.didConnect()
    }
    _ = ws
  }
  
  /// Disconnects the handler from the gateway
  func disconnect() {
    session?.close(promise: nil)
    session = nil
  }
}
