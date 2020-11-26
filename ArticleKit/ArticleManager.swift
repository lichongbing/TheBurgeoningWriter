/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

public class ArticleManager: NSObject {
  // Update the following with your own group identifier
  private static let groupIdentifier = "group.com.razeware.Writing"
  private static var articles: [Article] = []
  
  private static var articlesDir: String  {
    let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    if groupURL == nil {
      let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      return documentsDir.path + "/Articles"
    } else {
      return groupURL!.path + "/Articles"
    }
  }

  public static func update(article: Article, title: String, content: String) -> Article {
    let newArticle = Article(title: title, content: content, published: false)
    remove(article: article)
    add(article: newArticle)
    return newArticle
  }
  
  public static func findArticle(with title: String) -> Article? {
    loadArticles()
    return articles.first { $0.title == title }
  }
  
  public static func allArticles() -> [Article] {
    return articles
  }
  
  public static func publish(_ article: Article) {
    let publishedArticle = Article(title: article.title, content: article.content, published: true)
    
    ArticleManager.remove(article: article)
    ArticleManager.add(article: publishedArticle)
    
    ArticleManager.writeArticlesToDisk()
  }
  
  public static func writeArticlesToDisk() {
    do {
      if !FileManager.default.fileExists(atPath: articlesDir) {
        try FileManager.default.createDirectory(atPath: articlesDir, withIntermediateDirectories: false, attributes: nil)
      }
      
      // Delete all old articles
      let articlePaths = try FileManager.default.contentsOfDirectory(atPath: articlesDir)
      for articlePath in articlePaths  {
        let fullPath = articlesDir + "/\(articlePath)"
        try FileManager.default.removeItem(atPath: fullPath)
        print("Deleted \(articlePath)")
      }
    } catch let e {
      print(e)
    }
    
    for (i, article) in articles.enumerated() {
      let path = articlesDir + "/\(i + 1).article"
      let url = URL(fileURLWithPath: path)
      if let data = article.toData() {
        try? data.write(to: url)
        print("Wrote article \(article.title) published? \(article.published) to \(articlesDir)")
      }
    }
  }
  
  public static func loadArticles() {
    var savedArticles: [Article] = []
    
    do {
      if !FileManager.default.fileExists(atPath: articlesDir) {
        try FileManager.default.createDirectory(atPath: articlesDir, withIntermediateDirectories: false, attributes: nil)
      }
      
      let articlePaths = try FileManager.default.contentsOfDirectory(atPath: articlesDir)
      for articlePath in articlePaths  {
        let fullPath = articlesDir + "/\(articlePath)"
        if let articleData = FileManager.default.contents(atPath: fullPath),
          let articleDict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(articleData) as? [String: Any],
          let title = articleDict["title"] as? String,
          let content = articleDict["content"] as? String,
          let published = articleDict["published"] as? Bool {
          let article = Article(title: title, content: content, published: published)
          savedArticles.append(article)
        }
      }
    } catch let e {
      print(e)
    }
    
    articles = savedArticles
  }
  
  public static func add(article: Article) {
    articles.append(article)
  }
  
  public static func remove(article articleToDelete: Article) {
    articles.removeAll { article -> Bool in
      article.title == articleToDelete.title && article.content == articleToDelete.content
    }
  }
}
