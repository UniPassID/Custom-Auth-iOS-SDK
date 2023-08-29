//
//  SmartAccountTypes.swift
//  CustomAuthSDK
//
//

import Foundation
@_exported import Shared
import web3

public enum ChainID: UInt64 {
    case ETHEREUM_MAINNET = 1
    case ETHEREUM_GOERLI = 5
    case BNBCHAIN_MAINNET = 56
    case BNBCHAIN_TESTNET = 97
    case POLYGON_MAINNET = 137
    case POLYGON_MUMBAI = 80001
    case ARBITRIUM_ONE = 42161
    case ARBITRUM_GOERLI = 421613
}

public protocol Signer {
    func address() -> String

    func signMessage(message: Data) throws -> String
}

public extension Signer{
    func signMessage(message: String) throws -> String{
        return try self.signMessage(message: message.data(using: String.Encoding.utf8)!);
    }
}

extension web3.EthereumAccount:Signer{
    public func address() ->String{
        return self.address.asString()
    }

    public func signMessage(message: Data) throws -> String {
        return try (self as EthereumAccountProtocol).signMessage(message: message)
    }
}



public struct ChainOptions {
    public var chainId: ChainID = ChainID.ETHEREUM_MAINNET
    public var rpcUrl: String
    public var relayerUrl: String?
    
    public init(chainId: ChainID, rpcUrl: String, relayerUrl: String? = nil) {
        self.chainId = chainId
        self.rpcUrl = rpcUrl
        self.relayerUrl = relayerUrl
    }
}

public struct SmartAccountOptions {
    public var masterKeySigner: Signer?
    public var masterKeyRoleWeight: RoleWeight?
    public var appId: String
    public var unipassServerUrl: String?
    public var chainOptions: Array<ChainOptions>
    
    public init(masterKeySigner: Signer? = nil, masterKeyRoleWeight: RoleWeight? = nil, appId: String, unipassServerUrl: String? = nil, chainOptions: Array<ChainOptions>) {
        self.masterKeySigner = masterKeySigner
        self.masterKeyRoleWeight = masterKeyRoleWeight
        self.appId = appId
        self.unipassServerUrl = unipassServerUrl
        self.chainOptions = chainOptions
    }
}

public struct SmartAccountInitOptions{
    public var chainId:ChainID
    public init(chainId: ChainID) {
        self.chainId = chainId
    }
}

internal class WrapSigner: Shared.Signer {
    private var signer: Signer
    
    public init(signer: Signer) {
        self.signer = signer
    }

    public func address() -> String {
        return self.signer.address()
    }

   public func signMessage(message: [UInt8]) throws -> String {
        return try (self.signer as Signer).signMessage(message: Data(message));
    }
}

public enum SmartAccountError: String, Error{
    case expectedInit = "Expected Smart Account to Initialize"
}
