#if os(iOS)

import UIKit

@available(iOS 11.0, *)
public protocol CountryCodePickerDelegate: AnyObject {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country)
}

@available(iOS 11.0, *)
public class CountryCodePickerViewController: UITableViewController {

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString(
            "PhoneNumberKit.CountryCodePicker.SearchBarPlaceholder",
            value: "Country",
            comment: "Placeholder for country code search field")

        return searchController
    }()
    
    public var configuration: TextFieldConfiguration? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    public let phoneNumberKit: PhoneNumberKit

    let titleText: String
    let placeholder: String
    let selectedRegion: String
    let commonCountryCodes: [String]
    var emptyIcon: UIImage?
    var emptyTitle: String?
    var emptySubtitle: String?
    var emptyFont: UIFont?
    var emptySubtitleFont: UIFont?
    var emptyColor: UIColor?
    var labelColor: UIColor?

    var shouldRestoreNavigationBarToHidden = false

    var hasCurrent = true
    var hasCommon = true

    lazy var allCountries = phoneNumberKit
        .allCountries()
        .compactMap({ Country(for: $0, with: self.phoneNumberKit) })
        .sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })

    lazy var countries: [[Country]] = {
        let countries = allCountries
            .reduce([[Country]]()) { collection, country in
                var collection = collection
                guard var lastGroup = collection.last else { return [[country]] }
                let lhs = lastGroup.first?.name.folding(options: .diacriticInsensitive, locale: nil)
                let rhs = country.name.folding(options: .diacriticInsensitive, locale: nil)
                if lhs?.first == rhs.first {
                    lastGroup.append(country)
                    collection[collection.count - 1] = lastGroup
                } else {
                    collection.append([country])
                }
                return collection
            }

        let popular = commonCountryCodes.compactMap({ Country(for: $0, with: phoneNumberKit) })

        var result: [[Country]] = []
        // Note we should maybe use the user's current carrier's country code?
        if hasCurrent, let current = Country(for: selectedRegion, with: phoneNumberKit) {
            result.append([current])
        }
        hasCommon = hasCommon && !popular.isEmpty
        if hasCommon {
            result.append(popular)
        }
        return result + countries
    }()

    var filteredCountries: [Country] = []

    public weak var delegate: CountryCodePickerDelegate?

    var emptyView = EmptyView()
    
    lazy var cancelButton = UIKit.UIBarButtonItem(image: configuration?.closeButton, style: .plain, target: self, action: #selector(dismissAnimated))
    /**
     Init with a phone number kit instance. Because a PhoneNumberKit initialization is expensive you can must pass a pre-initialized instance to avoid incurring perf penalties.

     - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.
     - parameter commonCountryCodes: An array of country codes to display in the section below the current region section. defaults to `PhoneNumberKit.CountryCodePicker.commonCountryCodes`
     */
    public init(
        phoneNumberKit: PhoneNumberKit,
        titleText: String,
        placeholder: String,
        selectedRegion: String,
        commonCountryCodes: [String] = PhoneNumberKit.CountryCodePicker.commonCountryCodes,
        emptyIcon: UIImage?,
        emptyTitle: String?,
        emptySubtitle: String?,
        emptyFont: UIFont?,
        emptySubtitleFont: UIFont?,
        emptyColor: UIColor?,
        labelColor: UIColor?)
    {
        self.phoneNumberKit = phoneNumberKit
        self.titleText = titleText
        self.placeholder = placeholder
        self.selectedRegion = selectedRegion
        self.commonCountryCodes = commonCountryCodes
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptySubtitle = emptySubtitle
        self.emptyFont = emptyFont
        self.emptySubtitleFont = emptySubtitleFont
        self.emptyColor = emptyColor
        self.labelColor = labelColor
        super.init(style: .plain)
        self.commonInit()
        
    }

    required init?(coder aDecoder: NSCoder) {
        self.phoneNumberKit = PhoneNumberKit()
        self.titleText = "Сode of the country"
        self.placeholder = "Country"
        self.selectedRegion = "KZ"
        self.commonCountryCodes = PhoneNumberKit.CountryCodePicker.commonCountryCodes
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.title = NSLocalizedString("PhoneNumberKit.CountryCodePicker.Title", value: titleText, comment: "Title of CountryCodePicker ViewController")

        tableView.separatorStyle = .none
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.reuseIdentifier)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.placeholder = NSLocalizedString(
            "PhoneNumberKit.CountryCodePicker.SearchBarPlaceholder",
            value: placeholder,
            comment: "Placeholder for country code search field")

        UINavigationBar.appearance().tintColor = .black
        UIBarButtonItem.appearance().tintColor = UIColor.black
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = !PhoneNumberKit.CountryCodePicker.alwaysShowsSearchBar

        definesPresentationContext = true
    }
    
    func checkEmptyState(query: String) {
        emptyView.configure(icon: emptyIcon, title: emptyTitle, titleFont: emptyFont, textColor: emptyColor, subtitle: emptySubtitle, subtitleFont: emptySubtitleFont, subTitlecolor: labelColor, query: query)
        emptyView.isHidden = !filteredCountries.isEmpty
        tableView.backgroundView = filteredCountries.isEmpty ? emptyView : nil
        tableView.reloadData()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        emptyView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        emptyView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController {
            shouldRestoreNavigationBarToHidden = nav.isNavigationBarHidden
            nav.setNavigationBarHidden(false, animated: true)
        }
        if let nav = navigationController, nav.isBeingPresented && nav.viewControllers.count == 1 {
            navigationItem.setRightBarButton(cancelButton, animated: true)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(shouldRestoreNavigationBarToHidden, animated: true)
    }

    @objc func dismissAnimated() {
        dismiss(animated: true)
    }

    func country(for indexPath: IndexPath) -> Country {
        isFiltering ? filteredCountries[indexPath.row] : countries[indexPath.section][indexPath.row]
    }
    
    func setUpCellProperties(cell: CountryCell) {
        
        cell.nameLabel.font = configuration?.labelFont
        if #available(iOS 13.0, *) {
            cell.nameLabel.textColor = UIColor.label
        } else {
            // Fallback on earlier versions
            cell.nameLabel.textColor = configuration?.labelColor
        }
        cell.diallingCodeLabel.font = configuration?.detailFont
        cell.diallingCodeLabel.textColor = configuration?.detailColor

    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? 1 : countries.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredCountries.count : countries[section].count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.reuseIdentifier) as? CountryCell else { fatalError("Cell with Identifier CountryTableViewCell cann't dequed") }
        let country = self.country(for: indexPath)

        cell.configureCell(country: country)
        setUpCellProperties(cell: cell)
        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        } else if section == 0, hasCurrent {
            return ""
        } else if section == 0, !hasCurrent, hasCommon {
            return NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section")
        } else if section == 1, hasCurrent, hasCommon {
            return NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section")
        }
        return countries[section].first?.name.first.map(String.init)
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isFiltering else {
            return nil
        }
        var titles: [String] = []
        if hasCurrent {
            titles.append("•") // NOTE: SFSymbols are not supported otherwise we would use 􀋑
        }
        if hasCommon {
            titles.append("★") // This is a classic unicode star
        }
        return titles + countries.suffix(countries.count - titles.count).map { group in
            group.first?.name.first
                .map(String.init)?
                .folding(options: .diacriticInsensitive, locale: nil) ?? ""
        }
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.country(for: indexPath)
        delegate?.countryCodePickerViewControllerDidPickCountry(country)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

