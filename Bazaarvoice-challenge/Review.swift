//
//  Review.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/2/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import Foundation

struct Reviews: JSONJoy {
    let reviews: [String]
    init(_ decoder: JSONDecoder) throws {
        reviews = try decoder["reviews"].get()
    }
}
