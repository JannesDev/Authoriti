//
//  ECcurve.swift
//  Authoriti
//
//  Created by Rakib Ansary Saikot on 11/20/17.
//  Copyright © 2017 Rakib Ansary Saikot. All rights reserved.
//

import BigInt

struct ECcurve {
    var p: BigInt
    var a: BigInt
    var b: BigInt
    var n: BigInt
    
    private var _g: ECpoint?
    var G: ECpoint {
        set { _g = newValue }
        get { return _g! }
    }
    
    public init(_ p: BigInt, _ a: BigInt, _ b: BigInt, _ n: BigInt) {
        self.p = p
        self.a = a
        self.b = b
        self.n = n
    }
    
// Prime field multiplication: return a*b mod p
    public func field_mul(_ a: BigInt , _ b: BigInt) -> BigInt {
        return Util.mod((a * b), self.p)
    }

// Prime field division: return num/den mod p
    public func field_div(_ num: BigInt, _ den: BigInt) -> BigInt {
        let inverse_den = Util.modular_inverse(Util.mod(den, self.p), self.p)
        return self.field_mul(Util.mod(num, self.p), inverse_den)
    }
    

// Return the special identity point
//   We pick x=p, y=0
    func identity() -> ECpoint {
        return ECpoint(self, self.p, 0, 1)
    }
    
// Return true if point Q lies on our curve
    func touches(_ Q: ECpoint) -> Bool {
        let x = Q.get_x()
        let y = Q.get_y()
        let y2 = Util.mod((y*y), self.p)
        let x3ab = Util.mod((self.field_mul(Util.mod((x * x), self.p) + self.a, x) + self.b), self.p)
        
        return y2 == Util.mod(x3ab, self.p)
    }
    
// Return the slope of the tangent of this curve at point Q
    func tangent(_ Q: ECpoint) -> BigInt {
        return self.field_div(Q.x * Q.x * 3 + self.a, Q.y * 2)
    }
    
// Return a doubled version of this elliptic curve point
// Closely follows Gueron & Krasnov 2013 figure 2
    func double(_ Q: ECpoint) -> ECpoint {
        if (Q.x==self.p){ // doubling the identity
            return Q
        }
        
        let S = Util.mod((4 * Q.x * Q.y * Q.y), self.p)
        let Z2 = Q.z * Q.z
        let Z4 = Util.mod((Z2 * Z2), self.p)
        let M = (3 * Q.x * Q.x + self.a * Z4)
        let x = Util.mod((M * M - 2 * S), self.p)
        let Y2  = Q.y * Q.y
        let y = Util.mod((M * (S - x) - 8 * Y2 * Y2), self.p)
        let z = Util.mod((2 * Q.y * Q.z), self.p)
        return ECpoint(self,x,y,z)
    }

    // Return the "sum" of these elliptic curve points
    // Closely follows Gueron & Krasnov 2013 figure 2
    func add(_ Q1: ECpoint, _ Q2: ECpoint) -> ECpoint {
        // Identity special cases
        if (Q1.x == self.p) { // Q1 is identity
            return Q2
        }
        
        if (Q2.x==self.p){ // Q2 is identity
            return Q1
        }
        
        let Q1z2 = Q1.z * Q1.z
        let Q2z2 = Q2.z * Q2.z
        let xs1 = Util.mod((Q1.x * Q2z2), self.p)
        let xs2 = Util.mod((Q2.x * Q1z2), self.p)
        let ys1 = Util.mod((Q1.y * Q2z2 * Q2.z), self.p)
        let ys2 = Util.mod((Q2.y * Q1z2 * Q1.z), self.p)

        // Equality special cases
        if (xs1 == xs2) {
            if (ys1 == ys2) { // adding point to itself
                return self.double(Q1)
            }
            else { // vertical pair--result is the identity
                return self.identity()
            }
        }
        
        // Ordinary case
        let xd = Util.mod((xs2 - xs1), self.p)   // caution: if not python, negative result?
        let yd = Util.mod((ys2 - ys1), self.p)
        let xd2 = Util.mod((xd * xd), self.p)
        let xd3 = Util.mod((xd2 * xd), self.p)
        let x = Util.mod((yd * yd - xd3 - 2 * xs1 * xd2), self.p)
        let y = Util.mod((yd*(xs1 * xd2 - x) - ys1 * xd3), self.p)
        let z = Util.mod((xd * Q1.z * Q2.z), self.p)
        
        return ECpoint(self, x, y, z)
    }

// "Multiply" this elliptic curve point Q by the scalar (integer) m
// Often the point Q will be the generator G
    func mul(_ mm: BigInt, _ QQ: ECpoint) -> ECpoint {
        var m = mm
        var Q = QQ
        var R = self.identity() // return point
        while m != 0 {  // binary multiply loop
            if m & 1 == 1 { // bit is set
                R = self.add(R,Q)
            }
            m = m >> 1
            if (m != 0) {
                // print("  mul: doubling Q =",Q);
                Q = self.double(Q)
            }
        }
        return R
    }
}

