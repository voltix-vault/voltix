//
//  UTXOChainsHelperTest.swift
//  VoltixAppTests
//

import Tss
@testable import VoltixApp
import WalletCore
import XCTest

final class UTXOChainsHelperTest: XCTestCase {
    let hexPublicKey = "023e4b76861289ad4528b33c2fd21b3a5160cd37b3294234914e21efb6ed4a452b"
    let hexChainCode = "c9b189a8232b872b8d9ccd867d0db316dd10f56e729c310fe072adf5fd204ae7"
    
    func testGetCoin() throws {
        let utxoHelper = UTXOChainsHelper(coin: .bitcoin, vaultHexPublicKey: hexPublicKey, vaultHexChainCode: hexChainCode)
        let btcResult = utxoHelper.getCoin()
        switch btcResult {
        case .success(let btc):
            XCTAssertNotNil(btc)
            XCTAssertEqual(btc.chain.ticker, "BTC")
            XCTAssertEqual(btc.address, "bc1qj9q4nsl3q7z6t36un08j6t7knv5v3cwnnstaxu")
            XCTAssertEqual(btc.hexPublicKey, "026724d27f668b88513c925360ba5c5888cc03641eccbe70e6d85023e7c511b969")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
        
        let bitcoinCashHelper = UTXOChainsHelper(coin: .bitcoinCash, vaultHexPublicKey: hexPublicKey, vaultHexChainCode: hexChainCode)
        let bitcoinCashResult = bitcoinCashHelper.getCoin()
        switch bitcoinCashResult {
        case .success(let bch):
            XCTAssertNotNil(bch)
            XCTAssertEqual(bch.chain.ticker, "BCH")
            XCTAssertEqual(bch.address, "bitcoincash:qrfc9f9ta67l6x3ufcv8fdz83228r2vtcqmnul7jgx")
            XCTAssertEqual(bch.hexPublicKey, "0333bda0119776bd3f22b5dc6b1083bd3f5993b4d4b10b26db2dc55b919a5bb587")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
        
        let litecoinHelper = UTXOChainsHelper(coin: .litecoin, vaultHexPublicKey: hexPublicKey, vaultHexChainCode: hexChainCode)
        let ltcResult = litecoinHelper.getCoin()
        switch ltcResult {
        case .success(let ltc):
            XCTAssertNotNil(ltc)
            XCTAssertEqual(ltc.chain.ticker, "LTC")
            XCTAssertEqual(ltc.address, "ltc1q94hcz4uhl8gvw3pkqpfrhrxsglnlnrrr7lftpn")
            XCTAssertEqual(ltc.hexPublicKey, "0278fb4446eb161e89e33e4bf365dc465c9117c7a9808899eefced1bf905b57256")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
        
        let dogeHelper = UTXOChainsHelper(coin: .dogecoin, vaultHexPublicKey: hexPublicKey, vaultHexChainCode: hexChainCode)
        let dogeResult = dogeHelper.getCoin()
        switch dogeResult {
        case .success(let doge):
            XCTAssertNotNil(doge)
            XCTAssertEqual(doge.chain.ticker, "DOGE")
            XCTAssertEqual(doge.address, "DAcwwKfZ1RR4c8Gtg7kREtDuDivpkHFgF7")
            XCTAssertEqual(doge.hexPublicKey, "022ee50cb6713fb3c0014451dc103ecf8071c837fb417d9caa84f64ffa79504fbf")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
    }
    
    func testGetPreSignedImageHash() throws {
        let utxoHelper = UTXOChainsHelper(coin: .bitcoin, vaultHexPublicKey: hexPublicKey, vaultHexChainCode: hexChainCode)
        let c = try utxoHelper.getCoin().get()
        let result = utxoHelper.getPreSignedImageHash(keysignPayload: KeysignPayload(coin: c,
                                                                                     toAddress: "bc1q4e4y3g85dtkx0yp3l2flj2nmugf23c9wwtjwu5",
                                                                                     toAmount: 10000000,
                                                                                     chainSpecific: BlockChainSpecific.UTXO(byteFee: 20),
                                                                                     utxos: [UtxoInfo(hash: "631fad872ac6bea810cf6073f02e6cbd121cac83193b79f381f711ce93b531f0", amount: 193796, index: 1)],
                                                                                     memo: "voltix", swapPayload: nil, vaultPubKeyECDSA: "ECDSAKey"))
        switch result {
        case .success(let preSignImage):
            XCTAssertNotNil(preSignImage)
            XCTAssertTrue(preSignImage.count == 1)
            XCTAssertEqual(preSignImage[0], "14249cd992ccb9f8fb0e9f24dfe4437231819c6e02c52959b939a65eb533cbd4")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
    }

    func testGetBitcoinCashPreSignedImageHash() throws {
        let utxoHelper = UTXOChainsHelper(coin: .bitcoinCash, vaultHexPublicKey: hexPublicKey, vaultHexChainCode: hexChainCode)
        let c = try utxoHelper.getCoin().get()
        let result = utxoHelper.getPreSignedImageHash(keysignPayload: KeysignPayload(coin: c,
                                                                                     toAddress: "bitcoincash:qqxjcn4u4fgxvclqyaprkem3hptm3nf5yq3ryq70ry",
                                                                                     toAmount: 1000000,
                                                                                     chainSpecific: BlockChainSpecific.UTXO(byteFee: 20),
                                                                                     utxos: [UtxoInfo(hash: "71787a90556de944fcea8d8ff7478e535092638a68491b60b5661dfd871c40e4", amount: 10000000, index: 0)],
                                                                                     memo: "voltix", swapPayload: nil, vaultPubKeyECDSA: "ECDSAKey"))
        switch result {
        case .success(let preSignImage):
            XCTAssertNotNil(preSignImage)
            XCTAssertTrue(preSignImage.count == 1)
            XCTAssertEqual(preSignImage[0], "195b256774ca393f2e9812478abf6958076d0ff7d427dc958d35a9f7ffe7439b")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
        let resp = TssKeysignResponse()
        resp.derSignature = "3044022058355128efd16e9d71dfb351203d65268ea479ee3c214c2f1bc99b749c938b38022036c25424f83265ef93eb1f179444c528368b8efc62280297c4cc6d24407c2a91"
        let signature: [String: TssKeysignResponse] = ["195b256774ca393f2e9812478abf6958076d0ff7d427dc958d35a9f7ffe7439b": resp]
        let signedTxResult = utxoHelper.getSignedTransaction(keysignPayload: KeysignPayload(coin: c,
                                                                                            toAddress: "bitcoincash:qqxjcn4u4fgxvclqyaprkem3hptm3nf5yq3ryq70ry",
                                                                                            toAmount: 1000000,
                                                                                            chainSpecific: BlockChainSpecific.UTXO(byteFee: 20),
                                                                                            utxos: [UtxoInfo(hash: "71787a90556de944fcea8d8ff7478e535092638a68491b60b5661dfd871c40e4", amount: 10000000, index: 0)],
                                                                                            memo: "voltix",
                                                                                            swapPayload: nil, vaultPubKeyECDSA: "ECDSAKey"),
                                                             signatures: signature)
        switch signedTxResult {
        case .success(let tx):
            XCTAssertEqual(tx, "0100000001e4401c87fd1d66b5601b49688a639250538e47f78f8deafc44e96d55907a7871000000006a473044022058355128efd16e9d71dfb351203d65268ea479ee3c214c2f1bc99b749c938b38022036c25424f83265ef93eb1f179444c528368b8efc62280297c4cc6d24407c2a9141210333bda0119776bd3f22b5dc6b1083bd3f5993b4d4b10b26db2dc55b919a5bb587ffffffff0340420f00000000001976a9140d2c4ebcaa506663e027423b6771b857b8cd342088acf03f8900000000001976a914d382a4abeebdfd1a3c4e1874b4478a9471a98bc088ac0000000000000000086a06766f6c74697800000000")
        case .failure(let err):
            XCTFail("Expected success, but got error: \(err)")
        }
    }
}
