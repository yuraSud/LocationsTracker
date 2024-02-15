//
//  ErrorModel.swift
//  Movies
//
//  Created by Olga Sabadina on 08.02.2024.
//

import Foundation

struct ErrorModel: Codable {
    let errorMessage: String
    var date: Date = .now
    let uidUser: String
}
