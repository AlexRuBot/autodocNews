//
//  NewsListController.swift
//  autodocNews
//
//  Created by Александр Гужавин on 16.01.2025.
//

import UIKit
import Combine

// MARK: Life Circle & UI

class NewsListController: UIViewController {
    
    
    private var collectionView: UICollectionView!
    
    private var viewModel: NewsListViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.NavigationTitle.newsList
        navigationController?.navigationBar.backgroundColor = .systemBackground
        self.viewModel = NewsListViewModel()
        configureCollectionView()
        
        viewModel.$news.sink { [weak self] _ in
            self?.isLoading = false
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }.store(in: &cancellables)
        
        isLoading = true
        collectionView.reloadData()
        viewModel.fetchNews()
    }
    
    private func configureCollectionView() {
        let layout = createCompositionalLayout()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
            
        collectionView.register(NewsListCollectionViewCell.self, forCellWithReuseIdentifier: NewsListCollectionViewCell.indentifier)
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: LoadingCollectionViewCell.indentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createSection()
        }
    }

    private func createSection() -> NSCollectionLayoutSection {
        let heightView = view.frame.height
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(heightView / 8))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(heightView / 8))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        return section
    }
}

// MARK: CollectionView Delegate

extension NewsListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.news.count + (isLoading ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading && indexPath.item == viewModel.news.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionViewCell.indentifier, for: indexPath) as! LoadingCollectionViewCell
            cell.startLoading()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsListCollectionViewCell.indentifier, for: indexPath) as! NewsListCollectionViewCell
        cell.backgroundColor = .systemGray6
        let data = viewModel.news[indexPath.row]
        cell.configure(news: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = viewModel.news[indexPath.row]
        viewModel.pushToDetail(news.url)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = collectionView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offset > contentHeight - height - 100 {
            guard !isLoading else { return }
            isLoading = true
            collectionView.reloadData()
            viewModel.fetchNews()
        }
    }
}
