//
//  Util.swift
//  Authoriti
//
//  Created by Rakib Ansary Saikot on 11/20/17.
//  Copyright © 2017 Rakib Ansary Saikot. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

func divmod(_ a: BigInt, _ b: BigInt) -> (quotient: BigInt, modulus: BigInt) {
    let quotient = a / b
    let remainder = a % b
    
    if quotient > 0 || remainder == 0 {
        return (quotient, remainder)
    } else if quotient == 0 && a > 0 && b < 0 {
        let div = quotient - 1
        let result = (div * b) - a
        return (div, -result)
    } else {
        let signSituation = a > 0 || b < 0
        let div = ((quotient == 0) && signSituation) ? quotient : quotient - 1
        let result = abs((div * b) - a)
        
        return (div, (b < 0) ? -result: result)
    }
}

func absoluteValue(_ num: BigInt) -> BigInt {
    return num < 0 ? -num : num
}

public struct Util {
    private static var ALPHANUM: String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private static var BASE: BigInt = BigInt(62)
    
    private static func intToBase38(_ nn: Int, length: Int = 0) -> String {
        var num = nn;
        var str: String = ""
        while num != 0 {
            let index = Int(num % 38)
            str = str + ALPHANUM[index]
            num = num / 38
        }
        
        while str.length < length {
            str = str + ALPHANUM[0]
        }
        
        return String(str.characters.reversed())
    }
    
    public static func intToBase62(_ nn: BigInt, length: Int = 0) -> String {
        var num = nn
        var str: String = ""
        while num != 0 {
            let index = Int(num % BASE)
            str = str + ALPHANUM[index]
            num = num / BASE
        }
        
        while str.length < length {
            str = str + ALPHANUM[0]
        }
        
        return String(str.characters.reversed())
    }
    
    public static func intToBase62(_ nn: BigUInt, length: Int = 0) -> String {
        var num = nn
        var str: String = ""
        let base = BigUInt(62)
        while num != 0 {
            let index = Int(num % base)
            str = str + ALPHANUM[index]
            num = num / base
        }
        
        while str.length < length {
            str = str + ALPHANUM[0]
        }
        
        return String(str.characters.reversed())
    }
    
    public static func binaryToInt(_ binary: String) -> BigInt {
        var result = BigInt(0)
        let two = BigInt(2)
        let one = BigInt(1)
        for digit in binary {
            switch(digit) {
            case "0": result = result * two
            case "1": result = result * two + one
            default: continue;
            }
        }
        return result
    }
    
    public static func base62ToInt(_ str: String) -> BigInt {
        let b62 = String(str.characters.reversed())
        
        var num = BigInt(0)
        var mult = BigInt(1)
        for c in b62 {
            let asciiCode = c.unicodeScalars.first?.value
            var index: UInt32 = 0
            if asciiCode! >= 97 && asciiCode! <= 122 {
                index = asciiCode! - 97 + 10
            } else if asciiCode! >= 65 && asciiCode! <= 90 {
                index = asciiCode! - 65 + 10 + 26
            } else if asciiCode! >= 48 && asciiCode! <= 57 {
                index = asciiCode! - 48
            }
            
            let val = BigInt(index)
            num += val*mult
            mult *= 62
            
        }
        return num
    }
    
    public static func encodeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> String {
        // Specify date components
        var end = DateComponents()
        end.year = year
        end.month = month
        end.day = day
        end.hour = hour
        end.minute = minute
        end.timeZone = TimeZone.init(identifier: "UTC")
        
        var start = DateComponents()
        start.year = 2017
        start.month = 11
        start.day = 1
        start.hour = 0
        start.minute = 0
        start.timeZone = TimeZone.init(identifier: "UTC")

        let minutes = Calendar.current.dateComponents([.minute], from: start, to: end).minute!
        var strDate = self.intToBase62(BigInt(minutes), length: 4);
        if strDate.length > 4 {
            strDate = "ZZZZ"
        }
        return strDate
    }
    
