//
//  DatabaseManager.swift
//  NewsTest
//
//  Created by boredarthur on 19.01.2022.
//

import Foundation
import RealmSwift

class DatabaseManager {
    
    // MARK: - Configuring a Realm db manager
    static let sharedInstance = DatabaseManager()
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    lazy var realm = try! Realm(configuration: configuration)
    
    // Method for writing article to db
    func writeArticle(article: ArticleDB){
        // Open a write transaction
        try! realm.write {
            let object = realm.object(ofType: ArticleDB.self, forPrimaryKey: article.url)
            if (object != nil) {
                realm.delete(object!)
                let name = Notification.Name(rawValue: favoriteButtonPressedKey)
                NotificationCenter.default.post(name: name, object: nil)
                
            } else {
                realm.add(article)
            }
        }
    }
    
    // Method for fetching articles saved in db
    func fetchArticles() -> [ArticleDB] {
        let articles = Array(realm.objects(ArticleDB.self))
        return articles
    }
    
    // Get certain article
    func fetchArticle(articleUrl: String) -> ArticleDB? {
        let article = realm.object(ofType: ArticleDB.self, forPrimaryKey: articleUrl)
        return article
    }
}
