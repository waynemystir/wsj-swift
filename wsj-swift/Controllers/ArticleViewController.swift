//
//  ArticleViewController.swift
//  wsj-swift
//
//  Created by WAYNE SMALL on 11/17/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    private let urlString: String
    
    init(url: String) {
        self.urlString = url
        super.init(nibName: "ArticleView", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if let u = NSURL(string: urlString) { webView.loadRequest(NSURLRequest(URL: u)) }
    }

}
