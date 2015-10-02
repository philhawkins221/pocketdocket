//
//  ResearchViewController.swift
//  Docket
//
//  Created by Phil Hawkins on 7/17/15.
//  Copyright © 2015 Phil Hawkins. All rights reserved.
//
var research = ""

import UIKit

class ResearchViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var loadingindicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webview.delegate = self
        webview.hidden = true
        
        if let url = NSURL(string: research) {
            webview.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 208/255, green: 38/255, blue: 98/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 227/255, green: 223/255, blue: 215/255, alpha: 1)]
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingindicator.stopAnimating()
        webview.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func back(sender: AnyObject) {
        webview.goBack()
    }
    
    @IBAction func forward(sender: AnyObject) {
        webview.goForward()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
