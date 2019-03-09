//
//  DevelopmentDataMigration.swift
//  App
//
//  Created by Clément NONN on 09/03/2019.
//

import FluentMySQL
import Crypto


struct DevelopmentDataMigration: MySQLMigration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        do {
            let hashedPassword = try BCrypt.hash("test")
            return User(username: "zarghol", passwordHash: hashedPassword).create(on: conn).flatMap {
                UserToken.create(forUser: $0.id!).create(on: conn)
            }.map {
                print("dev token : \($0.string)")
                return ()
            }
        } catch {
            print("couldn't hash password")
            return conn.future()
        }
    }

    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return User.query(on: conn).filter(\User.username == "zarghol").all().map {
            try $0.forEach {
                try $0.tokens.query(on: conn).delete().wait()
                try $0.delete(on: conn).wait()

            }
        }
    }


}
