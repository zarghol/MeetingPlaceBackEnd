//
//  Future+Extension.swift
//  App
//
//  Created by Clément NONN on 09/03/2019.
//

import Async

extension Future {
    func `guard`(throwing error: Error, condition: @escaping (T) -> Bool) -> Future<T> {
        return self.map {
            guard condition($0) else {
                throw error
            }
            return $0
        }
    }

    func with<U>(_ mapping: @escaping (T) -> U) -> Future<(T, U)> {
        return self.map { ($0, mapping($0)) }
    }

    func with<U>(_ mapping: @escaping (T) -> Future<U>) -> Future<(T, U)> {
        return self.flatMap { first in mapping(first).map { (first, $0) } }
    }

    func verifyMapping<U>(_ mapping: @escaping (T) -> U, throwing error: Error, condition: @escaping (U) -> Bool) -> Future<T> {
        let cond: (T, U) -> Bool = { condition($1) }
        return self.with(mapping).guard(throwing: error, condition: cond).map { $0.0 }
    }

    func verifyMapping<U>(_ mapping: @escaping (T) -> Future<U>, throwing error: Error, condition: @escaping (U) -> Bool) -> Future<T> {
        let cond: (T, U) -> Bool = { condition($1) }
        return self.with(mapping).guard(throwing: error, condition: cond).map { $0.0 }
    }
}
