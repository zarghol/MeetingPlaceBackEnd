//
//  Permission.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//



enum PermissionLevel: Int, Codable {
    case teamMember = 0
    case admin = 1
}

import Vapor

extension PermissionLevel: ReflectionDecodable {
    static func reflectDecoded() throws -> (PermissionLevel, PermissionLevel) {
        return (.teamMember, .admin)
    }
}
