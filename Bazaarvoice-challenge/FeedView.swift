//
//  FeedView.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/2/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

/**
 View Model for the Feed View. Basically encapsulates the event object to add some handy indirection
 */
struct FeedViewModel: SourceItemProtocol {
    static var cellIdentifer: String {
        return "feedcell"
    }
    let text: NSAttributedString
}

class FeedView: UIView {
    let textLabel = UILabel()
    let bottomLine = UIView()
    static let pad: CGFloat = 10
    
    var viewModel: FeedViewModel? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(textLabel)
        
        bottomLine.backgroundColor = UIColor.lightGray
        addSubview(bottomLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let pad: CGFloat = FeedView.pad
        let lineH: CGFloat = 1
        var top = pad
        let left = pad
        
        let maxWidth = bounds.width - (left + pad)
        textLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: bounds.height - (top + pad))
        top += textLabel.bounds.height + pad
        
        bottomLine.frame = CGRect(x: 0, y: bounds.height - lineH, width: bounds.width, height: lineH)
    }
    
    func update() {
        guard let model = viewModel else {return}
        textLabel.attributedText = model.text
    }
    
    class func caculateHeight(width: CGFloat, model: FeedViewModel) -> CGFloat {
        let pad: CGFloat = FeedView.pad
        let maxWidth = width - (pad * 2)
        let textSize = model.text.boundingRect(with: CGSize(width: maxWidth, height: 0), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return textSize.height + pad * 2
    }
}
