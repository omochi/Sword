//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import NIOHTTPClient

extension Sword {
  static let apiVersion = "v7"
  
  static let version = "1.0.0"
}

extension Sword {
  /// Makes an HTTP Request to the land of Discord's API
  ///
  /// - parameter endpoint: The specific endpoint to request
  func request(
    _ endpoint: Endpoint,
    then: @escaping (Sword, Result<Data, Sword.Error>) -> ()
  ) throws {
    var request = try HTTPClient.Request(
      url: endpoint.url,
      method: endpoint.method
    )
    
    request.headers.add(
      name: "User-Agent",
      value: "DiscordBot (https://github.com/Azoy/Sword, \(Sword.version))"
    )
    
    request.headers.add(name: "Authorization", value: "Bot \(token)")
    
    let client = HTTPClient(eventLoopGroupProvider: .shared(worker))
    
    client.execute(request: request).whenComplete { [unowned self] result in
      switch result {
      case .failure(let error):
        then(self, .failure(Sword.Error(error.localizedDescription)))
      case .success(let response):
        guard let body = response.body else {
            then(self, .success(Data()))
            return
        }
        
        let dpData = body.getDispatchData(at: 0, length: body.readableBytes)!
        let data = dpData as AnyObject as! Data
        then(self, .success(data))
      }
    }
  }
  
  func handleRequestError(_ error: Swift.Error) {
    
  }
  
  func handleRequestResponse(_ response: HTTPClient.Response) {
    
  }
}
