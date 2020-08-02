/*
*  Copyright (C) 2020 Groupe MINASTE
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*
*/

import Foundation
import CryptoSwift
#if !os(Linux)
import CommonCrypto
#endif

class EncryptionManager {
    
    // Store keys
    static var keys: (publicKey: SecKey, privateKey: SecKey)? = {
        // Generation of RSA private and public keys
        let parameters: [String:Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: 1024]
        var publicKey, privateKey: SecKey?
        SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
        
        // Get keys
        if let publicKey = publicKey, let privateKey = privateKey {
            return (publicKey, privateKey)
        }
        return nil
    }()
    
    // Get data for a key
    @available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *)
    static func getData(for key: SecKey) -> Data? {
        if let data = SecKeyCopyExternalRepresentation(key, nil) {
            return addDERHeader(data as Data)
        }
        return nil
    }
    
    // Check if encryption is supported
    static func supportsEncryption() -> Bool {
        #if !os(Linux)
        if #available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *) {
            return keys != nil
        }
        #endif
        return false
    }
    
    // Generate an encryption request
    @available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *)
    static func generateRequest() -> EncryptionRequest {
        // Server hash
        let hash = String(Int64.random(in: 1000000000000000 ..< 9999999999999999))
        
        // Public key
        var publicKey = [UInt8]()
        if let key = keys?.publicKey, let data = getData(for: key) {
            // Add key info
            publicKey.append(contentsOf: [UInt8](data))
        }
        
        // Verify token
        var verify = [UInt8]()
        for _ in 0 ..< 4 {
            verify.append(UInt8.random(in: 0 ..< 255))
        }
        
        // Wrap everything
        return EncryptionRequest(serverId: hash, publicKey: publicKey, verifyToken: verify)
    }
    
    @available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *)
    static func getSecKey(from data: Data) -> SecKey? {
        let attributes: [String: Any] = [kSecAttrKeyClass as String: kSecAttrKeyClassPublic, kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: 1024]
        return SecKeyCreateWithData(data as CFData, attributes as CFDictionary, nil)
    }
    
    @available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *)
    static func getSecret(response: EncryptionResponse, request: EncryptionRequest) -> [UInt8]? {
        if let privateKey = keys?.privateKey, let decrypted = decrypt(privateKey: privateKey, content: Data(response.verifyToken) as CFData, usingAlgorithm: .rsaEncryptionPKCS1) as Data?, [UInt8](decrypted) == request.verifyToken, let secret = decrypt(privateKey: privateKey, content: Data(response.sharedSecret) as CFData, usingAlgorithm: .rsaEncryptionPKCS1) as Data? {
            return [UInt8](secret)
        }
        return nil
    }
    
    @available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *)
    static func encrypt(content: CFData, publicKey: SecKey, usingAlgorithm: SecKeyAlgorithm) -> CFData? {
        var status = Unmanaged<CFError>?.init(nilLiteral: ())
            
        let data = SecKeyCreateEncryptedData(publicKey, usingAlgorithm, content, &status)
            
        if let stat = status?.takeRetainedValue(), stat.localizedDescription.isEmpty {
            return nil
        }
            
        return data
    }
    
    @available(iOS 10.0, tvOS 10.0, macOS 10.12, watchOS 3.0, *)
    static func decrypt(privateKey: SecKey, content: CFData, usingAlgorithm: SecKeyAlgorithm) -> CFData? {
        // Decrypt the entrypted string with the private key
        var status = Unmanaged<CFError>?.init(nilLiteral: ())
        
        let decrypted = SecKeyCreateDecryptedData(privateKey, usingAlgorithm, content, &status)
            
        if let stat = status?.takeRetainedValue(), stat.localizedDescription.isEmpty {
            return nil
        }
                    
        return decrypted
    }
    
    static func addDERHeader(_ derKey: Data) -> Data {
        var result = Data()

        let encodingLength: Int = encodedOctets(derKey.count + 1).count
        let OID: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]

        var builder: [UInt8] = []

        // ASN.1 SEQUENCE
        builder.append(0x30)

        // Overall size, made of OID + bitstring encoding + actual key
        let size = OID.count + 2 + encodingLength + derKey.count
        let encodedSize = encodedOctets(size)
        builder.append(contentsOf: encodedSize)
        result.append(builder, count: builder.count)
        result.append(OID, count: OID.count)
        builder.removeAll(keepingCapacity: false)

        builder.append(0x03)
        builder.append(contentsOf: encodedOctets(derKey.count + 1))
        builder.append(0x00)
        result.append(builder, count: builder.count)

        // Actual key bytes
        result.append(derKey)

        return result
    }
    
    static func encodedOctets(_ int: Int) -> [UInt8] {
        // Short form
        if int < 128 {
            return [UInt8(int)]
        }

        // Long form
        let i = (int / 256) + 1
        var len = int
        var result: [UInt8] = [UInt8(i + 0x80)]

        for _ in 0 ..< i {
            result.insert(UInt8(len & 0xFF), at: 1)
            len = len >> 8
        }

        return result
    }
    
    // TEMP CODE UNTIL CRYPTOSWIFT ADDS SUPPORT FOR CFB8:
    
    public enum Mode {
        case encrypt, decrypt
    }
    
    #if !os(Linux)
    public static func crypt(_ opMode: EncryptionManager.Mode, data: Data, key: Data, iv: Data) -> Data? {
        var cryptor: CCCryptorRef?
        var status = withUnsafePointers(iv, key, { ivBytes, keyBytes in
            return CCCryptorCreateWithMode(
                CCOperation(opMode == .encrypt ? kCCEncrypt : kCCDecrypt),
                CCMode(kCCModeCFB8),
                CCAlgorithm(kCCAlgorithmAES), 0,
                ivBytes, keyBytes, key.count,
                nil, 0, 0,
                CCModeOptions(), &cryptor)
        })

        guard status == noErr else { return nil }

        defer { _ = CCCryptorRelease(cryptor!) }

        let needed = CCCryptorGetOutputLength(cryptor!, data.count, true)
        var result = Data(count: needed)
        let rescount = result.count
        var updateLen: size_t = 0
        status = withUnsafePointers(data, &result, { dataBytes, resultBytes in
            return CCCryptorUpdate(
                cryptor!,
                dataBytes, data.count,
                resultBytes, rescount,
                &updateLen)
        })
        guard status == noErr else { return nil }

        var finalLen: size_t = 0
        status = result.withUnsafeMutableBytes { resultBytes in
            return CCCryptorFinal(
                cryptor!,
                resultBytes + updateLen,
                rescount - updateLen,
                &finalLen)
        }
        guard status == noErr else { return nil }

        result.count = updateLen + finalLen
        return result
    }
    
    static fileprivate func withUnsafePointers<A0, A1, Result>(
        _ arg0: Data,
        _ arg1: Data,
        _ body: (
        UnsafePointer<A0>, UnsafePointer<A1>) throws -> Result
        ) rethrows -> Result {
        return try arg0.withUnsafeBytes { p0 in
            return try arg1.withUnsafeBytes { p1 in
                return try body(p0, p1)
            }
        }
    }
    
    static fileprivate func withUnsafePointers<A0, A1, Result>(
        _ arg0: Data,
        _ arg1: inout Data,
        _ body: (
            UnsafePointer<A0>,
            UnsafeMutablePointer<A1>) throws -> Result
        ) rethrows -> Result {
        return try arg0.withUnsafeBytes { p0 in
            return try arg1.withUnsafeMutableBytes { p1 in
                return try body(p0, p1)
            }
        }
    }
    #else
    public static func crypt(_ opMode: EncryptionManager.Mode, data: Data, key: Data, iv: Data) -> Data? {
        return nil
    }
    #endif
    
}
