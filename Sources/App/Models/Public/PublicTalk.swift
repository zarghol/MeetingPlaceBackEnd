//
//  PublicTalk.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

struct PublicTalk: Codable {
    let title: String
    /// The date of the meeting
    let presentationDate: String
    /// the presenter that make the show 😎
    let presenter: String
}

extension PublicTalk: Content { }


