//
//  Timer+Extention.swift
//  DouYin-Shoot
//
//  Created by 冯晓林 on 2018/5/4.
//  Copyright © 2018年 WeShion. All rights reserved.
//

import Foundation

extension Timer {
    
    func pause() {
        self.fireDate = Date.distantFuture
    }
    
    func resume() {
        self.fireDate = Date.distantPast
    }
    
}
