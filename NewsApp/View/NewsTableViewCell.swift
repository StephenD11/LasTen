//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Stepan on 22.10.2025.
//

import UIKit

final class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    
    private let newsImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implement")
    }
    
    private func setupLayout() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        
        NSLayoutConstraint.activate([
                    newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                    newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                    newsImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                    newsImageView.widthAnchor.constraint(equalToConstant: 100),
                    
                    titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                    titleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 10),
                    titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                    
                    descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                    descriptionLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 10),
                    descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                    descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
                ])
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description ?? "No description available"
        
        if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
            loadImage(from: url)
            
        } else {
            newsImageView.image = UIImage(systemName: "photo")
        }
    }
    
    private func loadImage(from url: URL) {
        let request = URLRequest(url: url)
        
        if let cachedData = URLCache.shared.cachedResponse(for: request)?.data,
           let image = UIImage(data: cachedData) {
            self.newsImageView.image = image
            return
        }
        
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
        guard let self = self,
              let data = data,
              let response = response else { return }
            
            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            DispatchQueue.main.async {
                self.newsImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
