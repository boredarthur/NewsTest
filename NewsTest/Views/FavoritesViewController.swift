//
//  FavoritesViewController.swift
//  NewsTest
//
//  Created by boredarthur on 19.01.2022.
//

import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - Properties
    private let tableView = UITableView()
    private var articleListVM: ArticleListViewModel!
    
    // MARK: - Notification name
    private let favoriteNotifictionName = Notification.Name(rawValue: favoriteButtonPressedKey)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
        createObserver()
    }
    
    deinit {
        // Removing observer on deinit
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configuring current ViewController
    private func configure() {
        self.view.backgroundColor = .white
        fetchFavoriteArticles()
    }
    
    // MARK: - Configuring favorites table view
    private func configureTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Constraints for table view
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20)
        ])
    }
    
    func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshArticles(_:)), name: favoriteNotifictionName, object: nil)
    }
    
    @objc private func refreshArticles(_ sender: Any) {
        fetchFavoriteArticles()
    }
    
    // MARK: - Fetching all favorite articles from DB
    private func fetchFavoriteArticles() {
        let articles = DatabaseManager.sharedInstance.fetchArticles()
        var articlesList: [Article] = []
        for article in articles {
            let newArticle = Article(author: article.author, title: article.title, description: article.articleDescription, url: article.url, urlToImage: article.urlToImage, publishedAt: article.publishedAt)
            articlesList.append(newArticle)
        }
        self.articleListVM = ArticleListViewModel(articles: articlesList)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Extension for UITableView
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
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
