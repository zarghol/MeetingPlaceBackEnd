//
//  Talk.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import FluentMySQL
import Foundation
import Vapor

struct Talk: MySQLModel {
    /// The unique identifier for this `meeting`.
    var id: Int?

    /// A title describing what this `Meeting` entails.
    var title: String
    /// The date of the meeting
    var presentationDate: String
    /// the presenter that make the show 😎
    var presenterId: User.ID
    // See later how to do it
//    var associatedFiles: [File]

    init(id: Int? = nil, title: String, presentationDate: String, presenterId: User.ID) {
        self.id = id
        self.title = title
        self.presentationDate = presentationDate
        self.presenterId = presenterId
    }

    var user: Parent<Talk, User> {
        return parent(\.presenterId)
    }
}

extension Talk: Migration { }

extension Talk: PublicEntityConvertible {
    func makePublic(with container: Container & DatabaseConnectable) throws -> EventLoopFuture<PublicTalk> {
        return self.user.get(on: container).map {
            return PublicTalk(title: self.title, presentationDate: self.presentationDate, presenter: $0.username)
        }
    }
}
