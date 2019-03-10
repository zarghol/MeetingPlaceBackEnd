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
            let userId = try req.requestUserId()

            return try MeetingRequest.decode(from: req).flatMap {
                return Meeting(id: meetingId, title: $0.title, presentationDate: MeetingRequest.dateFormatter.string(from: $0.date), presenterId: userId).create(on: req)
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
        return Meeting
            .query(on: req)
            .filter(\Meeting.id, .equal, id)
            .delete()
            .transform(to: .ok)
    }
}
