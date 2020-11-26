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
import Intents

extension ArticleFeedViewController {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    articles = ArticleManager.allArticles()
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    navigationItem.title = "Articles"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Article",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(ArticleFeedViewController.newArticleWasTapped))
    tableView.allowsMultipleSelectionDuringEditing = false
    view.addSubview(tableView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
}

extension ArticleFeedViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return articles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ArticleTableViewCell
    cell.article = articles[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100.0
  }
}

extension NewArticleViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    // Shortcuts Button
    addShortcutButton.setTitle("Add Shortcut to Siri", for: .normal)
    addShortcutButton.addTarget(self, action: #selector(NewArticleViewController.addNewArticleShortcutWasTapped), for: .touchUpInside)
    addShortcutButton.setTitleColor(.blue, for: .normal)
    
    // Navbar
    navigationItem.title = "New Article"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Draft",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(NewArticleViewController.saveWasTapped))
    
    // Text Fields
    titleTextField.placeholder = "Title"
    titleTextField.delegate = self
    
    contentsTextView.layer.cornerRadius = 4.0
    contentsTextView.layer.borderColor = UIColor.black.cgColor
    contentsTextView.layer.borderWidth = 1.0
    contentsTextView.delegate = self
    
    view.addSubview(addShortcutButton)
    view.addSubview(titleTextField)
    view.addSubview(contentsTextView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let navbarHeight: CGFloat = 44.0
    var topPadding: CGFloat = 20.0
    var bottomPadding: CGFloat = 20.0
    let paddingBetween: CGFloat = 20.0
    
    if let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top {
      topPadding += topInset
    }
    if let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
      bottomPadding += bottomInset
    }
    
    addShortcutButton.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44.0)
    addShortcutButton.center = CGPoint(x: view.bounds.width/2.0, y: titleTextField.bounds.height/2.0 + topPadding + navbarHeight)
    
    titleTextField.bounds = CGRect(x: 0, y: 0, width: view.bounds.width - 32.0, height: 44.0)
    titleTextField.center = CGPoint(x: titleTextField.bounds.width/2.0 + 16.0, y: titleTextField.bounds.height/2.0 + addShortcutButton.center.y + addShortcutButton.bounds.height/2.0)
    
    let contentsTextViewYOrigin = titleTextField.bounds.height + titleTextField.frame.origin.y + 20.0
    let height = view.bounds.height - (titleTextField.center.y + titleTextField.bounds.height/2.0) - paddingBetween - bottomPadding
    contentsTextView.frame = CGRect(x: 16.0, y: contentsTextViewYOrigin, width: view.bounds.width - 32.0, height: height)
  }

  override func updateUserActivityState(_ activity: NSUserActivity) {
    guard let title = titleTextField.text, let content = contentsTextView.text else { return }
    
    activity.addUserInfoEntries(from: ["title": title, "content": content])
    
    super.updateUserActivityState(activity)
  }
}

// Since your user activity supports hand-off, updating its user info dictionary means you can easily continue writing your article on another device if you'd like to. Make sure to call needs save so updateUserActivityState(activity:) can be called periodically instead of at each change.

extension NewArticleViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    userActivity?.needsSave = true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    userActivity?.needsSave = true
    
    return true
  }
}

extension NewArticleViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    userActivity?.needsSave = true
  }
}

extension EditDraftViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    // Navbar
    navigationItem.title = "Edit Draft"
    navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Publish",
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(EditDraftViewController.publishWasTapped)),
                                          UIBarButtonItem(title: "Save",
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(EditDraftViewController.saveWasTapped))]
    
    // Text Fields
    titleTextField.placeholder = "Title"
    titleTextField.text = article.title
    
    contentsTextView.layer.cornerRadius = 4.0
    contentsTextView.layer.borderColor = UIColor.black.cgColor
    contentsTextView.layer.borderWidth = 1.0
    contentsTextView.text = article.content
    
    view.addSubview(titleTextField)
    view.addSubview(contentsTextView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let navbarHeight: CGFloat = 44.0
    var topPadding: CGFloat = 20.0
    var bottomPadding: CGFloat = 20.0
    
    if let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top {
      topPadding += topInset
    }
    if let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
      bottomPadding += bottomInset
    }
    
    titleTextField.bounds = CGRect(x: 0, y: 0, width: view.bounds.width - 32.0, height: 44.0)
    titleTextField.center = CGPoint(x: titleTextField.bounds.width/2.0 + 16.0, y: titleTextField.bounds.height/2.0 + topPadding + navbarHeight)
    
    let contentsTextViewYOrigin = titleTextField.bounds.height + titleTextField.frame.origin.y + 20.0
    let height = view.bounds.height - navbarHeight - titleTextField.bounds.height - 20 - 20 - bottomPadding
    contentsTextView.frame = CGRect(x: 16.0, y: contentsTextViewYOrigin, width: view.bounds.width - 32.0, height: height)
  }
}
