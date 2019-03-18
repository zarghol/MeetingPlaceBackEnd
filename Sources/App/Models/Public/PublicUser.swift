//
//  PublicUser.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

struct PublicUser: Codable {
    let username: String
}

extension PublicUser: Content { }

struct PublicMe: Codable {
    let username: String
    let isAdmin: Bool
    let token: String
}

extension PublicMe: Content { }
