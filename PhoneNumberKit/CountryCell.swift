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

    let flagImageView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 24).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return label
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
        flagImageView.text = country.flag
        
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
        
        // Configure constraints on country content stack
        countryContentStackView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
        countryContentStackView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        countryContentStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        countryContentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
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
