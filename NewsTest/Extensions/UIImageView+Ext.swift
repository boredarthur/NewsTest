//
//  UIImageView+Ext.swift
//  NewsTest
//
//  Created by boredarthur on 19.01.2022.
//

import Foundation
import UIKit

extension UIImageView {
    func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
