import XCTest
import CryptoKit
@testable import Common
@testable import Core
@testable import Networking
@testable import Security
@testable import Logging
@testable import Storage

final class AOSCoreTests: XCTestCase {
    
    // MARK: - Encryption Tests
    func testEncryptionSymmetry() throws {
        let originalText = "Target Secure Journal Entry: Catastrophizing reframed."
        let key = EncryptionHelper.generateSymmetricKey()
        
        // Encrypt plain text
        let cipherText = try EncryptionHelper.encrypt(plainText: originalText, using: key)
        XCTAssertNotEqual(originalText, cipherText)
        XCTAssertFalse(cipherText.isEmpty)
        
        // Decrypt cipher text
        let decryptedText = try EncryptionHelper.decrypt(base64CipherText: cipherText, using: key)
        XCTAssertEqual(originalText, decryptedText)
    }
    
    func testKeySerialization() {
        let originalKey = EncryptionHelper.generateSymmetricKey()
        let hexString = originalKey.toHex()
        
        XCTAssertFalse(hexString.isEmpty)
        
        let deserializedKey = SymmetricKey.fromHex(hexString)
        XCTAssertNotNil(deserializedKey)
        XCTAssertEqual(originalKey.toHex(), deserializedKey?.toHex())
    }
    
    // MARK: - Keychain Manager Tests
    func testKeychainLifecycle() {
        let keyName = "com.atharva.os.testKey"
        let secretValue = "secure_token_abc123"
        
        // Save to Keychain
        let saveSuccess = KeychainManager.shared.save(key: keyName, secret: secretValue)
        XCTAssertTrue(saveSuccess)
        
        // Load from Keychain
        let loadedValue = KeychainManager.shared.load(key: keyName)
        XCTAssertEqual(secretValue, loadedValue)
        
        // Delete from Keychain
        let deleteSuccess = KeychainManager.shared.delete(key: keyName)
        XCTAssertTrue(deleteSuccess)
        
        // Load deleted key returns nil
        let postDeleteValue = KeychainManager.shared.load(key: keyName)
        XCTAssertNil(postDeleteValue)
    }
    
    // MARK: - API Endpoint Tests
    func testAPIEndpointSetup() {
        let endpoint = APIEndpoint.login(body: Data())
        XCTAssertEqual(endpoint.path, "/v1/auth/login")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(endpoint.headers["Content-Type"], "application/json")
        XCTAssertEqual(endpoint.headers["Accept"], "application/json")
    }
}
