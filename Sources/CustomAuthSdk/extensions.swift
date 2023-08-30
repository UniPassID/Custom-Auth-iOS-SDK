//
//  File.swift
//
//
//

import Foundation
import GenericJSON
@_exported import Shared
import web3



public protocol TypedDataExtendable {
    associatedtype T
    var typed_data: T { get }
}

public extension TypedDataExtendable {
    var typed_data: TypedDataExtensions<Self> {
        TypedDataExtensions(self)
    }
}

public struct TypedDataExtensions<Base> {
    public internal(set) var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

extension web3.TypedData: TypedDataExtendable {}
extension GenericJSON.JSON: TypedDataExtendable {}

public extension TypedDataExtensions where Base == GenericJSON.JSON {
    var value: Shared.Value {
        switch base {
        case let .array(inner):
            return Shared.Value.arrayValue(inner: inner.map { element in
                element.typed_data.value
            })
        case let .bool(inner):
            return Shared.Value.boolValue(inner: inner)
        case .null:
            return Shared.Value.nullValue
        case let .number(inner):
            return Shared.Value.numberValue(inner: inner)
        case let .object(inner):
            var object: [String: Shared.Value] = [:]
            inner.forEach { key, value in
                object[key] = value.typed_data.value
            }
            return Shared.Value.objectValue(inner: object)
        case let .string(inner):
            return Shared.Value.stringValue(inner: inner)
        }
    }
}
