//
//  ViewController.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 03/12/22.
//

import UIKit
import RxSwift

class ViewController: UITableViewController {
  
  private let cellIdentifier = "schoolCell"
  
  // use it to enable pagination
  private var pageLimit = 25
  
  private var schoolListSubscription: Disposable?
  private var satSubscription: Disposable?
  
  // this vewcontroller need a store to be injected from outside to be testable
  // I usually preffer dependency inhection from the init, but since Im using storyboard to speedup work
  // I will use property injection instead: viewController.store = Store(...)
  var store: Store<SchoolListState, SchoolListActions, SchoolListEnviroment>!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Schools"
    
    store = Store(reducer: SchoolListReducer.schoolListReducer, initState: .initial, enviroment: .prod())
    
    schoolListSubscription = store?.observe(\.schoolList).subscribe(onNext: { [weak self] schools in
      self?.tableView.reloadData()
    })
    
    satSubscription = store?.observe(\.selectedSat).subscribe(onNext: { [weak self] satModel in
      guard let model = satModel else { return }
      self?.performSegue(withIdentifier: "toDetail", sender: model)
    })
    
    store.dispatch(.fetchSchools(limit: pageLimit, offset: store.state.schoolList.count))
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toDetail", let model = sender as? SATModel {
      let detailVC = segue.destination as! SchoolDetailViewController
      detailVC.satModel = model
    }
  }
  
  deinit {
    schoolListSubscription?.dispose()
    satSubscription?.dispose()
  }
  
}

// tableviewdelegate

extension ViewController {
  
  func configureCell(_ cell: UITableViewCell, withModel model: SchoolModel) {
    cell.textLabel?.text = model.name
    
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.lineBreakMode = .byWordWrapping
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return store.state.schoolList.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let model = store.state.schoolList[indexPath.row]
    configureCell(cell, withModel: model)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dbn = store.state.schoolList[indexPath.row].dbn
    store.dispatch(.loadSAT(dbn: dbn))
  }
  
}

// loading indicator

extension ViewController {
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lastSectionIndex = tableView.numberOfSections - 1
    let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
    if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && !store.state.listCompleted {
      let spinner = UIActivityIndicatorView(style: .medium)
      spinner.startAnimating()
      spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
      tableView.tableFooterView = spinner
      
      // load more
      store.dispatch(.fetchSchools(limit: pageLimit, offset: store.state.schoolList.count))
    }
    
    tableView.tableFooterView?.isHidden = store.state.listCompleted
  }

}

