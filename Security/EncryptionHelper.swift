import Foundation
import CryptoKit

public final class EncryptionHelper {
    
    /// Generates a new 256-bit cryptographically secure symmetric key.
    public static func generateSymmetricKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
    
    /// Encrypts plain text using a symmetric key, returning a Base64-encoded encrypted string.
    public static func encrypt(plainText: String, using key: SymmetricKey) throws -> String {
        guard let data = plainText.data(using: .utf8) else {
            throw NSError(domain: "AOSEncryptionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid text encoding."])
        }
        
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combinedData = sealedBox.combined else {
            throw NSError(domain: "AOSEncryptionError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Combined ciphertext data generation failed."])
        }
        
        return combinedData.base64EncodedString()
    }
    
    /// Decrypts a Base64-encoded encrypted string using a symmetric key.
    public static func decrypt(base64CipherText: String, using key: SymmetricKey) throws -> String {
        guard let combinedData = Data(base64Encoded: base64CipherText) else {
            throw NSError(domain: "AOSEncryptionError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 ciphertext input."])
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let plainText = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "AOSEncryptionError", code: -4, userInfo: [NSLocalizedDescriptionKey: "Decrypted data cannot be decoded to UTF-8."])
        }
        
        return plainText;
    }
}
extension SymmetricKey {
    /// Serializes a key to a Hex String for secure storage.
    public func toHex() -> String {
        return self.withUnsafeBytes { Data($0).map { String(format: "%02hhx", $0) }.joined() }
    }
    
    /// Deserializes a Hex String to a SymmetricKey.
    public static func fromHex(_ hexString: String) -> SymmetricKey? {
        var data = Data()
        var hex = hexString
        while hex.count > 0 {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            if let b = UInt8(c, radix: 16) {
                data.append(b)
            } else {
                return nil
            }
        }
        return SymmetricKey(data: data)
    }
}
