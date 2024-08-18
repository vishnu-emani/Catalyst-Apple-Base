//
//  HttpClient.swift
//  Essentials
//
//  Created by Vishnu on 18/08/24.
//

import Foundation

public enum HttpClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HttpClient {
    func get(requestedURL: URL, completion: @escaping(HttpClientResult) -> Void)
}
