//
//  PublicUser.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

struct PublicUser: Codable {
    var username: String
}

extension PublicUser: Content { }
