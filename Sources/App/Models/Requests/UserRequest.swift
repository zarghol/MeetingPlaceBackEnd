//
//  UserRequest.swift
//  App
//
//  Created by Clément NONN on 09/03/2019.
//

import Vapor

struct UserRequest: Content {
    let user: String
    let password: String
}
