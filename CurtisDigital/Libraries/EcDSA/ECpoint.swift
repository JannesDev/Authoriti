//
//  ECpoint.swift
//  Authoriti
//
//  Created by Rakib Ansary Saikot on 11/20/17.
//  Copyright © 2017 Rakib Ansary Saikot. All rights reserved.
//

import BigInt

class ECpoint {
    var x: BigInt
    var y: BigInt
    var z: BigInt
    var curve: ECcurve
    
    public init(_ curve: ECcurve, _ x: BigInt, _ y: BigInt, _ z: BigInt){
        self.curve = curve
        self.x = x
        self.y = y
        self.z = z
    }
    
    // "Add" this point to another point on the same curve
    public func add(_ Q2: ECpoint) -> ECpoint {
        return self.curve.add(self, Q2)
    }
    
    // "Multiply" this point by a scalar
    public func mul(_ m: BigInt) -> ECpoint {
        return self.curve.mul(m, self)
    }
    
    // Extract non-projective X and Y coordinates
    //   This is the only time we need the expensive modular inverse
    public func get_x() -> BigInt {
        return self.curve.field_div(self.x, Util.mod((self.z * self.z), self.curve.p))
    }
    
    public func get_y() -> BigInt {
        return self.curve.field_div(self.y, Util.mod((self.z * self.z * self.z), self.curve.p))
    }
    
}

extension ECpoint: CustomStringConvertible {
    var description: String {
        if self.x == self.curve.p {
            return "identity_point"
        }
        else {
            return "(" + String(self.get_x()) + ", " + String(self.get_y()) + ")"
        }
    }
}
