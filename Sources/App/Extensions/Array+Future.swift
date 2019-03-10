//
//  Array+Future.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

extension Array where Element == Future<Void>  {
    func chained() -> Future<Void>? {
        guard let firstElement = first else { return nil }
        guard count > 1 else { return firstElement }

        var future = firstElement
        for element in self[1...] {
            future = future.flatMap { return element }
        }
        return future
    }
}
