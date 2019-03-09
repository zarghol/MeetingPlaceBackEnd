//
//  Meeting.swift
//  App
//
//  Created by Clément NONN on 08/03/2019.
//

import FluentMySQL
import Foundation
import Vapor

struct Meeting: MySQLModel {
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

    var user: Parent<Meeting, User> {
        return parent(\.presenterId)
    }
}

extension Meeting: Migration { }

extension Meeting: Content { }
