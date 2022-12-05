//
//  SATModel.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 04/12/22.
//

import Foundation

struct SATModel: Decodable, Equatable {
  enum CodingKeys: String, CodingKey {
    case readingScore = "satCriticalReadingAvgScore"
    case mathScore = "satMathAvgScore"
    case writingScore = "satWritingAvgScore"
  }

  let readingScore: String
  let writingScore: String
  let mathScore: String
  
}
