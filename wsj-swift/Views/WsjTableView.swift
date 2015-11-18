//
//  WsjTableView.swift
//  wsj-swift
//
//  Created by WAYNE SMALL on 11/17/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

import UIKit

class WsjTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    static let kWsjTblVwStartTag = 17000
    private static let cellIdentifier = "wsjResuseId"
    private static let placeHolderImage = UIImage(named: "charliebrown.jpg")
    
    var tableViewData: [WsjRssItem] { didSet { reloadData() } }
    
    // MARK: Lifecycle
    
    init(placement: Int) {
        tableViewData = []
        let s = UIScreen.mainScreen().bounds
        let sw = s.size.width
        super.init(frame: CGRectMake(sw * CGFloat(placement), 0, sw, s.size.height - 108), style: .Plain)
        registerNib(UINib(nibName: "WsjTableViewCell", bundle: nil), forCellReuseIdentifier: WsjTableView.cellIdentifier)
        tag = WsjTableView.kWsjTblVwStartTag + placement
        dataSource = self
        delegate = self
        separatorStyle = .None
        separatorColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(WsjTableView.cellIdentifier) as! WsjTableViewCell
        let wri = tableViewData[indexPath.row]
        cell.title.text = wri.title;
        cell.itemDescription.text = wri.itemDescription;
        
        cell.itemImage.image = nil;
        
        guard let us = wri.imageUrlString, let url = NSURL(string: us) else {
            cell.itemImage.image = WsjTableView.placeHolderImage
            return cell
        }
        
        let sp = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        sp.frame = cell.itemImage.bounds;
        sp.startAnimating()
        cell.itemImage.addSubview(sp)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let d = NSData(contentsOfURL: url)
            let image = d == nil ? nil : UIImage(data: d!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                sp.removeFromSuperview()
                let mc = tableView.cellForRowAtIndexPath(indexPath) as? WsjTableViewCell
                mc?.itemImage.image = image ?? WsjTableView.placeHolderImage
            })
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let w = UIApplication.sharedApplication().delegate?.window, nc = w?.rootViewController as? UINavigationController,
            us = tableViewData[indexPath.row].urlString  {
                nc.pushViewController(ArticleViewController(url: us), animated: true)
        }
    }

}
