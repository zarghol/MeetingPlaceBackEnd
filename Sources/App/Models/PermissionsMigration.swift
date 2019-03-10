//
//  PermissionsMigration.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import FluentMySQL

struct PermissionsMigration: MySQLMigration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn) { schema in
            let defaultValueConstraint = MySQLColumnConstraint.default(.literal(0))
            schema.field(for: \.permissions, type: .int, defaultValueConstraint)
        }
    }

    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(User.self, on: conn) { schema in
            schema.deleteField(for: \.permissions)
        }
    }
}
