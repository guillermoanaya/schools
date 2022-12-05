//
//  Store.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation
import RxSwift

// react type like https://redux.js.org/tutorials/fundamentals/part-3-state-actions-reducers#writing-reducers
typealias Reducer<State, Action, Enviroment> = (_ state: inout State, _ action: Action, _ enviroment: Enviroment) -> [Effect<Action>]

// main interactor from UI, in charge to glue state and actions
final class Store<State, Action, Enviroment> {
  private let reducer: Reducer<State, Action, Enviroment>
  private let subject: BehaviorSubject<State>
  private(set) var state: State
  private let envrioment: Enviroment
  
  init(reducer: @escaping Reducer<State, Action, Enviroment>, initState: State, enviroment: Enviroment) {
    self.reducer = reducer
    self.state = initState
    self.envrioment = enviroment
    self.subject = BehaviorSubject(value: initState)
  }
  
  func dispatch(_ action: Action) {
    let effects = reducer(&state, action, envrioment)
    for effect in effects {
      effect.work { action in self.dispatch(action) }
    }
    subject.onNext(state)
  }
  
  func observeDistinctUntilChanged<T: Equatable>(_ keyPath: KeyPath<State, T>) -> Observable<T> {
    return
      subject
      .map { $0[keyPath: keyPath] }
      .distinctUntilChanged()
  }
  
  func observe<T: Equatable>(_ keyPath: KeyPath<State, T>) -> Observable<T> {
    return
      subject
      .map { $0[keyPath: keyPath] }
  }
  
  deinit {
    subject.onCompleted()
  }
  
}
