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
        let userId = try req.requestUserId()

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
    func deleteToken(_ req: Request) throws -> Future<HTTPStatus> {
        let userId = try req.requestUserId()
        let token = try req.parameters.next(String.self)

        return UserToken.query(on: req)
            .filter(\UserToken.string, .equal, token)
            .filter(\UserToken.userID, .equal, userId)
            .delete()
            .transform(to: .ok)
    }

    // protected by token
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)

        return req.transaction(on: .mysql) { conn in
            return [try user.tokens.query(on: conn).delete(),
                    try user.meetings.query(on: conn).delete(),
                    user.delete(on: conn)].chained()!
        }.transform(to: .ok)
    }

    // not protected
    func allUsernames(_ req: Request) -> Future<[String]> {
        return User.query(on: req).all().map { $0.map { $0.username } }
    }
}
