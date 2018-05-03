//
//  ViewController.swift
//  DouYin-Shoot
//
//  Created by 冯晓林 on 2018/5/3.
//  Copyright © 2018年 WeShion. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SMRecordBottomViewDelegate {
    
    var progressView: QUProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 147/255.0, green: 237/255.0, blue: 148/255.0, alpha: 1)

        progressView = QUProgressView(frame: CGRect(x: 0, y: 23, width: self.view.bounds.width, height: 5))
        progressView!.showBlink = false
        progressView!.showNoticePoint = true
        progressView!.maxDuration = 15
        progressView!.minDuration = 0
        view.addSubview(progressView!)
        
        
        let bottomView = RecordBottomView()
        bottomView.delegate = self
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(160)
        }
        
    }

    
    func SMRecordBottomViewRecordStart() {
        progressView.showBlink = false
        progressView.videoCount += 1
    }
    
    func SMRecordBottomViewRecordStop() {
        
    }
    
    func SMRecordBottomViewRecordError() {
        
    }
    
    func SMRecordBottomViewDeletePart(selected: Bool) {
        
    }
    
    func SMRecordBottomViewFinishRecord() {
        
    }

}

