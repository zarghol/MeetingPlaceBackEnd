//
//  User.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import FluentMySQL
import Vapor
import Authentication

struct User: MySQLModel {
    var id: Int?

    var username: String
    var passwordHash: String
    var permissions: PermissionLevel

    init(id: Int? = nil, username: String, passwordHash: String, permissions: PermissionLevel = .teamMember) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.permissions = permissions
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
    var talks: Children<User, Talk> {
        return children(\.presenterId)
    }
}

extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

extension User: Migration { }

extension User: PublicEntityConvertible {
    func makePublic(with container: Container & DatabaseConnectable) throws -> EventLoopFuture<PublicUser> {
        return container.future(PublicUser(username: self.username)) 
    }

    func makePublicMe(with container: Container & DatabaseConnectable) throws -> EventLoopFuture<PublicMe> {
        return try self.authTokens.query(on: container)
            .first()
            .ifNotAlreadyExist(container: container) { UserToken.create(forUser: self.id!).create(on: container) }
            .map { PublicMe(username: self.username, isAdmin: self.permissions == .admin, token: $0.string) }
    }
}
