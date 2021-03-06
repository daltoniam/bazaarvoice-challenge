//////////////////////////////////////////////////////////////////////////////////////////////////
//
//  JSONJoy.swift
//
//  Created by Dalton Cherry on 9/17/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
//  Really old class I built back in the early days of Swift (https://github.com/daltoniam/JSONJoy-Swift). 
//  Been updated as Swift has but should be replace in Swift 4 with the new Codable protocols.
//
//////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation

public protocol JSONBasicType {}
extension String:   JSONBasicType {}
extension Int:      JSONBasicType {}
extension UInt:     JSONBasicType {}
extension Double:   JSONBasicType {}
extension Float:   	JSONBasicType {}
extension NSNumber: JSONBasicType {}
extension Bool:     JSONBasicType {}

public enum JSONError: Error {
    case wrongType
}

open class JSONDecoder {
    var value: Any?
    
    /**
     Converts any raw object like a String or Data into a JSONJoy object
     */
    public init(_ raw: Any, isSub: Bool = false) {
        var rawObject: Any = raw
        if let str = rawObject as? String, !isSub {
            rawObject = str.data(using: String.Encoding.utf8)! as Any
        }
        if let data = rawObject as? Data {
            var response: Any?
            do {
                try response = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                rawObject = response!
            }
            catch let error as NSError {
                value = error
                return
            }
        }
        if let array = rawObject as? NSArray {
            var collect = [JSONDecoder]()
            for val: Any in array {
                collect.append(JSONDecoder(val, isSub: true))
            }
            value = collect as Any?
        } else if let dict = rawObject as? NSDictionary {
            var collect = Dictionary<String,JSONDecoder>()
            for (key,val) in dict {
                collect[key as! String] = JSONDecoder(val as AnyObject, isSub: true)
            }
            value = collect as Any?
        } else {
            value = rawObject
        }
    }
    
    /**
     get typed `Array` of `JSONJoy` and have it throw if it doesn't work
     */
    public func get<T: JSONJoy>() throws -> [T] {
        guard let a = getOptionalArray() else { throw JSONError.wrongType }
        return try a.reduce([T]()) { $0.0 + [try T($0.1)] }
    }
    
    /**
     get typed `Array` and have it throw if it doesn't work
     */
    open func get<T: JSONBasicType>() throws -> [T] {
        guard let a = getOptionalArray() else { throw JSONError.wrongType }
        return try a.reduce([T]()) { $0.0 + [try $0.1.get()] }
    }
    
    /**
     get any type and have it throw if it doesn't work
     */
    open func get<T>() throws -> T {
        if let val = value as? Error {
            throw val
        }
        guard let val = value as? T else {throw JSONError.wrongType}
        return val
    }
    
    /**
     get any type as an optional
     */
    open func getOptional<T>() -> T? {
        do { return try get() }
        catch { return nil }
    }
    
    /**
     get an array
     */
    open func getOptionalArray() -> [JSONDecoder]? {
        return value as? [JSONDecoder]
    }
    
    /**
     get typed `Array` of `JSONJoy` as an optional
     */
    public func getOptional<T: JSONJoy>() -> [T]? {
        guard let a = getOptionalArray() else { return nil }
        do { return try a.reduce([T]()) { $0.0 + [try T($0.1)] } }
        catch { return nil }
    }
    
    /**
     get typed `Array` of `JSONJoy` as an optional
     */
    public func getOptional<T: JSONBasicType>() -> [T]? {
        guard let a = getOptionalArray() else { return nil }
        do { return try a.reduce([T]()) { $0.0 + [try $0.1.get()] } }
        catch { return nil }
    }
    
    /**
     Array access support
     */
    open subscript(index: Int) -> JSONDecoder {
        get {
            if let array = value as? NSArray {
                if array.count > index {
                    return array[index] as! JSONDecoder
                }
            }
            return JSONDecoder(createError("index: \(index) is greater than array or this is not an Array type."))
        }
    }
    
    /**
     Dictionary access support
     */
    open subscript(key: String) -> JSONDecoder {
        get {
            if let dict = value as? NSDictionary {
                if let value: Any = dict[key] {
                    return value as! JSONDecoder
                }
            }
            return JSONDecoder(createError("key: \(key) does not exist or this is not a Dictionary type"))
        }
    }
    
    /**
     Simple helper method to create an error
     */
    func createError(_ text: String) -> Error {
        return NSError(domain: "JSONJoy", code: 1002, userInfo: [NSLocalizedDescriptionKey: text]) as Error
    }

}

/**
 Implement this protocol on all objects you want to use JSONJoy with
 */
public protocol JSONJoy {
    init(_ decoder: JSONDecoder) throws
}

extension JSONDecoder: CustomStringConvertible {
    public var description: String {
        if let value = value {
            return String(describing: value)
        } else {
            return String(describing: value)
        }
    }
}

extension JSONDecoder: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let value = value {
            return String(reflecting: value)
        } else {
            return String(reflecting: value)
        }
    }
}

