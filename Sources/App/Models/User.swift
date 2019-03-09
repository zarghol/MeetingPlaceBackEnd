//
//  User.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import FluentSQLite
import Vapor
import Authentication

struct User: SQLiteModel {
    var id: Int?

    var username: String
    var passwordHash: String

    init(id: Int? = nil, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
    }

    var meetings: Children<User, Meeting> {
        return children(\.presenterId)
    }
}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \.username
    }

    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

extension User {
    var tokens: Children<User, UserToken> {
        return children(\.userID)
    }
}

extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

extension User: Content { }

extension User: Migration { }
