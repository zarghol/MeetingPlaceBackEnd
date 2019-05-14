//
//  ConnectionCloseMiddleware.swift
//  App
//
//  Created by Clément NONN on 14/05/2019.
//

import Vapor

class ConnectionCloseMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        request.http.headers.replaceOrAdd(name: .connection, value: "close")
        return try next.respond(to: request)
    }
}
