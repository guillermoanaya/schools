//
//  NYC_SchoolsTests.swift
//  NYC SchoolsTests
//
//  Created by Guillermo Anaya on 03/12/22.
//

import XCTest
@testable import NYC_Schools

extension SchoolListEnviroment {
  static func testWithSuccess() -> SchoolListEnviroment {
    let schoolModel = SchoolModel(name: "name", dbn: "dbn")
    let satModel = SATModel(readingScore: "99", writingScore: "99", mathScore: "99")
    return SchoolListEnviroment { url in
      Effect<Result<[SchoolModel], Error>> { callback in
        callback(.success([schoolModel]))
      }
    } satModelFetcher: { url in
      Effect<Result<[SATModel], Error>> { callback in
        callback(.success([satModel]))
      }
    }
  }
  
  static func testWithTripWireErrorLoading() -> SchoolListEnviroment {
    return SchoolListEnviroment { url in
      Effect<Result<[SchoolModel], Error>> { callback in
        callback(.failure(AppErrors.tripwire("Error loading Schools")))
      }
    } satModelFetcher: { url in
      Effect<Result<[SATModel], Error>> { callback in
        callback(.failure(AppErrors.tripwire("Error loading SAT")))
      }
    }
  }
  
  static func testWithErrorToDisplayWhileLoading() -> SchoolListEnviroment {
    return SchoolListEnviroment { url in
      Effect<Result<[SchoolModel], Error>> { callback in
        callback(.failure(AppErrors.toDisplay("Error loading Schools")))
      }
    } satModelFetcher: { url in
      Effect<Result<[SATModel], Error>> { callback in
        callback(.failure(AppErrors.toDisplay("Error loading SAT")))
      }
    }
  }
  
  
}

class NYC_SchoolsTests: XCTestCase {

  func testWithSuccess() {
    
    // inject testWithSuccess
    let store = Store(reducer: SchoolListReducer.schoolListReducer, initState: .initial, enviroment: .testWithSuccess())
    
    XCTAssert(store.state.schoolList.count == 0)
    XCTAssertNil(store.state.selectedSat)
    
    // fetch schools
    store.dispatch(.fetchSchools(limit: 1, offset: 0))
    
    XCTAssert(store.state.schoolList.count == 1)
    XCTAssertEqual(store.state.schoolList.first?.dbn, "dbn")
    
    // fetch details
    store.dispatch(.loadSAT(dbn: "dbn"))
    XCTAssertNotNil(store.state.selectedSat)
    XCTAssertEqual(store.state.selectedSat?.mathScore, "99")
    
    // no error
    XCTAssertNil(store.state.errorToDisplay)
  }
  
  func testWithTripWireErrorLoading() {
    
    // inject testWithTripWireErrorLoading
    let store = Store(reducer: SchoolListReducer.schoolListReducer, initState: .initial, enviroment: .testWithTripWireErrorLoading())
    
    XCTAssert(store.state.schoolList.count == 0)
    XCTAssertNil(store.state.selectedSat)
    
    // fetch schools
    store.dispatch(.fetchSchools(limit: 1, offset: 0))
    
    XCTAssert(store.state.schoolList.count == 0)
    XCTAssertNil(store.state.selectedSat)
    
    XCTAssertEqual(store.state.errorToDisplay, "An error occurred, we are looking at it")
    
    // fetch details
    store.dispatch(.loadSAT(dbn: "dbn"))
    XCTAssertNil(store.state.selectedSat)
    XCTAssertNil(store.state.selectedSat?.mathScore)
    
    XCTAssertEqual(store.state.errorToDisplay, "An error occurred, we are looking at it")
  }
  
  func testWithErrorToDisplayWhileLoading() {
    
    // inject testWithErrorToDisplayWhileLoading
    let store = Store(reducer: SchoolListReducer.schoolListReducer, initState: .initial, enviroment: .testWithErrorToDisplayWhileLoading())
    
    XCTAssert(store.state.schoolList.count == 0)
    XCTAssertNil(store.state.selectedSat)
    
    // fetch schools
    store.dispatch(.fetchSchools(limit: 1, offset: 0))
    
    XCTAssert(store.state.schoolList.count == 0)
    XCTAssertNil(store.state.selectedSat)
    
    XCTAssertEqual(store.state.errorToDisplay, "Error loading Schools")
    
    // fetch details
    store.dispatch(.loadSAT(dbn: "dbn"))
    XCTAssertNil(store.state.selectedSat)
    XCTAssertNil(store.state.selectedSat?.mathScore)
    
    XCTAssertEqual(store.state.errorToDisplay, "Error loading SAT")
  }
}
