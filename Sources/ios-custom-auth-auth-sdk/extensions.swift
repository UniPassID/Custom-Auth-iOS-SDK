//
//  File.swift
//
//
//  Created by 郑卓 on 2023/8/9.
//

import Foundation
import GenericJSON
import Shared
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

public extension TypedDataExtensions where Base == web3.TypedData {
    var typedData: Shared.TypedData {
        let domain = base.domain.objectValue
        let domainChainId = domain?["chainId"]?.doubleValue
        let chainId = domainChainId == nil ? nil : UInt64(domainChainId!)
        let typedDomain = Shared.Eip712Domain(name: domain?["name"]?.stringValue, version: domain?["version"]?.stringValue, chainId: chainId, verifyingContract: domain?["verifyingContract"]?.stringValue, salt: domain?["salt"]?.stringValue)

        var typedTypes: [String: [Shared.Eip712DomainType]] = [:]
        base.types.forEach { key, value in
            typedTypes[key] = value.map { element in
                Shared.Eip712DomainType(name: element.name, type: element.type)
            }
        }

        var typedMessage: [String: Shared.Value] = [:]
        base.message.objectValue?.forEach { key, value in
            typedMessage[key] = value.typed_data.value
        }
        return Shared.TypedData(domain: typedDomain, types: typedTypes, primaryType: base.primaryType, message: typedMessage)
    }
}

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
