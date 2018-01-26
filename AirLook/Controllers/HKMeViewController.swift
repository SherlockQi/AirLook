//
//  HKMeViewController.swift
//  HeavenMemoirs
//
//  Created by HeiKki on 2017/11/3.
//  Copyright © 2017年 HeiKki. All rights reserved.
//

import UIKit

class HKMeViewController: UIViewController {
    @IBOutlet weak var jianshuIconImageView: UILabel!
    
    @IBAction func backButtonDidClick(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        jianshuIconImageView.layer.cornerRadius = jianshuIconImageView.bounds.size.width * 0.5
        jianshuIconImageView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