@available(iOS 11.0, *)
extension CountryCodePickerViewController: UISearchResultsUpdating {

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    public func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredCountries = allCountries.filter { country in
            country.name.lowercased().contains(searchText.lowercased()) ||
                country.code.lowercased().contains(searchText.lowercased()) ||
                country.prefix.lowercased().contains(searchText.lowercased())
        }
        checkEmptyState(query: searchText)
        tableView.reloadData()
    }
}


// MARK: Types

@available(iOS 11.0, *)
public extension CountryCodePickerViewController {

    struct Country {
        public var code: String
        public var flag: String
        public var name: String
        public var prefix: String

        public init?(for countryCode: String, with phoneNumberKit: PhoneNumberKit) {
            let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
            guard
                let name = (Locale.current as NSLocale).localizedString(forCountryCode: countryCode),
                let prefix = phoneNumberKit.countryCode(for: countryCode)?.description
            else {
                return nil
            }

            self.code = countryCode
            self.name = name
            self.prefix = "+" + prefix
            self.flag = ""
            countryCode.uppercased().unicodeScalars.forEach {
                if let scaler = UnicodeScalar(flagBase + $0.value) {
                    flag.append(String(describing: scaler))
                }
            }
            if flag.count != 1 { // Failed to initialize a flag ... use an empty string
                return nil
            }
        }
    }

    class Cell: UITableViewCell {

        static let reuseIdentifier = "Cell"

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value2, reuseIdentifier: Self.reuseIdentifier)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif
