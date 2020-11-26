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
import ArticleKit

class ArticleTableViewCell: UITableViewCell {
  let titleLabel = UILabel()
  var publishStatusLabel = UILabel()
  
  var article: Article {
    didSet {
      initializeTitleLabel()
      article.published ? showArticleWasPublished() : showArticleIsDraft()
      setNeedsLayout()
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    article = Article(title: "placeholder", content: "placeholder", published: false)
    publishStatusLabel = ArticleTableViewCell.statusLabel(title: "")
    
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubview(titleLabel)
    addSubview(publishStatusLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    titleLabel.sizeToFit()
    titleLabel.bounds = CGRect(x: 0, y: 0, width: min(titleLabel.bounds.width, 150.0), height: titleLabel.bounds.height)
    titleLabel.center = CGPoint(x: titleLabel.bounds.width/2.0 + 16, y: bounds.height/2.0)
    
    publishStatusLabel.sizeToFit()
    publishStatusLabel.bounds = CGRect(x: 0, y: 0, width: publishStatusLabel.bounds.width + 30, height: publishStatusLabel.bounds.height + 8)
    publishStatusLabel.center = CGPoint(x: bounds.width - publishStatusLabel.bounds.width/2.0 - 16.0, y: bounds.height/2.0)
  }
  
  private func initializeTitleLabel() {
    titleLabel.text = article.title
    titleLabel.font = UIFont.systemFont(ofSize: 24.0)
  }
  
  class func statusLabel(title: String) -> UILabel {
    let label = UILabel()
    
    label.text = title
    label.layer.cornerRadius = 4.0
    label.layer.borderWidth = 1.0
    label.textAlignment = .center;
    return label
  }
  
  func showArticleWasPublished() {
    publishStatusLabel.text = "PUBLISHED"
    
    let green = UIColor(red: 0.0/255.0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    
    publishStatusLabel.textColor = green
    publishStatusLabel.layer.borderColor = green.cgColor
  }
  
  func showArticleIsDraft() {
    publishStatusLabel.text = "DRAFT"
    
    let yellow = UIColor(red: 254.0/255.0, green: 223.0/255.0, blue: 0.0, alpha: 1.0)
    
    publishStatusLabel.textColor = yellow
    publishStatusLabel.layer.borderColor = yellow.cgColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
