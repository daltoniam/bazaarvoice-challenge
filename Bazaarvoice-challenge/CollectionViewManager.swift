//
//  CollectionViewManager.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/2/17.
//  Copyright © 2017 vluxe. All rights reserved.
//
//  This is a bare bones wrapper around the UICollectionView Delegate and DataSource to make adding items simple to manage

import UIKit

/**
 This protocol is implement by whatever object is going to get add to the data source manager (model, viewModel, etc)
 */
protocol SourceItemProtocol {
    static var cellIdentifer: String {get}
}

/**
 This is implemented by the UICollectionViewCell. Update gets called with the new model to update the cell's views
 */
protocol SourceCellProtocol {
    func update(_ object: SourceItemProtocol)
}

/**
 Delegate methods to know standard interactions with a collection view
 */
protocol CollectionViewManagerDelegate: class {
    func didSelect(_ item: SourceItemProtocol, indexPath: IndexPath)
    func sizeForItem(_ item: SourceItemProtocol, indexPath: IndexPath) -> CGSize
    func updateDisplay(_ collectionView: UICollectionView, item: SourceItemProtocol, cell: UICollectionViewCell, indexPath: IndexPath, isDisplaying: Bool)
}

class CollectionViewManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var items = [SourceItemProtocol]()
    weak var delegate: CollectionViewManagerDelegate?
    
    /**
     Standard number of rows in a section. Could be expanded to support sections
     */
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    /**
     Handles when a cell is going to displayed (and possibly recycled). 
     Gets the cell type then calls the update method to update the cell with the new model data
     */
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifer = "cell"
        let item = objectForIndex(indexPath)
        if let i = item {
            identifer = type(of: i).cellIdentifer
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifer, for: indexPath)
        if let sourceCell = cell as? SourceCellProtocol, let i = item {
            sourceCell.update(i)
        }
        return cell
    }
    
    /**
     A size delegate for Flow layout options
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = objectForIndex(indexPath) else {return CGSize.zero}
        if let size = delegate?.sizeForItem(item, indexPath: indexPath) {
            return size
        }
        return CGSize.zero
    }
    
    /**
     Know when a cell has been tapped
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = objectForIndex(indexPath) else {return}
        delegate?.didSelect(item, indexPath: indexPath)
    }
    
    /**
     Know when a cell has come into focus. Useful for "boot" things like starting animations.
     */
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = objectForIndex(indexPath) else {return}
        delegate?.updateDisplay(collectionView, item: item, cell: cell, indexPath: indexPath, isDisplaying: true)
    }
    
    /**
     Know when a cell has come out of focus. Useful for cleanup things like stopping running animations.
     */
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = objectForIndex(indexPath) else {return}
        delegate?.updateDisplay(collectionView, item: item, cell: cell, indexPath: indexPath, isDisplaying: false)
    }
    
    /**
     Simple helper method to do a safety check on the items versus rows. Could be expanded for sections.
     */
    func objectForIndex(_ indexPath: IndexPath) -> SourceItemProtocol? {
        if (indexPath as NSIndexPath).row < items.count {
            return items[(indexPath as NSIndexPath).row]
        }
        return nil
    }
}

