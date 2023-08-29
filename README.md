# UniPass Custom Auth iOS SDK

## Install

Use Xcode to add to the project (File -> Swift Packages) or add this to your Package.swift file:

```bash
.package(url: "https://github.com/UniPassID/Custom-Auth-iOS-SDK.git", from: "0.0.1-alpha.25")
```

## Initialize Smart Account

### Step1: Initialize Master Key Signer

Master Key Signer is the main signer for signing messages and transactions. You can create the EOA Signer using the EOASigner class provided by the SDK

#### Init EOA Signer

```swift
import web3

let keyStorage = EthereumKeyLocalStorage()

let masterKeySigner = try? EthereumAccount.create(replacing: keyStorage, keystorePassword: "MY_PASSWORD")
```

### Step2: Initialize Smart Account

To initialize the smart account, you need to init the active chainId by default.

```swift
import Shared
import CustomAuthSdk

// public struct SmartAccountOptions {
//     public init(masterKeySigner: Signer? = nil, masterKeyRoleWeight: RoleWeight? = nil, appId: String, unipassServerUrl: String? = nil, chainOptions: Array<ChainOptions>);
// }
//
// public struct ChainOptions {
//     public init(chainId: ChainID, rpcUrl: String, relayerUrl: String? = nil);
// }

let options = SmartAccountOptions(masterKeySigner: masterKeySigner, appId: appId,  chainOptions: [ChainOptions(chainId: ChainID.POLYGON_MUMBAI, rpcUrl: "https://node.wallet.unipass.id/polygon-mumbai")])

let smartAccount = SmartAccount(options:options)

let initOptions = SmartAccountInitOptions(chainId: ChainID.POLYGON_MUMBAI)
smartAccount.initialize(options: initOptions)
```

## Send Transaction

### Step1: Generate Transaction

```swift
let tx = Shared.Transaction(
    to: to,       // to address hex string
    data: "0x",   // transaction data
    value: "0x1"  // transaction value
);
```

### Step2: Get Fee Options and Consumption through `simulateTransaction()`

You need to call this method in a suspend function because it is an asynchronous method

```swift
// public struct SimulateResult {
//     public var isFeeRequired: Bool
//     public var feeOptions: [FeeOption]

//     public init(isFeeRequired: Bool, feeOptions: [FeeOption]);
// }

// public struct FeeOption {
//     public var token: String
//     public var name: String
//     public var symbol: String
//     public var decimals: UInt8
//     public var to: String
//     public var amount: String
//     public var error: String?

//     public init(token: String, name: String, symbol: String, decimals: UInt8, to: String, amount: String, error: String?);
// }

let simulateRet = try? await smartAccount.simulateTransaction(transaction: tx);
```

### Step3: **Validate Whether Fee is Sufficient**

```swift
// Token_CA: The contract address of the token you want to use as gasFee
// Example: Take USDC on Mumbai as gasFee
let Token_CA = "0x87F0E95E11a49f56b329A1c143Fb22430C07332a"

var fee:FeeOption?
if (simulateRet!!.isFeeRequired) {
    fee = feeOptions.first(where: { feeOption in
        feeOption.token == Token_CA.lowercased()
    })
}

let sendTransactionOptions = SendingTransactionOptions(fee:fee)
```

Notice that if there is a transaction involving fee tokens, the validating result may not be accurate.

### Step4: Select Fee Option and Send Transaction

You need to call this method in a suspend function because it is an asynchronous method

```swift
let txHash = try? await smartAccount.sendTransaction(transaction: tx, options: sendTransactionOptions)
let receipt = try? await smartAccount.waitTransactionReceiptByHash(transactionHash: txHash!!);
```

## Sign & Verify Message

### Sign Message

```swift
let message = "Hello UniPass!"; // The Message to Sign
let signature = smartAccount.signMessage(message: message); // Sign message
```

### Verify Message

```
```

## Sign & Verify Typed Data

### Sign Typed Data

```swift
import Shared
import CustomAuthSdk

let domain = Eip712Domain(name: "uniPass", version: "0.1.2", chainId: 8001, verifyingContract: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC", salt: nil)
let types = ["EIP712Domain":[Eip712DomainType(name: "name", type: "string"),Eip712DomainType(name: "version", type:"string"),Eip712DomainType(name: "chainId", type: "uint256"),Eip712DomainType(name: "verifyingContract", type: "address")],"Mail":[Eip712DomainType(name: "from", type:"address"),Eip712DomainType(name: "to", type: "address"),Eip712DomainType(name: "contents", type: "string")]]

let typedData = Shared.TypedData(domain: domain, types:types, primaryType: "Mail", message: ["from":Shared.Value.stringValue(inner: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"),"to":Shared.Value.stringValue(inner: "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"),"contents":Shared.Value.stringValue(inner: "Hello, Bob!")])
let sig = try! await self.smartAccount!.signTypedData(typedData: typedData)
```

### Verify Typed Data

```

```

## Methods of `SmartAccount`

The instance of `SmartAccount` returns the following functions:

- Get Smart Account Info
  - `address()` : returns the address of your smart account.
  - `isDeployed()` : returns the result whether your smart account is deployed in current chain.
  - `chainId()`: returns current chain id of your smart account.
- `switchChain()`: switch active chain
- `sendTransaction()`: returns the response of transaction
- `signMessage()`: returns the signature using personal sign
- `signTypedData()`: returns the signature using sign typed data

## Get Smart Account Info

`Address()`

This returns the address of your smart account.

```swift
let address = try? await smartAccount.address();
```

`isDeployed()`

This returns the result whether your smart account is deployed in current chain.

```swift
let isDeployed = try? await smartAccount.isDeployed();
```

`chainId()`

This returns current chain of your smart account.

```swift
let chainId = try? smartAccount.chainId(); // ChainID
```

`switchChain()`

Switch active chain
