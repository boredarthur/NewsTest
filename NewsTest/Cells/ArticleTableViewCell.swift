//
//  ArticleTableViewCell.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleAuthor: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var articleDescription: UILabel!
    
    var articleVM: ArticleViewModel? {
        didSet {
            if let articleVM = articleVM {
                articleTitle.text = articleVM.title
                articleAuthor.text = articleVM.author
                articleDescription.text = articleVM.description
                NewsAPI.sharedInstance.getImage(urlString: articleVM.urlToImg) { data in
                    guard let data = data else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.articleImage.image = UIImage(data: data)
                        self.favoriteButton.tintColor = (DatabaseManager.sharedInstance.fetchArticle(articleUrl: articleVM.url) != nil) ? .systemPink : .systemGray4
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        articleImage.configure()
        favoriteButton.setTitle("", for: .normal)
    }

    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        let article = ArticleDB(author: articleVM?.author, title: articleVM?.title, articleDescription: articleVM?.description, url: articleVM?.url, urlToImage: articleVM?.urlToImg, publishedAt: articleVM?.publishedAt)
        // Write article to db
        DatabaseManager.sharedInstance.writeArticle(article: article)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.favoriteButton.tintColor = (DatabaseManager.sharedInstance.fetchArticle(articleUrl: article.url!) != nil) ? .systemPink : .systemGray4
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
