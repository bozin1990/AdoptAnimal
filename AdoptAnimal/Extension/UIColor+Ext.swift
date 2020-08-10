//
//  UIColor+Ext.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/9.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let redValue = CGFloat(red) / 255.0
        let greenValue = CGFloat(green) / 255.0
        let blueValue = CGFloat(blue) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
}
