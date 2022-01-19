//
//  ViewController.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//
import Foundation
import UIKit

// MARK: - Notification key for NotificationCenter
let favoriteButtonPressedKey = "co.boredarthur.favoritePressed"

class ViewController: UIViewController {
    
    // MARK: - Properties
    var articleListVM: ArticleListViewModel!
    
    // MARK: - Init a refresh control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Init a search text field
    private let searchTextField = UITextField()
    
    // MARK: - Init a table view
    private let tableView = UITableView()
    
    // MARK: - Init favorite button
    private let favoriteButton = UIButton()
    
    // MARK: - Notification name
    private let favoriteNotifictionName = Notification.Name(rawValue: favoriteButtonPressedKey)
    
    // MARK: - Init an UIPickerView
    private let countryPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
    private let countryPickerLabel = UILabel()
    private var currentCountry: String = "ae"
    private let alertView = UIAlertController(title: "Choose a country", message: "to search news in", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureUIPickerView()
        configureTableView()
        configureFavoriteButton()
        configureSearchController()
        createObserver()
        fetchArticles(countryCode: currentCountry)
    }
    
    deinit {
        // Removing observer on deinit
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observer for changed in DB
    func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshArticles(_:)), name: favoriteNotifictionName, object: nil)
    }
    
    // MARK: - Configuring a view
    func configureView() {
        view.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refreshArticles(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching articles...")
    }
    
    // MARK: - Configuring an UIPickerView
    func configureUIPickerView() {
    
        // VC for UIPickerView in Alert
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 100)
        vc.view.addSubview(countryPicker)
        
        // Configuring UILabel
        self.view.addSubview(countryPickerLabel)
        countryPickerLabel.translatesAutoresizingMaskIntoConstraints = false
        countryPickerLabel.backgroundColor = .systemGray5
        countryPickerLabel.layer.masksToBounds = true
        countryPickerLabel.layer.cornerRadius = 20
        
        countryPickerLabel.text = Constants.Pickers.countriesList[0]
        countryPickerLabel.textAlignment = .center
        
        countryPickerLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunction))
        countryPickerLabel.addGestureRecognizer(tap)
        
        // Configuring Alert and fetching articles on dismiss
        let action = UIAlertAction(title: "OK", style: .default, handler: { [weak self]_ in
            guard let self = self else { return }
            self.fetchArticles(countryCode: self.currentCountry)
        })
        alertView.addAction(action)
        alertView.isModalInPresentation = true
        alertView.setValue(vc, forKey: "contentViewController")
        
        // Configuring delegates for picker
        countryPicker.dataSource = self
        countryPicker.delegate = self
        
        
        // Constraints for label
        NSLayoutConstraint.activate([
            countryPickerLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            countryPickerLabel.widthAnchor.constraint(equalToConstant: 40),
            countryPickerLabel.heightAnchor.constraint(equalToConstant: 40),
            countryPickerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
        ])
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -40, 0)
        countryPickerLabel.layer.transform = rotationTransform
        countryPickerLabel.alpha = 0
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            self.countryPickerLabel.layer.transform = CATransform3DIdentity
            self.countryPickerLabel.alpha = 1
        }
    }
    
    // MARK: - Function for opening UIPickerView on label tapped
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Configuring a search controller
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for articles"
        navigationItem.searchController = searchController
    }
    
    // MARK: - Configuring a table view
    func configureTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        
        // Constraints for table view
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: self.countryPickerLabel.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    @objc private func refreshArticles(_ sender: Any) {
        fetchArticles(countryCode: currentCountry)
    }
    
    // MARK: - Configuring a favorite button
    func configureFavoriteButton() {
        let buttonIcon = UIImage(systemName: "heart.fill")
        favoriteButton.setImage(buttonIcon, for: .normal)
        
        // Visuals
        self.view.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.backgroundColor = .systemGray5
        favoriteButton.layer.masksToBounds = true
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(favoritePressed), for: .touchUpInside)
        
        // Constraints for button
        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
            favoriteButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -40, 0)
        favoriteButton.layer.transform = rotationTransform
        favoriteButton.alpha = 0
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            self.favoriteButton.layer.transform = CATransform3DIdentity
            self.favoriteButton.alpha = 1
        }
    }
    
    @objc func favoritePressed() {
        let favoritesVC = FavoritesViewController()
        favoritesVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    // MARK: - Fetching all articles with NewsAPI
    func fetchArticles(countryCode: String) {
        NewsAPI.sharedInstance.getArticles(countryCode: countryCode) { articles in
            guard let articles = articles else { return }
            self.articleListVM = ArticleListViewModel(articles: articles)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK: - Extension for UITableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Setting up number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articleListVM.numberOfRowsInSection(section)
    }
    
    // Setting up number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.articleListVM == nil ? 0 : self.articleListVM.numberOfSections
    }
    
    // Setting up a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as? ArticleTableViewCell
        let article = articleListVM.articleIndex(indexPath.row)
        cell?.articleVM = article
        return cell ?? UITableViewCell()
    }
    
    // Height of row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    // Open article on tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articleListVM.articleIndex(indexPath.row)
        guard let url = URL(string: article.url) else { return }
        
        let vc = WebViewViewController(url: url, title: article.title)
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    // Animation for scrolling
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.75) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1
        }
    }
}

// MARK: - Extension for UISearchController
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Getting text from search bar
        guard let filter = searchController.searchBar.text, !filter.isEmpty else { return }
        NewsAPI.sharedInstance.getArticles(keyword: filter) { articles in
            guard let articles = articles else { return }
            self.articleListVM = ArticleListViewModel(articles: articles)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
}

// MARK: - Extension for UIPickerView
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Pickers.countriesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Pickers.countriesList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let _country = Constants.Pickers.countriesList[row]
        currentCountry = Constants.Pickers.countiresDictionary[_country]!
        countryPickerLabel.text = _country
    }
}
