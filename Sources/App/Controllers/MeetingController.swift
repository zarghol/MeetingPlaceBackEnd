//
//  MeetingController.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import Foundation
import Vapor

final class MeetingController {
    func create(withId meetingId: Int? = nil) -> ((_ req: Request) throws -> Future<HTTPResponse>) {
        return { req in
            let user = try req.requireAuthenticated(User.self)

            return try MeetingRequest.decode(from: req)
            .with {
                if let writerUsername = $0.username, user.permissions == .admin {
                    return User
                        .query(on: req)
                        .filter(\User.username, .equal, writerUsername)
                        .first()
                        .unwrap(or: BasicValidationError("No user found for this username"))
                        .map { try $0.requireID() }
                } else {
                    return req.future(try user.requireID())
                }
            }.flatMap {
                return Meeting(id: meetingId, title: $0.0.title, presentationDate: MeetingRequest.dateFormatter.string(from: $0.0.date), presenterId: $0.1).create(on: req)
            }.map {
                guard let newMeetingId = $0.id else {
                    throw VaporError(
                        identifier: "meeting creation",
                        reason: "the meeting is created in DB but no id...."
                    )
                }
                let location = meetingId == nil ? "\(req.http.urlString)/\(newMeetingId)" : req.http.urlString
                return HTTPResponse(
                    status: .created,
                    headers: HTTPHeaders([("Location", location)])
                )
            }
        }
    }

    func mine(_ req: Request) throws -> Future<[Meeting]> {
        let user = try req.requireAuthenticated(User.self)

        return try user
            .meetings
            .query(on: req)
            .all()
    }

    func all(_ req: Request) -> Future<[Meeting]> {
        return Meeting
            .query(on: req)
            .all()
    }

    func oneDay(_ req: Request) throws -> Future<[Meeting]> {
        let date = try req.parameters.next(String.self)
        return Meeting
            .query(on: req)
            .filter(\.presentationDate, .equal, date)
            .all()
    }

    func one(_ req: Request) throws -> Future<Meeting> {
        let id = try req.parameters.next(Int.self)

        return Meeting
            .find(id, on: req)
            .unwrap(or: BasicValidationError("No meeting found for this id"))
    }

    func edit(_ req: Request) throws -> Future<HTTPResponse> {
        let id = try req.parameters.next(Int.self)

        return Meeting
            .find(id, on: req)
            .and(try MeetingRequest.decode(from: req))
            .flatMap {
                if var modified = $0.0 {
                    guard try req.checkPermission(meeting: modified) else {
                        throw BasicValidationError("the user id doesn't correspond to this meeting. You can't modify it without admin access")
                    }
                    modified.presentationDate = MeetingRequest.dateFormatter.string(from: $0.1.date)
                    modified.title = $0.1.title
                    return modified.update(on: req).transform(to: HTTPResponse(status: .ok))
                } else {
                    return try self.create(withId: id)(req)
                }
            }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let id = try req.parameters.next(Int.self)

        return Meeting.find(id, on: req)
            .unwrap(or: BasicValidationError("this meeting doesn't exist"))
            .guard(throwing: BasicValidationError("the user id doesn't correspond to this meeting. You can't delete it without admin access")) { try req.checkPermission(meeting: $0) }
            .delete(on: req)
            .transform(to: .ok)
    }
}

fileprivate extension Request {
    func checkPermission(meeting: Meeting) throws -> Bool {
        if try self.requestUserId() == meeting.presenterId {
            return true
        }

        let user = try self.requireAuthenticated(User.self)
        return user.permissions == .admin
    }
}
