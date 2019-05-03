//
//  UserController.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import Vapor
import Crypto

enum AuthenticationError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .badPassword:
            return .unauthorized
        case .unknownUser:
            return .preconditionFailed
        }
    }

    var reason: String {
        switch self {
        case .badPassword:
            return "invalid password"
        case .unknownUser:
            return "unknown user"
        }
    }

    var identifier: String { return "Authentication Error" }

    case unknownUser
    case badPassword
}

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
        if let user = try req.authenticated(User.self) {
            return try user.makePublicMe(with: req)
        } else if let username = req.http.headers.basicAuthorization?.username {
            return User.query(on: req).filter(\User.username, .equal, username).first().map(to: Bool.self) {
                return $0 != nil
            }.map {
                throw $0 ? AuthenticationError.badPassword : AuthenticationError.unknownUser
            }
        } else {
            throw AuthenticationError.badPassword
        }
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
