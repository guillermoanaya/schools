//
//  SchoolModel.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation

struct SchoolModel: Decodable, Equatable {
  enum CodingKeys: String, CodingKey {
    case dbn
    case name = "schoolName"
  }

  let name: String
  let dbn: String
}
