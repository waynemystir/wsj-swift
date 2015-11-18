//
//  ViewController.swift
//  wsj-swift
//
//  Created by WAYNE SMALL on 11/17/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LoadWsjDataDelegate, UIScrollViewDelegate {
    
    // MARK: Stored properties
    
    private static let headerLblBgClr = UIColor(red: 0.79, green: 0.79, blue: 0.79, alpha: 1.0)
    
    @IBOutlet weak private var headerScroller: UIScrollView!
    @IBOutlet weak private var headersContainer: UIView!
    @IBOutlet weak private var scroller: UIScrollView!
    @IBOutlet weak private var tablesContainer: UIView!
    @IBOutlet weak private var tblcContainerCenterXConstr: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    init() {
        super.init(nibName: "View", bundle: nil)
        LoadWsjData.manager.dataDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Wall Street Journal"
        self.automaticallyAdjustsScrollViewInsets = false
        
        for i in 0...5 { tablesContainer.addSubview(WsjTableView(placement: i)) }
        
        let s = UIScreen.mainScreen().bounds
        let sw = s.size.width;
        let sha = s.size.height - 108;
        
        scroller.removeConstraint(tblcContainerCenterXConstr)
        tablesContainer.translatesAutoresizingMaskIntoConstraints = true
        tablesContainer.frame = CGRectMake(0, 0, sw * 6, sha);
        scroller.contentSize = CGSizeMake(sw * 6, sha);
        scroller.delegate = self;
        
        for i in 0...5 { LoadWsjData.load(i) }
    }
    
    // MARK: LoadWsjDataDelegate
    
    func loadedData(dataType: DATA_TYPE, wsjItems: [WsjRssItem]) {
        guard let tv = tablesContainer.viewWithTag(WsjTableView.kWsjTblVwStartTag + dataType.rawValue) as? WsjTableView
            else { return }
        tv.tableViewData = wsjItems;
    }
    
    func requestTimedOut(dataType: DATA_TYPE, name: String) {
        displayFailMessage(dataType, name: name, message: "The request timed out")
    }
    
    func requestFailedOffline(dataType: DATA_TYPE, name: String) {
        displayFailMessage(dataType, name: name, message: "Your device is not connected to the internet.")
    }
    
    func requestFailed(dataType: DATA_TYPE, name: String) {
        displayFailMessage(dataType, name: name, message: "A problem occurred.")
    }
    
    func displayFailMessage(dataType: DATA_TYPE, name: String, message: String) {
        guard let tv = tablesContainer.viewWithTag(WsjTableView.kWsjTblVwStartTag + dataType.rawValue) else { return }
        let nl = UILabel(frame: tv.frame)
        nl.numberOfLines = 0
        nl.lineBreakMode = .ByWordWrapping
        nl.backgroundColor = UIColor.clearColor()
        nl.textColor = UIColor.blackColor()
        nl.textAlignment = .Center
        nl.text = "\(message)\n\nThe \(name) could not be loaded."
        tablesContainer.addSubview(nl)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = UIScreen.mainScreen().bounds.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let currentPageNumber = round(fractionalPage)
        
        let sl = headersContainer.viewWithTag(19000 + Int(currentPageNumber))!
        headerScroller.scrollRectToVisible(sl.frame, animated: true)
        
        for view in headersContainer.subviews { view.backgroundColor = UIColor.clearColor() }
        sl.backgroundColor = ViewController.headerLblBgClr;
    }
    
    // MARK: Tap gesture

    @IBAction func tapHeaderLbl(sender: AnyObject) {
        guard let s = sender as? UITapGestureRecognizer,
            let sv = s.view,
            let tv = tablesContainer.viewWithTag(sv.tag - 19000 + WsjTableView.kWsjTblVwStartTag)
            else { return }
        scroller.scrollRectToVisible(tv.frame, animated: true)
    }
}

