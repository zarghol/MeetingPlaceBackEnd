//
//  PublicToken.swift
//  App
//
//  Created by Clément NONN on 11/03/2019.
//

import Vapor

struct PublicToken: Codable {
    let token: String
}

extension PublicToken: Content { }
