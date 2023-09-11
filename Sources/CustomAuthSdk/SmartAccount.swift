import Foundation
@_exported import Shared
import web3

public class SmartAccount {
    var inner: Shared.SmartAccount?
    var builder: Shared.SmartAccountBuilder?
    var masterKeySigner: WrapSigner?
    var masterKeyRoleWeight: RoleWeight?
    
    public init(options: SmartAccountOptions) {
        builder = SmartAccountBuilder().withAppId(appId: options.appId)

        masterKeyRoleWeight = options.masterKeyRoleWeight
        
        if let signer = options.masterKeySigner {
            masterKeySigner = WrapSigner(signer: signer)
            builder = builder!.withMasterKeySigner(signer: masterKeySigner!, roleWeight: masterKeyRoleWeight)
        }

        if options.unipassServerUrl != nil {
            builder = builder!.withUnipassServerUrl(unipassServerUrl: options.unipassServerUrl!)
        }

        options.chainOptions.forEach { element in
            self.builder = self.builder!.addChainOption(chain: element.chainId.rawValue, rpcUrl: element.rpcUrl, httpRelayerUrl: element.relayerUrl)
        }
    }

    private func requireInit() throws {
        if inner == nil {
            throw SmartAccountError.expectedInit
        }
    }

    public func initialize(options: SmartAccountInitOptions) async throws {
        builder = builder!.withActiveChain(activeChain: options.chainId.rawValue)
        inner = try await builder?.build()
        builder = nil
    }

    public func initialize(options: SmartAccountInitByKeyOptions) async throws {
        var keys = options.keys
        if masterKeySigner == nil {
            let masterKey = keys.removeFirst()
            builder = try? builder?.withMasterKey(key: masterKey)
        }
        builder = try builder?.addGuardianKeys(keys: keys).withActiveChain(activeChain: options.chainId.rawValue)
        inner = try await builder?.build()
        builder = nil
    }
    
    public func initialize(options: SmartAccountInitByKeysetJsonOptions) async throws {
        builder = try builder!.withActiveChain(activeChain: options.chainId.rawValue).withKeysetJson(keysetJson: options.keysetJson)
        if let signer = masterKeySigner {
            builder = builder?.withMasterKeySigner(signer: signer, roleWeight: masterKeyRoleWeight)
        }
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
        try inner!.switchChain(chainId: chainID.rawValue)
    }

    public func signMessage(message: String) async throws -> String {
        try requireInit()
        return String(bytes: try await inner!.signMessage(message: Array(message.utf8)))
    }

    public func signMessage(message: Data) async throws -> String {
        try requireInit()
        return String(bytes: try await inner!.signMessage(message: message.bytes))
    }
    
    public func signTransactions(transactions: [Transaction], options: SendingTransactionOptions?) async throws -> Execute {
        try requireInit()
        
        return try await inner!.signTransactions(transactions: transactions, options: options != nil ? Shared.SendingTransactionOptions(fee: options!.fee, chain: options!.chain) : nil)
    }
    
    public func signTypedData(typedData: web3.TypedData) async throws -> String {
        try requireInit()

        return String(bytes: try await inner!.signTypedData(typedData: typedData.typed_data.typedData))
    }

    public func signTypedData(typedData: Shared.TypedData) async throws -> String {
        try requireInit()

        return String(bytes: try await inner!.signTypedData(typedData: typedData))
    }

    public func simulateTransaction(transaction: Shared.Transaction, options: SimulateTransactionOptions?) async throws -> SimulateResult {
        try requireInit()

        return try await inner!.simulateTransactions(transactions: [transaction], simulateOptions: options != nil ? Shared.SimulateTransactionOptions(token: options!.token, chain: options!.chain) : nil)
    }

    public func simulateTransaction(transaction: Shared.Transaction) async throws -> SimulateResult {
        try requireInit()

        return try await inner!.simulateTransactions(transactions: [transaction], simulateOptions: nil)
    }

    public func simulateTransactionBatch(transactions: [Shared.Transaction], options: SimulateTransactionOptions?) async throws -> SimulateResult {
        try requireInit()

        return try await inner!.simulateTransactions(transactions: transactions, simulateOptions: options != nil ? Shared.SimulateTransactionOptions(token: options!.token, chain: options!.chain) : nil)
    }

    public func simulateTransactionBatch(transactions: [Shared.Transaction]) async throws -> SimulateResult {
        try requireInit()

        return try await inner!.simulateTransactions(transactions: transactions, simulateOptions: nil)
    }

    public func sendTransaction(transaction: Shared.Transaction, options: SendingTransactionOptions?) async throws -> String {
        try requireInit()

        return try await inner!.sendTransactions(transactions: [transaction], options: options != nil ? Shared.SendingTransactionOptions(fee: options!.fee, chain: options!.chain) : nil)
    }

    public func sendTransaction(transaction: Shared.Transaction) async throws -> String {
        try requireInit()

        return try await inner!.sendTransactions(transactions: [transaction], options: nil)
    }

    public func sendTransactionBatch(transactions: [Shared.Transaction], options: SendingTransactionOptions?) async throws -> String {
        try requireInit()

        return try await inner!.sendTransactions(transactions: transactions, options: options != nil ? Shared.SendingTransactionOptions(fee: options!.fee, chain: options!.chain) : nil)
    }

    public func sendTransactionBatch(transactions: [Shared.Transaction]) async throws -> String {
        try requireInit()

        return try await inner!.sendTransactions(transactions: transactions, options: nil)
    }

    public func waitTransactionReceiptByHash(transactionHash: String) async throws -> Shared.TransactionReceipt? {
        try requireInit()

        return try await inner!.waitForTransaction(txHash: transactionHash)
    }

    public func getKeysetJson() throws -> String {
        try requireInit()

        return inner!.keysetJson()
    }
}
