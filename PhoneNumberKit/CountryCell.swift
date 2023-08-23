//
//  CountryCell.swift
//  PhoneNumberKit
//
//  Created by Sharapat Azamat on 23.08.2023.
//  Copyright © 2023 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit



public enum CountryFlagStyle {
    
    // Corner style will be applied
    case corner
    
    // Circular style will be applied
    case circular
    
    // Rectangle style will be applied
    case normal
}

class CountryCell: UITableViewCell {

    // MARK: - Variables
    static let reuseIdentifier = String(describing: CountryCell.self)

    var flagStyle: CountryFlagStyle {
        return CountryFlagStyle.normal
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let diallingCodeLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()

    
    // MARK: - Private properties
    private var countryContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private var countryInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    
    private(set) var countryFlagStackView: UIStackView = UIStackView()
    private var countryCheckStackView: UIStackView = UIStackView()
    
    public func configureCell(country: CountryCodePickerViewController.Country) {
        diallingCodeLabel.text = country.name
        nameLabel.text = country.prefix
        flagImageView.setImage(from: country.flag)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupViews()
    }
}

extension CountryCell {
    
    func setupViews() {
        
        // Add country flag & check mark views
        countryFlagStackView.addArrangedSubview(flagImageView)
        
        // Add country info sub views
        countryInfoStackView.addArrangedSubview(nameLabel)
        countryInfoStackView.addArrangedSubview(diallingCodeLabel)
        
        // Add stackviews into country content stack
        countryContentStackView.addArrangedSubview(countryFlagStackView)
        countryContentStackView.addArrangedSubview(countryInfoStackView)
        countryContentStackView.addArrangedSubview(countryCheckStackView)
        
        contentView.addSubview(countryContentStackView)
        contentView.addSubview(separatorLineView)
        
        // Configure constraints on country content stack
        countryContentStackView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
        countryContentStackView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        countryContentStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 4).isActive = true
        countryContentStackView.bottomAnchor.constraint(equalTo: separatorLineView.topAnchor, constant: -4).isActive = true
        
        // Configure constraints on separator view
        separatorLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorLineView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        separatorLineView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
    }
    
    
    /// Apply some styling on flag image view
    ///
    /// - Note: By default, `CountryFlagStyle.nromal` style is applied on the flag image view.
    ///
    /// - Parameter style: Flag style kind
    
    func applyFlagStyle(_ style: CountryFlagStyle) {
        
        // Cleae all constraints from flag image view
        NSLayoutConstraint.deactivate(flagImageView.constraints)
        layoutIfNeeded()
        
        switch style {
        case .corner:
            // Corner style
            flagImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            flagImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            flagImageView.layer.cornerRadius = 4
            flagImageView.clipsToBounds = true
            flagImageView.contentMode = .scaleAspectFit
        case .circular:
            // Circular style
            flagImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
            flagImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
            flagImageView.layer.cornerRadius = 34 / 2
            flagImageView.clipsToBounds = true
            flagImageView.contentMode = .scaleAspectFit
        default:
            // Apply default styling
            flagImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            flagImageView.heightAnchor.constraint(equalToConstant: 26).isActive = true
            flagImageView.contentMode = .scaleAspectFit
        }
    }
    
    
    /// Hides dialing code label
    ///
    /// - Parameter state: Visibility boolean state. By default it's set to `True`
    func hideDialCode(_ state: Bool = true) {
        diallingCodeLabel.isHidden = state
    }
    
    
    /// Hides country flag view
    ///
    /// - Parameter state: Visibility boolean state. By default it's set to `True`
    func hideFlag(_ state: Bool = true) {
        countryFlagStackView.isHidden = state
    }
    
}

extension UIImageView {
    func setImage(from urlString: String) {
        if let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
