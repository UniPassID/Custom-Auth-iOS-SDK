import Foundation
import Shared
import web3

public class SmartAccount {
    var inner: Shared.SmartAccount?
    var builder: Shared.SmartAccountBuilder?

    public init(options: SmartAccountOptions) {
        builder = SmartAccountBuilder().withAppId(options.appId)

        if options.masterKeySigner != nil {
            builder = builder!.withMasterKeySigner(WrapSigner(signer: options.masterKeySigner!), options.masterKeyRoleWeight)
        }

        if options.unipassServerUrl != nil {
            builder = builder!.withUnipassServerUrl(options.unipassServerUrl!)
        }

        options.chainOptions.forEach { element in
            self.builder = self.builder!.addChainOption(element.chainId.rawValue, element.rpcUrl, element.relayerUrl)
        }
    }

    private func requireInit() throws {
        if inner == nil {
            throw SmartAccountError.expectedInit
        }
    }

    public func initalize(options: SmartAccountInitOptions) async throws {
        builder = builder!.withActiveChain(options.chainId.rawValue)
        inner = try await builder?.build()
        builder = nil
    }

    public func address() async throws -> String {
        try requireInit()
        return Data(inner!.address()).web3.hexString
    }

    public func isDeployed() async throws -> Bool {
        try requireInit()
        return try await inner!.isDeployed()
    }

    public func chainID() throws -> ChainID {
        try requireInit()
        return ChainID(rawValue: inner!.chain())!
    }

    public func nonce() async throws -> UInt64 {
        try requireInit()
        return try await inner!.nonce()
    }

    public func switchChain(chainID: ChainID) throws {
        try requireInit()
        try inner!.switchChain(chainID.rawValue)
    }

    public func signMessage(message: String) async throws -> String {
        try requireInit()
        return String(bytes: try await inner!.signMessage(try message.bytes))
    }

    public func signMessage(message: Data) async throws -> String {
        try requireInit()
        return String(bytes: try await inner!.signMessage(message.bytes))
    }

    public func signTypedData(typedData: web3.TypedData) async throws -> String {
        try requireInit()

        return String(bytes: try await inner!.signTypedData(typedData.typed_data.typedData))
    }
}
