//
//  SchoolListEnviroment.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation



// manage specific logic like network request, etc
struct SchoolListEnviroment {
  
  func schoolListEndpoint(limit: Int, offset: Int) -> String? {
    guard limit > 0 || offset >= 0 else { return nil }
    return "https://data.cityofnewyork.us/resource/s3k6-pzi2.json?$limit=\(limit)&$offset=\(offset)"
  }
  
  func schoolSATEndpoint(dbn: String) -> String {
    return "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?dbn=\(dbn)"
  }
  
  var schoolModelFetcher: (_ url: URL) -> Effect<Result<[SchoolModel], Error>>
  var satModelFetcher: (_ url: URL) -> Effect<Result<[SATModel], Error>>
  
  // we can have other enviroments with different enpoint and configs, like dev, or test
  static func prod() -> SchoolListEnviroment {
    let prodFetcher = SchoolListFetcher()
    return SchoolListEnviroment(schoolModelFetcher: prodFetcher.fetch, satModelFetcher: SATModelFetcher().fetch)
  }
  
}

// concrete prod implementation to fetch scrools
struct SchoolListFetcher: ModelFetcher {
  typealias Model = SchoolModel
  
  func fetch(url: URL) -> Effect<Result<[SchoolModel], Error>> {
    return
      .networkRequestWithURL(url)
      .decode(as: [SchoolModel].self)
      .performOn(on: .main)
  }
}

// concrete prod implementation to fetch SAT score
struct SATModelFetcher: ModelFetcher {
  typealias Model = SATModel
  
  func fetch(url: URL) -> Effect<Result<[SATModel], Error>> {
    return
      .networkRequestWithURL(url)
      .decode(as: [SATModel].self)
      .performOn(on: .main)
  }
}
