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
        return try self.requireAuthenticated(User.self).requireID()
    }
}
