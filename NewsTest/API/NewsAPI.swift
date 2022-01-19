//
//  NetworkManager.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//

import Foundation

class NewsAPI {
    // MARK: - Singleton
    static let sharedInstance = NewsAPI(apiKey: Constants.API.apiKey)
    
    // MARK: - Cache for images
    private let imageCache = NSCache<NSString, NSData>()
    
    // MARK: - Properties
    private let apiKey: String
    private let baseURL: String = "https://newsapi.org/v2/"
    private let TopHeadlines: String = "top-headlines?country="
    
    // MARK: - API Key for NewsAPI
    private init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Getting every article from NewsAPI
    func getArticles(countryCode: String = "ae", completion: @escaping ([Article]?) -> ()) {
    
        // Setting url string all together
        let urlString = "\(baseURL)\(TopHeadlines)\(countryCode)&apiKey=\(apiKey)"
        
        // Making an URL for request
        guard let url = URL(string: urlString) else { return }
        
        // Sending a request to url
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                let decoder = JSONDecoder()
                let articleList = try? decoder.decode(ArticleList.self, from: data)
                completion(articleList?.articles)
            }
        }.resume()
    }
    
    // MARK: - Overloading method for getting articles
    func getArticles(keyword: String, completion: @escaping ([Article]?) -> ()) {
        // Setting url string all together with search keyword
        let urlString = "\(baseURL)/everything?qInTitle=\(keyword)&apikey=\(apiKey)"
        
        // Making an URL for request
        guard let url = URL(string: urlString) else { return }
        
        // Sending a request to url
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                let decoder = JSONDecoder()
                let articleList = try? decoder.decode(ArticleList.self, from: data)
                completion(articleList?.articles)
            }
        }.resume()
    }
    
    // MARK: - Getting image and putting it in a cache
    func getImage(urlString: String, completion: @escaping (Data?) -> Void) {
        
        // Converting string to URL
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Checking if image by this url is already in a cache
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage as Data)
        } else {
            // Sending a request to url
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil, let data = data else {
                    completion(nil)
                    return
                }
                
                // Putting image in a cache
                self.imageCache.setObject(data as NSData, forKey: NSString(string: urlString))
                completion(data)
            }.resume()
        }
    }
}
