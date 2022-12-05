//
//  SchoolDetailViewController.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation
import UIKit


final class SchoolDetailViewController: UITableViewController {
  
  private let cellIdentifier = "detailCell"
  
  var satModel: SATModel?
  var dataSource: [String]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "SAT Average scores"
    
    dataSource = satModel.map({
      ["Math: \($0.mathScore)", "Reading: \($0.readingScore)", "Writing:\($0.writingScore)"]
    })
  }
}

extension SchoolDetailViewController {
  
  func configureCell(_ cell: UITableViewCell, withDetail detail: String) {
    cell.textLabel?.text = detail
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    if let detail = dataSource?[indexPath.row] {
      configureCell(cell, withDetail: detail)
    }
    return cell
  }
  
}
