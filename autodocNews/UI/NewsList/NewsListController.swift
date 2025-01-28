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
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.NavigationTitle.newsList
        navigationController?.navigationBar.backgroundColor = .systemBackground
        self.viewModel = NewsListViewModel()
        
        configureCollectionView()
        configureDataSource()
        
        viewModel.$news.sink { [weak self] news in
            self?.isLoading = false
            self?.applySnapshot(news: news)
        }.store(in: &cancellables)
        
        isLoading = true
        applySnapshot(news: [])
        Task {
            do {
                try await viewModel.fetchNews()
            } catch {
                isLoading = false
                print("Error fetching news: \(error)")
            }
        }
    }
    
    private func configureCollectionView() {
        let layout = createCompositionalLayout()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        collectionView.delegate = self

        collectionView.register(NewsListCollectionViewCell.self, forCellWithReuseIdentifier: NewsListCollectionViewCell.indentifier)
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: LoadingCollectionViewCell.indentifier)
        
        view.addSubview(collectionView)
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createSection()
        }
    }

    private func createSection() -> NSCollectionLayoutSection {
        let heightDimension = view.frame.height / 8
        var fractionalWidth = CGFloat(1.0)
        
        switch Constants.Device.type {
        case .pad:
            fractionalWidth = 0.5
        case .phone:
            fractionalWidth = 1.0
        default:
            break
        }

        let itemSizeNews = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionalWidth), heightDimension: .absolute(heightDimension))
        let itemNews = NSCollectionLayoutItem(layoutSize: itemSizeNews)
        itemNews.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(heightDimension))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemNews])
        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .news(let news):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsListCollectionViewCell.indentifier, for: indexPath) as! NewsListCollectionViewCell
                cell.configure(news: news)
                return cell
            case .loading:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionViewCell.indentifier, for: indexPath) as! LoadingCollectionViewCell
                cell.startLoading()
                return cell
            }
        }
    }

    private func applySnapshot(news: [News]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.newsSection])
        snapshot.appendItems(news.map { Item.news($0) }, toSection: .newsSection)
        
        if isLoading {
            snapshot.appendSections([.loadingSection])
            snapshot.appendItems([.loading], toSection: .loadingSection)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension NewsListController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = collectionView.contentSize.height
        let height = scrollView.frame.size.height

        if offset > contentHeight - height - 100 {
            guard !isLoading else { return }
            isLoading = true
            applySnapshot(news: viewModel.news)

            Task {
                do {
                    try await viewModel.fetchNews()
                } catch {
                    isLoading = false
                    print("Error fetching news: \(error)")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = viewModel.news[indexPath.item]
        viewModel.pushToDetail(news.url)
    }
}

extension NewsListController {
    enum Section {
        case newsSection
        case loadingSection
    }

    enum Item: Hashable {
        case news(News)
        case loading
    }
}

