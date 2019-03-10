//
//  Request+User.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Foundation
import Vapor

extension Request {
    func requestUserId() throws -> Int {
        let user = try self.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw BasicValidationError("Unknown user")
        }
        return userId
    }
}
