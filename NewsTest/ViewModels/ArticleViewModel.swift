//
//  ArticleViewModel.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//

import Foundation

struct ArticleViewModel {
    // MARK: - Properties
    private let article: Article
    
    var title: String {
        return self.article.title ?? ""
    }
    
    var description: String {
        return self.article.description ?? ""
    }
    
    var author: String {
        return self.article.author ?? "Unknown author"
    }
    
    var url: String {
        return self.article.url!
    }
    
    var urlToImg: String {
        return self.article.urlToImage ?? ""
    }
    
    var publishedAt: String {
        return self.article.publishedAt ?? ""
    }
    
    // MARK: - Initializer
    init(_ article: Article) {
        self.article = article
    }
}
