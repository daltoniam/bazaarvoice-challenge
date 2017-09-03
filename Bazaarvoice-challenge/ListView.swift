//
//  ListView.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/2/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

class ListView: UIView, CollectionViewManagerDelegate {
    var collectionView: UICollectionView!
    let dataManager = CollectionViewManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.white
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = dataManager
        collectionView.dataSource = dataManager
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        addSubview(collectionView)
        dataManager.delegate = self
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: FeedViewModel.cellIdentifer)
    }
    
    func update(viewModels: [FeedViewModel]) {
        dataManager.items.removeAll()
        for model in viewModels {
            dataManager.items.append(model)
        }
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    //MARK: - CollectionViewManagerDelegate
    
    func didSelect(_ item: SourceItemProtocol, indexPath: IndexPath) {
    }
    
    func sizeForItem(_ item: SourceItemProtocol, indexPath: IndexPath) -> CGSize {
        if let i = item as? FeedViewModel {
            return CGSize(width: bounds.width, height: FeedView.caculateHeight(width: bounds.width, model: i))
        }
        return CGSize(width: bounds.width, height: 80)
    }
    
    func updateDisplay(_ collectionView: UICollectionView, item: SourceItemProtocol, cell: UICollectionViewCell, indexPath: IndexPath, isDisplaying: Bool) {
    }
}
