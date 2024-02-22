//
//  AuthorizedError.swift
//  Movies
//
//  Created by Olga Sabadina on 05.01.2024.
//

import Foundation

enum AuthorizeError: String, Error {
    case errorParceProfile = "Can't parce data to Profile struct"
    case docNotExists = "Sorry. \nThis document not exists"
    case sendDataFailed = "Sorry, can't send data profile to server FireStore"
    case userNotFound = "Sorry user not found"
    
    case sendErrorFail = "Can't send error to server"
    case uidUserFail = "Can't find user uid in local store"
    case errorEncode = "Can't encode model to data"
    case trackEncode = "Can't encode track model to data"
    case profileEncode = "Can't encode profile model to data"
}

