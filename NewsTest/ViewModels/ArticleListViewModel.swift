//
//  ArticleListViewModel.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//

import Foundation

struct ArticleListViewModel {
    let articles: [Article]
}

extension ArticleListViewModel {
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return self.articles.count
    }
    
    func articleIndex(_ index: Int) -> ArticleViewModel{
        let article = articles[index]
        return ArticleViewModel(article)
    }
}
