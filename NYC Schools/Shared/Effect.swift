//
//  Event.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 03/12/22.
//

import Foundation

// wraps any async actions in to sync actions
struct Effect<Action> {
  let work: (@escaping (Action) -> Void) -> Void
  
  init(_ work: @escaping ( @escaping (Action) -> Void) -> Void) {
    self.work = work
  }
  
  func map<B>(_ t: @escaping (Action) -> B) -> Effect<B> {
    return Effect<B> { callback in
      self.work { action in callback(t(action)) }
    }
  }
}

extension Effect where Action == (Data?, URLResponse?, Error?) {
  func decode<Model: Decodable>(as type: Model.Type) -> Effect<Result<Model, Error>> {
    return self.map { data, response, error in
      if let error = error {
        return .failure(AppErrors.tripwire(error.localizedDescription))
      }
      guard let data = data else {
        return .failure(AppErrors.toDisplay("server error, try later"))
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      do {
        let models = try decoder.decode(Model.self, from: data)
        return .success(models)
      } catch (let error) {
        return .failure(AppErrors.fatal(error.localizedDescription))
      }
    }
  }
}

extension Effect {
  
  func performOn(on queue: DispatchQueue) -> Effect {
    return Effect { callback in
      self.work { action in
        queue.async {
          callback(action)
        }
      }
    }
  }
  
  // helper wrapping any network call in to Effect
  static func networkRequestWithURL(_ url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
    return Effect<(Data?, URLResponse?, Error?)> { callback in
      URLSession.shared.dataTask(with: url) { data, response, error in
        callback((data, response, error))
      }.resume()
    }
  }
}
