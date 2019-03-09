//
//  UserController.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import Vapor
import Crypto

final class UserController {
    func create(_ req: Request) throws -> Future<User> {
        let userRequest = try req.content.decode(UserRequest.self)

        let existingUserError = BasicValidationError("a user with this name already exist. Couldn't create new user with this name")

        return userRequest.verifyMapping({
            return User.query(on: req) .filter(\User.username, .equal, $0.user).first()
        }, throwing: existingUserError, condition: { $0 == nil })
        .flatMap { request in
            let passwordHashed = try BCrypt.hash(request.password)
            let created = User(username: request.user, passwordHash: passwordHashed)
            return created.create(on: req)
        }
    }

    // protected by password
    func createToken(_ req: Request) throws -> Future<String> {
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw BasicValidationError("Unknown user")
        }

        return UserToken
            .create(forUser: userId)
            .create(on: req)
            .map { $0.string }
    }

    func allTokens(_ req: Request) throws -> Future<[String]> {
        let user = try req.requireAuthenticated(User.self)

        return try user.tokens
            .query(on: req)
            .all()
            .map { $0.map { $0.string }}
    }

    // protected by password
    func deleteToken(_ req: Request) -> HTTPStatus {
        return .notImplemented
    }

    // protected by token
    func delete(_ req: Request) -> HTTPStatus {
        return .notImplemented
    }

    // not protected
    func allUsernames(_ req: Request) -> Future<[String]> {
        return User.query(on: req).all().map { $0.map { $0.username } }
    }
}
