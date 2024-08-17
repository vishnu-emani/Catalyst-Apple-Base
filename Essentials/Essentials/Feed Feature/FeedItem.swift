//
//  FeedItem.swift
//  Essentials
//
//  Created by Vishnu on 09/08/24.
//

import Foundation


public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
