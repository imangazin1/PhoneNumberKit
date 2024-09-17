//
//  EmptyView.swift
//  PhoneNumberKit
//
//  Created by Akzhol Imangazin on 17.09.2024.
//  Copyright © 2024 Roy Marmelstein. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    // MARK: - Views
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MAARK: - Helpers
    private func setup() {
        [imageView, titleLabel, subTitleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    func configure(icon: UIImage?, title: String?, titleFont: UIFont?, textColor: UIColor?, subtitle: String?, subtitleFont: UIFont?, subTitlecolor: UIColor?, query: String) {
        imageView.image = icon
        titleLabel.font = titleFont
        titleLabel.text = title
        titleLabel.textColor = textColor
        
        let mainString = subtitle?.replacingOccurrences(of: "%@", with: query) ?? ""
        let queryString = "«\(query)»"
        let range = (mainString as NSString).range(of: queryString)
        let attributedText = NSMutableAttributedString(
            string: mainString, attributes: [
                .foregroundColor: textColor ?? .lightGray,
                .font: subtitleFont ?? .systemFont(ofSize: 14)
            ])
        attributedText.addAttribute(
            .foregroundColor,
            value: subTitlecolor ?? .black,
            range: range)
        
        self.subTitleLabel.attributedText = attributedText
    }
}
