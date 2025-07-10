import UIKit

// MARK: - Model
struct Country: Codable {
    let name: String
    let code: String
    let capital: String
    let region: String
}

// MARK: - ViewModel
class CountryListViewModel {
    // The full list of countries (private setter)
    var countries: [Country] = []
    // Filtered countries based on search query
    private(set) var filteredCountries: [Country] = []
    
    // Whether currently searching
    var isSearching: Bool = false {
        didSet {
            filterCountries(with: currentQuery)
        }
    }
    
    // Current search query
    private var currentQuery: String = ""
    
    // Callback closure to notify when data changes
    var onDataChanged: (() -> Void)?
    
    // Fetch countries from URL
    func fetchCountries() {
        let urlString = "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard error == nil else { print("Error:", error!); return }
            guard let data = data else { print("No data"); return }
            do {
                let countries = try JSONDecoder().decode([Country].self, from: data)
                DispatchQueue.main.async {
                    self?.countries = countries
                    self?.onDataChanged?()
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    
    // Update the filter query and filter countries
    func filter(with query: String) {
        currentQuery = query.lowercased()
        filterCountries(with: currentQuery)
    }
    
    // Filter countries based on query or clear if empty
    private func filterCountries(with query: String) {
        if query.isEmpty {
            filteredCountries = []
        } else {
            filteredCountries = countries.filter {
                $0.name.lowercased().contains(query) ||
                $0.capital.lowercased().contains(query)
            }
        }
        onDataChanged?()
    }
    
    // Returns number of countries to display depending on search state
    func numberOfCountries() -> Int {
        return isSearching ? filteredCountries.count : countries.count
    }
    
    // Returns a country at the given index depending on search state
    func country(at index: Int) -> Country {
        return isSearching ? filteredCountries[index] : countries[index]
    }
}

// MARK: - ViewController
class CountryListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel = CountryListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Countries"
        view.backgroundColor = .systemBackground
        
        configureTableView()
        configureSearchController()
        
        // Reload table when data changes in ViewModel
        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.fetchCountries()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name or capital"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension CountryListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCountries()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as? CountryCell else {
            return UITableViewCell()
        }
        let country = viewModel.country(at: indexPath.row)
        cell.configure(with: country)
        return cell
    }
}

extension CountryListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.isSearching = !query.isEmpty
        viewModel.filter(with: query)
    }
}

// MARK: - Country Cell
class CountryCell: UITableViewCell {
    static let identifier = "CountryCell"
    
    private let nameLabel = UILabel()
    private let capitalLabel = UILabel()
    private let codeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with country: Country) {
        nameLabel.text = "\(country.name), \(country.region)"
        capitalLabel.text = country.capital
        codeLabel.text = country.code
    }
    
    private func setupUI() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true
        
        capitalLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        capitalLabel.adjustsFontForContentSizeCategory = true
        
        codeLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        codeLabel.adjustsFontForContentSizeCategory = true
        codeLabel.textAlignment = .right
        
        let topRow = UIStackView(arrangedSubviews: [nameLabel, codeLabel])
        topRow.axis = .horizontal
        topRow.distribution = .equalSpacing
        
        let stack = UIStackView(arrangedSubviews: [topRow, capitalLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}
