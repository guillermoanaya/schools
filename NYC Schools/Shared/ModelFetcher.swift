//
//  ModelFetcher.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation

protocol ModelFetcher {
  associatedtype Model: Decodable
  func fetch(url: URL) -> Effect<Result<[Model], Error>>
}
