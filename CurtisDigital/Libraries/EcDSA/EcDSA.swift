//
//  EcDSA.swift
//  Authoriti
//
//  Created by Rakib Ansary Saikot on 11/20/17.
//  Copyright © 2017 Rakib Ansary Saikot. All rights reserved.
//

import BigInt
import CryptoSwift

struct EcDSA {
    private var curve: ECcurve
    
    public init() {
        var curve62_5 = ECcurve(803734343, -3, 566674593, 803725957)
        curve62_5.G = ECpoint(
            curve62_5,
            759297038,
            125527788,
            1
        )
        
        self.curve = curve62_5
    }
    
    public func encodeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> String {
        return Util.encodeDate(year: year, month: month, day: day, hour: hour, minute: minute)
    }
    
    public func encodeDataTypes(selectedTypes: String, payload: String) -> String {
        let b = Util.intToBase62(Util.binaryToInt(selectedTypes), length: 2);
        let r = payload + b;
        
        return r;
    }
    
    public func encodeGeo(geo: String, payload: String) -> String {
        let p = BigInt(geo)
        let v = Util.intToBase62(p!)
        let r = payload + v
        return r
    }
    
    public func generate(password: String, salt: String? = nil) -> (salt: String, publicKey: String, privateKey: String) {
        let pwdBytes: Array<UInt8> = Array(password.utf8)
        let saltBytes: Array<UInt8>
        
        if (salt != nil) {
            saltBytes = Array<UInt8>(hex: salt!)
        } else {
            saltBytes = Util.generateRandomBytes(len: 5)!.bytes
        }
        
        var publicKey: String = ""
        var privateKey: String = ""
        
        do {
            let result = try PKCS5.PBKDF2(
                password: pwdBytes,
                salt: saltBytes,
                iterations: 4096,
                variant: .sha256
                ).calculate()
            
            let keypair = self.generate_keypair(seed: result)
            
            publicKey = keypair.publicKey
            privateKey = keypair.privateKey
        }
        catch {
            print ("Something went wrong")
        }
        
        return (saltBytes.toHexString(), publicKey, privateKey)
    }
    
    public func addAccountIdToPayload(accountId: String, payload: String) -> String {
        return Util.addAccountIdToPayload(accountId: accountId, payload: payload)
    }
    
    public func addIdentifierToAccountId(identifier: String, accountId: String) -> String {
        let s = Util.addIdentifierToAccountId(identifier: identifier, accountId: accountId)
        return s
    }
    
    private func get_public_key(_ private_key: BigInt) -> String {
        let G = curve.G
        let public_key = G.mul(private_key)
        
        return Util.intToBase62(public_key.get_x(), length: 5) + Util.intToBase62(public_key.get_y(), length: 5)
    }
    
    private func generate_keypair(seed: [UInt8]) -> (privateKey: String, publicKey: String) {
        let keypair = Util.makeKeyPair(29)
        let pubA = keypair.pub[0]
        let pubB = keypair.pub[1]
        
        let priA = keypair.priv[0]
        let priB = keypair.priv[1]
        
        let strPub = Util.intToBase62(pubA) + "-" + Util.intToBase62(pubB)
        let strPri = Util.intToBase62(priA) + "-" + Util.intToBase62(priB)
        
        let testPayload = "10rbkibGqs"
        let encrypted = self.sign(payload: testPayload, privateKey: strPri)
        if encrypted.length > 10 {
            return self.generate_keypair(seed:seed)
        }
        let decrypted = self.sign(payload: encrypted, privateKey: strPub)
        if testPayload != decrypted {
            return self.generate_keypair(seed:seed)
        }
        /*
         let privateKey = Util.mod(Util.intFromBytes(seed), BigInt(62).power(5))
         
         let base62PublicKey = self.get_public_key(privateKey)
         let base62PrivateKey = Util.intToBase62(privateKey)
         
         return (base62PrivateKey, base62PublicKey)
         */
        
        return (strPri, strPub)
    }
    
    /*
     public func decrypt(encrypted: String, publicKey: String) -> String {
     let parts = publicKey.split(separator: "-")
     let a: BigUInt = BigUInt(Util.base62ToInt(String(parts[0])))
     let b: BigUInt = BigUInt(Util.base62ToInt(String(parts[1])))
     
     let zz = BigUInt(Util.base62ToInt(encrypted))
     let decrypted = Util.sign(zz, [a, b])
     
     return Util.intToBase62(decrypted);
     
     }
     */
    
    public func sign(payload: String, privateKey: String) -> String {
        let parts = privateKey.split(separator: "-")
        let a: BigUInt = BigUInt(Util.base62ToInt(String(parts[0])))
        let b: BigUInt = BigUInt(Util.base62ToInt(String(parts[1])))
        let zz = BigUInt(Util.base62ToInt(payload))
        let encrypted = Util.sign(zz, [a, b])
        
        let ret = Util.intToBase62(encrypted, length: 10);
        return ret
        /*
         let G = self.curve.G
         let n = curve.n
         let d = Util.base62ToInt(privateKey)
         
         let z = Util.intFromBytes(payload.bytes)
         let kbytes = Util.intFromBytes(Util.generateRandomBytes(len: 6)!.bytes)
         let k = Util.mod(kbytes, n)
         
         let C = G.mul(k) // Move down the curve by k
         
         let r = Util.mod(C.get_x(), n) // Part 1 of signature
         let s = (((z + r*d) % n) * Util.modular_inverse(k, n)) % n // n # Part 2 of signature
         
         // MSB is dropped off
         
         let a = Util.intToBase62(r, length: 5)
         let b = Util.intToBase62(s, length: 5)
         /*
         a.remove(at: a.startIndex)
         b.remove(at: b.startIndex)
         */
         let signature = a + b
         
         let p = "15ZZZZZZZZ"
         let zz = BigUInt(Util.base62ToInt(p))
         print ("Encrypting", Util.intToBase62(zz))
         
         let keys = Util.makeKeyPair(30)
         let num: BigUInt = BigUInt(zz)
         let encrypted = Util.sign(num, keys.priv)
         
         print("Private keys", keys.priv)
         
         let sign = Util.intToBase62(encrypted);
         print("Encrypted", sign)
         
         let decrypted = Util.sign(BigUInt(Util.base62ToInt(sign)), keys.pub)
         
         print("Decrypted", Util.intToBase62(decrypted))
         */
    }
}

