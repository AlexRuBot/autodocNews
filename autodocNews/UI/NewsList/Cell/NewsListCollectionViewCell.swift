//
//  NewsListCollectionViewCell.swift
//  autodocNews
//
//  Created by Александр Гужавин on 16.01.2025.
//

import UIKit

class NewsListCollectionViewCell: UICollectionViewCell {
    
    static let indentifier: String = "NewsListCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var constraintSize: CGFloat {
        get {
            contentView.frame.height <= 100 ? 8 : 16
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        self.layer.cornerRadius = 8

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: constraintSize),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: constraintSize),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -constraintSize),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: constraintSize),
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -constraintSize),
        ])
    }
    
    func configure(news: News) {
        titleLabel.text = news.title
        imageView.image = news.image
    }
}
