//
//  ParseWsjDocOperation.swift
//  wsj-swift
//
//  Created by WAYNE SMALL on 11/17/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

import UIKit

class ParseWsjDocOperation: NSOperation, NSXMLParserDelegate {
    
    private static let kKeyItem = "item"
    private static let kKeyTitle = "title";
    private static let kKeyLink = "link";
    private static let kKeyItemDescriptioin = "description";
    private static let kKeyMediaContent = "media:content";
    private static let kKeyUrl = "url";
    private static let kKeyMedium = "medium";
    
    private(set) var wsjItems: [WsjRssItem]
    private var currentWsjItem: WsjRssItem
    private let dataToParse: NSData
    private var foundCharacters: String
    
    init(data: NSData) {
        wsjItems = []
        currentWsjItem = WsjRssItem()
        dataToParse = data
        foundCharacters = ""
    }
    
    override func main() {
        let parser = NSXMLParser(data: dataToParse)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == ParseWsjDocOperation.kKeyItem { self.currentWsjItem = WsjRssItem() }
        
        else if elementName == ParseWsjDocOperation.kKeyMediaContent {
            
            let urlAttribute = attributeDict[ParseWsjDocOperation.kKeyUrl]
            let mediumAttribute = attributeDict[ParseWsjDocOperation.kKeyMedium]
            if mediumAttribute  == "image" { self.currentWsjItem.imageUrlString = urlAttribute }
            
        }
        
        foundCharacters = ""
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) { self.foundCharacters += string }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == ParseWsjDocOperation.kKeyItem { wsjItems.append(currentWsjItem) }
        else if elementName == ParseWsjDocOperation.kKeyTitle { currentWsjItem.title = foundCharacters }
        else if elementName == ParseWsjDocOperation.kKeyLink { currentWsjItem.urlString = foundCharacters }
        else if elementName == ParseWsjDocOperation.kKeyItemDescriptioin { currentWsjItem.itemDescription = foundCharacters }
    }

}
