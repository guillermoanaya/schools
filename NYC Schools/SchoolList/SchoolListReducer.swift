//
//  SchoolListReducer.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation

enum SchoolListActions {
  case fetchSchools(limit: Int, offset: Int)
  case schoolsLoaded(results: [SchoolModel])
  case errorLoading(e: Error)
  case listCompleted
  case loadSAT(dbn: String)
  case satLoaded(model: SATModel?)
}

struct SchoolListState {
  var schoolList: [SchoolModel]
  var errorToDisplay: String?
  var listCompleted: Bool
  var selectedSat: SATModel?
  
  static let initial = SchoolListState(schoolList: [], listCompleted: false)
}

enum SchoolListReducer {
  
  static func schoolListReducer(_ state: inout SchoolListState,
                                _ action: SchoolListActions,
                                _ enviroment: SchoolListEnviroment) -> [Effect<SchoolListActions>] {
    switch action {
    case .fetchSchools(let limit, let offset):
      guard let stringUrl = enviroment.schoolListEndpoint(limit: limit, offset: offset) else {
        return [Effect<SchoolListActions> { callback in
          callback(SchoolListActions.errorLoading(e: AppErrors.tripwire("invalid limit or offset")))
        }]
      }
      let url = URL(string: stringUrl)!
      return [enviroment.schoolModelFetcher(url).map { result in
        switch result {
        case .failure(let error):
          return .errorLoading(e: error)
        case .success(let results):
          if results.isEmpty {
            return .listCompleted
          }
          return .schoolsLoaded(results: results)
        }
      }]
    case .schoolsLoaded(let schools):
      state.schoolList += schools
    case .listCompleted:
      state.listCompleted = true
    case .loadSAT(let dbn):
      let url = URL(string: enviroment.schoolSATEndpoint(dbn: dbn))!
      return [
        enviroment.satModelFetcher(url).map({ result in
          switch result {
          case .success(let satModel):
            return .satLoaded(model: satModel.first)
          case .failure(let error):
            return .errorLoading(e: error)
          }
        })
      ]
    case .satLoaded(let model):
      state.selectedSat = model
      if model == nil {
        return [Effect { callback in
          callback(SchoolListActions.errorLoading(e: AppErrors.toDisplay("school dont have SAT")))
        }]
      }
    case .errorLoading(let error):
      if let error = error as? AppErrors {
        switch error {
        case .tripwire(let errorMessage):
          // TODO: log in to a real log system
          print("[mustfix]log: ", errorMessage)
          state.errorToDisplay = "An error occurred, we are looking at it"
        case .fatal(let errorMessage):
          print("[fatal]log: ", errorMessage!)
          // if fatal lets crash!!
          fatalError()
        case .toDisplay(let errorMessage):
          // error to bubble up to user
          state.errorToDisplay = errorMessage
        }
      }
      print(error)
    }
    
    return []
  }
}
