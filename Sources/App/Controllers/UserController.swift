//
//  UserController.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import Vapor
import Crypto

final class UserController {
    func create(_ req: Request) throws -> Future<PublicUser> {
        let userRequest = try req.content.decode(UserRequest.self)

        let existingUserError = BasicValidationError("a user with this name already exist. Couldn't create new user with this name")

        return userRequest.verifyMapping({
            return User.query(on: req).filter(\User.username, .equal, $0.user).first()
        }, throwing: existingUserError, condition: { $0 == nil })
        .flatMap { request in
            let passwordHashed = try BCrypt.hash(request.password)
            let created = User(username: request.user, passwordHash: passwordHashed)
            return created.create(on: req).flatMap { try $0.makePublic(with: req) }
        }
    }

    // protected by token
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)

        return req.transaction(on: .mysql) { conn in
            return [try user.authTokens.query(on: conn).delete(),
                    try user.talks.query(on: conn).delete(),
                    user.delete(on: conn)].chained()!
            }.transform(to: .ok)
    }

    // not protected
    func allUsernames(_ req: Request) -> Future<[PublicUser]> {
        return User.query(on: req)
            .all()
            .makePublic(with: req)
    }

    func connect(_ req: Request) throws -> Future<PublicMe> {
        let user = try req.requireAuthenticated(User.self)

        return try user.makePublicMe(with: req)
    }

    // protected by password
    func createToken(_ req: Request) throws -> Future<PublicToken> {
        let userId = try req.requestUserId()

        return UserToken
            .create(forUser: userId)
            .create(on: req)
            .makePublic(with: req)
    }

    func allTokens(_ req: Request) throws -> Future<[PublicToken]> {
        let user = try req.requireAuthenticated(User.self)

        return try user.authTokens
            .query(on: req)
            .all()
            .makePublic(with: req)
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
}
