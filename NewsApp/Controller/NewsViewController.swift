//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Stepan on 22.10.2025.
//

import UIKit
import Lottie

class NewsViewController: UIViewController {
    
    
    private var articles: [Article] = []
    
    private let refreshControl = UIRefreshControl()
    
    private let topBannerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0x36/255, green: 0xC5/255, blue: 0xFE/255, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No news yet"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // пока скрыт
        return label
    }()
    
    private let chatbotAnimation: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "Chatbot")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()
    
    private let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        view.backgroundColor = .systemBackground
        title = "LasTen"
        print("✅ NewsViewController is running!")
        
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
        view.addSubview(topBannerView)
        topBannerView.addSubview(chatbotAnimation)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
       
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            topBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            topBannerView.heightAnchor.constraint(equalToConstant: 100),
            
            chatbotAnimation.centerXAnchor.constraint(equalTo: topBannerView.centerXAnchor),
            chatbotAnimation.centerYAnchor.constraint(equalTo: topBannerView.centerYAnchor),
            chatbotAnimation.widthAnchor.constraint(equalToConstant: 130),
            chatbotAnimation.heightAnchor.constraint(equalToConstant: 130),
            
            tableView.topAnchor.constraint(equalTo: topBannerView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        fetchNews {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    @objc private func didPullToRefresh() {
        NetworkManager.shared.fetchNews { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let articles):
                    self.articles = articles
                    self.tableView.reloadData()
                    
                    self.emptyLabel.text = "No news yet"
                    self.emptyLabel.isHidden = !(self.articles.isEmpty)
                    
                case .failure(let error):
                    print("❌ Load error:", error.localizedDescription)
                    
                    // Ошибка сети
                    self.emptyLabel.text = "News load error. Please try again."
                    self.emptyLabel.isHidden = false
                }

                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    private func fetchNews(completion: (() -> Void)? = nil ) {
        NetworkManager.shared.fetchNews { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                switch result {
                case .success(let articles):
                    self?.articles = articles
                    self?.tableView.reloadData()
                    print("✅ Load \(articles.count) news")
                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                }
                
                completion?()
            }
            
        }
    }
    
    
    
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let article = articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        guard let urlString = article.url else { return }
        
        let detailVC = NewsDetailViewController(urlString: urlString)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

