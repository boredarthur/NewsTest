//
//  NewsImageView.swift
//  NewsTest
//
//  Created by boredarthur on 19.01.2022.
//

import UIKit

class NewsImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius  = 10
        clipsToBounds       = true
    }
}
