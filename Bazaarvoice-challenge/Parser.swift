//
//  Parser.swift
//  Bazaarvoice-challenge
//
//  Created by Dalton Cherry on 9/1/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import Foundation
#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

//using this instead of a NSAttributed String just to be very clear on what is happening
public struct MatchedResponse {
    let string: String
    let attributes: [String: Any]?
}

public typealias MatchClosure = (String) -> MatchedResponse

//This is a protocol to allow custom regex patterns to be create outside of the ones provided below
public protocol Pattern {
    func regex() throws -> NSRegularExpression
    func transform(text: String) -> String
}

//The transform method allows a pattern to do pre processing on the text before it shows up in the matched closure.
//This is a default implementation to not force protocols that don't need this power to implement the method.
extension Pattern {
    public func transform(text: String) -> String {
        return text
    }
}

//Matches URLs. e.g. (http://domain.com/url/etc)
public class LinkPattern : Pattern {
    public func regex() throws -> NSRegularExpression {
        return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }
}

//Matches typical user name patterns from social platforms like twitter. (@daltoniam, etc)
public class UserNamePattern : Pattern {
    public func regex() throws -> NSRegularExpression {
        //twitter requires between 4 and 15 char for a user name, but hightlights the user name at one char...
        //so I'm using {1,15} instead of {4,15}, but could be easily changed depending on requirements
        return try NSRegularExpression(pattern: "(?<=\\s|^)@[a-zA-Z0-9_]{1,15}\\b", options: .caseInsensitive)
    }
}

//Matches hex strings to convert them to their proper unicode version.
public class UnicodePattern : Pattern {
    public func regex() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: "(?<=\\s|^)U\\+[a-zA-Z0-9]{2,6}\\b", options: .caseInsensitive)
    }
    
    //convert the hex to its proper Unicode scalar. e.g. (U+1F602 to 😂)
    public func transform(text: String) -> String {
        let offset = text.index(text.startIndex, offsetBy: 2)
        let hex = text.substring(from: offset)
        if let i = Int(hex, radix: 16) {
            let scalar = UnicodeScalar(i)
            if let scalar = scalar {
                return String(Character(scalar))
            }
        }
        return text
    }
}

//private class that holds the matches
class Matcher {
    let pattern: Pattern
    let matched: MatchClosure
    init(pattern: Pattern, match: @escaping MatchClosure) {
        self.pattern = pattern
        self.matched = match
    }
}

open class Parser {
    var matchOpts = [Matcher]()
    
    //add a Pattern and map it to a closure that is called for text and attribute modification when a pattern matches
    public func add(pattern: Pattern, matched: @escaping MatchClosure) {
        matchOpts.append(Matcher(pattern: pattern, match: matched))
    }
    
    //This is where the magic happens. This methods creates a attributed string 
    //with all the pattern operations off the text provided
    public func process(text: String, attributes: [String: Any]? = nil, completion: @escaping ((NSAttributedString?) -> Void)) {
        //background thread to deal with long stage parsing
        let opts = matchOpts //avoid race condition in the rare case that the add method is called with text is being processed
        DispatchQueue.global(qos: .background).async {
            let mutStr = NSMutableAttributedString(string: text, attributes: attributes)
            for opt in opts {
                do {
                    let regex = try opt.pattern.regex()
                    var diff = 0
                    let matches = regex.matches(in: mutStr.string, range: NSMakeRange(0, mutStr.string.utf16.count))
                    for result in matches {
                        for i in 0..<result.numberOfRanges {
                            let range = result.rangeAt(i)
                            let location = range.location
                            let start = String.UTF16Index(location)
                            let end = String.UTF16Index(location + range.length)
                            
                            if let str = String(text.utf16[start..<end]) {
                                let transformStr = opt.pattern.transform(text: str)
                                let response = opt.matched(transformStr)
                                
                                //diff range accounts for any char changes (string is now a different length)
                                let diffRange = NSMakeRange(location + diff, range.length)
                                //merge and apply attributes
                                var attrs = mutStr.attributes(at: diffRange.location, longestEffectiveRange: nil, in: diffRange)
                                if let newAttrs = response.attributes {
                                    for (key, value) in newAttrs {
                                        attrs[key] = value
                                    }
                                }
                                //create an attributed string with the attributes of the orignial string with any new additions for the matched response
                                let replaceStr = NSAttributedString(string: response.string, attributes: attrs)
                                diff += response.string.utf16.count - str.utf16.count
                                mutStr.replaceCharacters(in: diffRange, with: replaceStr)
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil) //the regex failed, you get nothing! (or I guess an error if we wanted, very unlikely this will happen)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                completion(mutStr)
            }
        }
    }
}
