//
//  LoadWsjData.swift
//  wsj-swift
//
//  Created by WAYNE SMALL on 11/17/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

import UIKit

enum DATA_TYPE: Int { case WORLD = 0, OPINION, BUSINESS, MARKETS, TECH, LIFE }

private struct WSJ_DATA { let dataType: DATA_TYPE, urlPath, name: String }

protocol LoadWsjDataDelegate {
    func loadedData(dataType: DATA_TYPE, wsjItems: [WsjRssItem])
    func requestTimedOut(dataType: DATA_TYPE, name: String)
    func requestFailedOffline(dataType: DATA_TYPE, name: String)
    func requestFailed(dataType: DATA_TYPE, name: String)
}

class LoadWsjData: NSObject {
    
    // MARK: Stored properties
    
    private static let world = WSJ_DATA(dataType: DATA_TYPE.WORLD, urlPath: "3_7085.xml", name: "World News")
    private static let opinion = WSJ_DATA(dataType: DATA_TYPE.OPINION, urlPath: "3_7041.xml", name: "Opinions")
    private static let business = WSJ_DATA(dataType: DATA_TYPE.BUSINESS, urlPath: "3_7014.xml", name: "Business News")
    private static let markets = WSJ_DATA(dataType: DATA_TYPE.MARKETS, urlPath: "3_7031.xml", name: "Markets")
    private static let tech = WSJ_DATA(dataType: DATA_TYPE.TECH, urlPath: "3_7455.xml", name: "Technology News")
    private static let life = WSJ_DATA(dataType: DATA_TYPE.LIFE, urlPath: "3_7201.xml", name: "Lifestyle Section")
    
    private static let dd = [ world, opinion, business, markets, tech, life ]
    
    static let manager = LoadWsjData()
    private static let parseOperationQueue = NSOperationQueue()
    
    var dataDelegate: LoadWsjDataDelegate?
    
    // MARK: Class functions
    
    class func load(dataType: Int) { dataTask(dd[dataType]) }
    
    private class func wsjUrl(urlPath: String) -> String { return "http://www.wsj.com/xml/rss/" + urlPath }
    
    private class func mq(block: () -> Void) { NSOperationQueue.mainQueue().addOperationWithBlock(block) }
    
    private class func dataTask(loadData: WSJ_DATA) -> NSURLSessionTask {
        let url = wsjUrl(loadData.urlPath).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.timeoutInterval = 10
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if handleError(error, loadData: loadData) || handleResponse(response, loadData: loadData) { return };
            guard let d = data else { return mq( { manager.dataDelegate?.requestFailed(loadData.dataType, name: loadData.name) } ) }
            
            let op = ParseWsjDocOperation(data: d)
            op.completionBlock = { [unowned op] in
                let wi = op.wsjItems
                mq( { manager.dataDelegate?.loadedData(loadData.dataType, wsjItems: wi) } )
            }
            parseOperationQueue.addOperation(op)
        }
        task.resume()
        return task
    }
    
    private class func handleError(error: NSError?, loadData: WSJ_DATA) -> Bool {
        guard let err = error else { return false }
        switch(err.code) {
        case NSURLErrorCancelled: break
        case NSURLErrorTimedOut: mq( { manager.dataDelegate?.requestTimedOut(loadData.dataType, name: loadData.name) } )
        case NSURLErrorNotConnectedToInternet: mq( { manager.dataDelegate?.requestFailedOffline(loadData.dataType, name: loadData.name) } )
        default: mq( { manager.dataDelegate?.requestFailed(loadData.dataType, name: loadData.name) } )
        }
        
        return true
    }
    
    private class func handleResponse(response: NSURLResponse?, loadData: WSJ_DATA) -> Bool {
        if let resp = response as? NSHTTPURLResponse where resp.statusCode == 200 { return false }
        mq( { manager.dataDelegate?.requestFailed(loadData.dataType, name: loadData.name) } )
        return true
    }

}
