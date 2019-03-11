//
//  PublicEntityConvertible.swift
//  App
//
//  Created by Clément NONN on 10/03/2019.
//

import Vapor

protocol PublicEntityConvertible {
    associatedtype PublicEntityType

    func makePublic(with container: Container & DatabaseConnectable) throws -> Future<PublicEntityType>
}

extension Future where T: PublicEntityConvertible {
    func makePublic(with container: DatabaseConnectable & Container) -> EventLoopFuture<T.PublicEntityType> {
        return self.flatMap { try $0.makePublic(with: container) }
    }
}

extension Array: PublicEntityConvertible where Element: PublicEntityConvertible {
    typealias PublicEntityType = Array<Element.PublicEntityType>

    func makePublic(with container: DatabaseConnectable & Container) throws -> EventLoopFuture<Array<Element.PublicEntityType>> {

        let publicElements = try self.map { try $0.makePublic(with: container) }

        return publicElements.reduce(container.future(Array<Element.PublicEntityType>())) { (allElements, nextPublic) in
            return allElements.and(nextPublic).map {
                var (currentTable, nextItem) = $0
                currentTable.append(nextItem)
                return currentTable
            }
        }
    }
}
