//
//  ViewController.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/1/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let parser = Parser()
    let waitGroup = DispatchGroup()
    var items = [FeedViewModel]()
    
    var listView: ListView {
        return view as! ListView
    }
    
    override func loadView() {
        view = ListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup the parser.
        parser.add(pattern: LinkPattern()) { (str) in
            return MatchedResponse(string: str, attributes: [NSForegroundColorAttributeName: UIColor.blue,
                                                             NSLinkAttributeName: URL(string: str)!])
        }
        parser.add(pattern: UserNamePattern()) { (str) in
            return MatchedResponse(string: str, attributes: [NSForegroundColorAttributeName: UIColor.red,
                                                             NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        }
        parser.add(pattern: UnicodePattern()) { (str) in
            return MatchedResponse(string: str, attributes: nil)
        }
        
        //load the json, decode it, then run it through the parser
        if let file = Bundle.main.url(forResource: "reviews", withExtension: "json") {
            do {
                let data = try Data(contentsOf: file)
                let decoder = JSONDecoder(data)
                let reviews = try Reviews(decoder)
                for review in reviews.reviews {
                    runParser(text: review)
                }
                
            } catch {
                print("got to load that json!")
            }
        }
        
        //once all the items are done parsing, we reload the collection view
        waitGroup.notify(queue: DispatchQueue.main, execute: {[weak self] in
            guard let s = self else {return}
            s.listView.update(viewModels: s.items)
        })
    }
    
    func runParser(text: String) {
        waitGroup.enter()
        parser.process(text: text, attributes: [NSForegroundColorAttributeName: UIColor.black,
                                                NSFontAttributeName: UIFont.systemFont(ofSize: 14)],
                       completion: {[weak self] (attrString) in
                        if let str = attrString {
                            self?.items.append(FeedViewModel(text: str))
                        }
                        self?.waitGroup.leave()
        })
    }


}

