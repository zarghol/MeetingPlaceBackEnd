//
//  Token.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import FluentSQLite
import Vapor
import Authentication

struct UserToken: SQLiteModel {
    var id: Int?
    var string: String
    var userID: User.ID

    init(id: Int? = nil, value: String, userId: User.ID) {
        self.id = id
        self.string = value
        self.userID = userId
    }

    static func create(forUser userId: User.ID) -> UserToken {
        let token = UUID().uuidString
        return UserToken(value: token, userId: userId)
    }

    var user: Parent<UserToken, User> {
        return parent(\.userID)
    }
}

extension UserToken: Token {
    /// See `Token`.
    typealias UserType = User

    /// See `Token`.
    static var tokenKey: WritableKeyPath<UserToken, String> {
        return \.string
    }

    /// See `Token`.
    static var userIDKey: WritableKeyPath<UserToken, User.ID> {
        return \.userID
    }
}

extension UserToken: Migration { }
