//
//  MeetingRequest.swift
//  App
//
//  Created by Clément NONN on 09/03/2019.
//

import Vapor

struct MeetingRequest {
    let title: String
    let date: Date
}

extension MeetingRequest: Content {
    static let dateFormatter: DateFormatter = {
        let fo = DateFormatter()
        fo.dateFormat = "dd'-'MM'-'yyyy"
        fo.locale = Locale.current
        return fo
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .formatted(dateFormatter)
        return d
    }()

    static let encoder: JSONEncoder = {
        let d = JSONEncoder()
        d.dateEncodingStrategy = .formatted(dateFormatter)
        return d
    }()

    public func encode(using container: Container) throws -> Future<Request> {
        let req = Request(using: container)
        try req.content.encode(json: self, using: MeetingRequest.encoder)
        return Future.map(on: container) { req }
    }

    public func encode(for req: Request) throws -> Future<Response> {
        let res = req.response()
        try res.content.encode(json: self, using: MeetingRequest.encoder)
        return Future.map(on: req) { res }
    }

    public static func decode(from req: Request) throws -> Future<MeetingRequest> {
        let content = try req.content.decode(json: MeetingRequest.self, using: MeetingRequest.decoder)
        return content
    }

    public static func decode(from res: Response, for req: Request) throws -> Future<MeetingRequest> {
        let content = try req.content.decode(json: MeetingRequest.self, using: MeetingRequest.decoder)
        return content
    }
}
