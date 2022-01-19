//
//  Article.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//

import Foundation
import RealmSwift

struct Article: Decodable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
}

class ArticleDB: Object {
    @Persisted var author: String?
    @Persisted var title: String?
    @Persisted var articleDescription: String?
    @Persisted var url: String?
    @Persisted var urlToImage: String?
    @Persisted var publishedAt: String?
    
    override static func primaryKey() -> String? {
        return "url"
    }
    
    convenience init(author: String?, title: String?, articleDescription: String?, url: String?, urlToImage: String?, publishedAt: String?) {
        self.init()
        guard let url = url else { return }
        guard let publishedAt = publishedAt else { return }
        
        self.author = author ?? "Unknown author"
        self.title = title ?? "No title"
        self.articleDescription = articleDescription ?? ""
        self.url = url
        self.urlToImage = urlToImage ?? ""
        self.publishedAt = publishedAt
    }
}