    public static func generateRandomBytes(len: Int) -> Data? {
        
        var keyData = Data(count: len)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    public static func intFromBytes(_ array: [UInt8]) -> BigInt {
        var value : BigInt = BigInt(0)
        let eight = BigInt(8)
        for byte in array {
            value = value << eight
            value = value | BigInt(byte)
        }
        
        return value;
    }
    
    public static func mod(_ a: BigInt, _ n: BigInt) -> BigInt {
        precondition(n > 0, "modulus must be positive")
        let r = a % n
        return r >= 0 ? r : r + n
    }
    
    public static func half_extended_gcd(_ aa: BigInt, _ bb: BigInt) -> (rem: BigInt, x: BigInt) {
        var lastrem = absoluteValue(aa)
        var rem = absoluteValue(bb)
        
        var x = BigInt(0)
        var lastx = BigInt(1)
        
        while rem > 0 {
            let tempRem = rem
            let result = divmod(lastrem, rem)
            let quotient = result.quotient
            
            rem = result.modulus
            lastrem = tempRem
            
            let tempx = lastx
            lastx = x
            x = tempx - quotient * x
        }
        
        return (lastrem, lastx)
    }
    
    public static func modular_inverse(_ a: BigInt, _ m: BigInt) -> BigInt {
        let result = half_extended_gcd(a, m)
        let x = result.x
        
        return self.mod(x, m)
    }
    
    public static func addIdentifierToAccountId(identifier: String, accountId: String) -> String {
        let acc = self.cleanup(str: accountId, maximum: 4)
        let _identifier = self.cleanup(str: identifier, maximum: identifier.length);
        let id = self.cleanup(str: _identifier.md5(), maximum: 4);
        let a = self.base62ToInt(acc)
        let b = self.base62ToInt(id)
        
        let c = a + b
        let r = self.intToBase62(c)
        return r
    }
    
    public static func addAccountIdToPayload(accountId: String, payload: String) -> String {
        let acc = self.cleanup(str: accountId, maximum: 4);
        let p = self.cleanup(str: payload, maximum: 10)
        
        let base64Acc = self.base62ToInt(acc)
        let base64P = self.base62ToInt(p)
        
        let sum = base64P + base64Acc
        
        let ret = intToBase62(sum);
        return ret;
    }
    
    public static func cleanup(str: String, maximum: Int = 6) -> String {
        var max = maximum
        var a = ""
        for c in str {
            let asciiCode = c.unicodeScalars.first?.value
            if asciiCode! >= 97 && asciiCode! <= 122 {
                a = a + String(c)
                max = max - 1
            } else if asciiCode! >= 65 && asciiCode! <= 90 {
                a += String(c)
                max = max - 1
            } else if asciiCode! >= 48 && asciiCode! <= 57 {
                a += String(c)
                max = max - 1
            }
            
            if max == 0 {
                break
            }
        }
        
        return a
    }
    
    private static func generatePrime(_ width: Int) -> BigUInt {
        while true {
            var random = BigUInt.randomInteger(withExactWidth: width)
            random |= BigUInt(1)
            if random.isPrime() {
                return random
            }
        }
    }
    
    public static func makeKeyPair(_ length: Int) -> (pub: [BigUInt], priv: [BigUInt]) {
        let p = self.generatePrime(length)
        let q = self.generatePrime(length)
        let n = p * q
        
        let e: BigUInt = 65537
        let phi = (p - 1) * (q - 1)
        let d = e.inverse(phi)!
        
        let publicKey: [BigUInt] = [n, e]
        let privateKey: [BigUInt] = [n, d]
        
        return (publicKey, privateKey)
    }
    
    public static func sign(_ message: BigUInt, _ key: [BigUInt]) -> BigUInt {
        return message.power(key[1], modulus: key[0])
    }
}


extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

