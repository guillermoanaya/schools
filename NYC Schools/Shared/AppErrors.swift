//
//  AppErrors.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation

enum AppErrors: Error {
  case tripwire(_ message: String)
  case fatal(_ message: String?)
  case toDisplay(_ message: String)
}
