//
//  ShadowedView.swift
//  CurtisDigital
//
//  Created by Brian on 2017-11-29.
//  Copyright © 2017 Mark. All rights reserved.
//

import MaterialComponents

class ShadowedView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDefaultElevation()
    }
    override class var layerClass: AnyClass {
        return MDCShadowLayer.self
    }
    
    var shadowLayer: MDCShadowLayer {
        return self.layer as! MDCShadowLayer
    }
    
    func setDefaultElevation() {
        self.shadowLayer.elevation = ShadowElevation.cardResting
    }
    
}
