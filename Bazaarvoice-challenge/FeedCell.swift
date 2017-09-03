//
//  FeedCell.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/2/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell, SourceCellProtocol {
    let feedView = FeedView()
    
    override var isHighlighted: Bool {
        didSet {
            let color = isHighlighted ? UIColor(white: 0.95, alpha: 1) : UIColor(white: 1, alpha: 1)
            let dur = isHighlighted ? 0.1 : 0.05
            UIView.animate(withDuration: dur, animations: {
                self.contentView.backgroundColor = color
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        contentView.addSubview(feedView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        feedView.frame = contentView.bounds
    }
    
    // MARK: - SourceCellProtocol
    
    func update(_ object: SourceItemProtocol) {
        guard let item = object as? FeedViewModel else {return}
        feedView.viewModel = item
        feedView.setNeedsLayout()
    }
}
