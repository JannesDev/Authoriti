//
//  String+Extension.swift
//  CurtisDigital
//
//  Created by mobilestar on 12/1/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

extension String {
    
    func trimSpecialCharactors() -> String {
        let okayChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        return String(self.characters.filter {okayChars.contains($0) }).lowercased()
    }
}
