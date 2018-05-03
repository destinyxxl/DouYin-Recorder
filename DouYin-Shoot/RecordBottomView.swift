//
//  RecordBottomView.swift
//  DouYin-Shoot
//
//  Created by 冯晓林 on 2018/5/3.
//  Copyright © 2018年 WeShion. All rights reserved.
//

import UIKit
import SnapKit

protocol SMRecordBottomViewDelegate: class {
    
    func SMRecordBottomViewRecordStart()//开始录制
    func SMRecordBottomViewRecordStop()//停止录制
    func SMRecordBottomViewRecordError()//取消录制
    
    func SMRecordBottomViewDeletePart(selected: Bool)//删除片段
    func SMRecordBottomViewFinishRecord()//完成录制
    
}

class RecordBottomView: UIView, UIScrollViewDelegate {
    
    enum SMRecordType {
        case singleTap   //单击拍摄
        case longPress   //长按拍摄
    }
    
    private var startBtnCenterLayer: CALayer?//录制按钮-开始录制、停止录制的layer
    private var startBtnCircleLayer: CALayer?//录制按钮-周边的环形动画layer
    private var startBtnBigCircleLayer: CALayer?//录制按钮-周边的大环形动画layer
    
    private var recording: Bool = false
    
    private var singleTapButton: UIButton?
    private var longPressButton: UIButton?
    
    private var currentRecordType: SMRecordType = .longPress
    
    weak var delegate: SMRecordBottomViewDelegate?//代理

    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .green
        setupUI()
        setConstraints()
        
        resetRecordButtonUIWithCurrentType()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(recordBtn)
        addSubview(switchScrollView)
        addSubview(bottomIndictorView)
        
        
        longPressButton?.addTarget(self, action: #selector(tapLongPressModeButton), for: .touchUpInside)
        singleTapButton?.addTarget(self, action: #selector(tapSingleTapModeButton), for: .touchUpInside)
    }
    
    private func setConstraints() {

        switchScrollView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(41)
        }
        
        recordBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(switchScrollView.snp.top).offset(-15)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: startButtonWidth, height: startButtonWidth))
        }
        
        bottomIndictorView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(-13)
            make.width.equalTo(10)
            make.height.equalTo(2)
        }
        
    }
    
    // MARK: - 按钮的点击事件
    @objc private func recordButtonTouchUp() {//抬起
        
        if longPressing == true {
            longPressingEnd = true
            startBtnBigCircleLayer?.removeAllAnimations()
        }
        
        if currentRecordType == .longPress {
            stopRecord()
        }
    }
    
    var longPressing = false
    var longPressingEnd = false
    
    @objc private func recordButtonTouchDown() {//按下
        
        guard recording == false else {
            stopRecord()
            return
        }
        
        if currentRecordType == .singleTap {
            longPressing = false
            updateCenterLayerSuspend()
        } else {
            longPressing = true
            startBtnCenterLayer?.isHidden = true
            recordBtn.setTitle("", for: .normal)
        }
        
        startBtnCircleLayer?.isHidden = true
        startBtnBigCircleLayer?.isHidden = false
        
        creatBreathAnimation()
        
        recording = true
        changeOtherButtonType()
        
        delegate?.SMRecordBottomViewRecordStart()
    }
    
    private func updateCenterLayerSuspend() { //中间圆形layer变换为方形layer
        startBtnCenterLayer?.isHidden = false
        startBtnCenterLayer?.cornerRadius = 10
        startBtnCenterLayer?.frame = CGRect(x: (startButtonWidth - 40) / 2,
                                            y: (startButtonWidth - 40) / 2,
                                            width: 40,
                                            height: 40)
    }
    
    private func creatBreathAnimation() {
        
        //呼吸动画
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.fromValue = 5
        animation.toValue = 15
        animation.repeatCount = HUGE
        animation.duration = 0.5
        animation.autoreverses = true
        self.startBtnBigCircleLayer?.add(animation, forKey: animation.keyPath)
    }
    
    func stopRecord() { //停止录制
        
        guard recording == true else {
            return
        }
        
//        touchStartTime = 0
        updateRecordTypeToEndRecord()
//        delegate?.SMRecordBottomViewRecordStop()
    }
    
    func updateRecordTypeToEndRecord() {
        recording = false
        resetRecordButtonUIWithCurrentType()
        changeOtherButtonType()
    }
    
    func changeOtherButtonType() {
//        deleteBtn.isHidden = recording
//        finishBtn.isHidden = recording
        switchScrollView.isHidden = recording
        bottomIndictorView.isHidden = recording
    }
    
    private func resetRecordButtonUIWithCurrentType() { //重置拍摄按钮UI
        startBtnBigCircleLayer?.removeAllAnimations()
        startBtnBigCircleLayer?.isHidden = true
        startBtnCircleLayer?.isHidden = false
        startBtnCenterLayer?.isHidden = false
        if currentRecordType == .singleTap {
            
            self.startBtnCenterLayer?.frame = CGRect(x: (startButtonWidth - layerWidth) / 2,
                                                     y: (startButtonWidth - layerWidth) / 2,
                                                     width: layerWidth,
                                                     height: layerWidth)
            self.startBtnCenterLayer?.cornerRadius = CGFloat(layerWidth / 2.0)
            self.recordBtn.setTitle("", for: .normal)
            
        } else {
            
            self.startBtnCenterLayer?.bounds = CGRect(x: 0, y: 0, width: startButtonWidth, height: startButtonWidth)
            self.startBtnCenterLayer?.cornerRadius = CGFloat(startButtonWidth / 2.0)
            self.recordBtn.setTitle("按住拍", for: .normal)
            self.recordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            updatebottomScrollLabelToLongPress()
        } else {
            updatebottomScrollLabelToSingleTap()
        }
    }
    
    @objc func tapLongPressModeButton() {
        switchScrollView.setContentOffset(.zero, animated: true)
    }
    
    @objc func tapSingleTapModeButton() {
        switchScrollView.setContentOffset(CGPoint(x: 90, y: 0), animated: true)
    }
    
    func updatebottomScrollLabelToLongPress() {
        currentRecordType = .longPress
        self.singleTapButton?.titleLabel?.alpha = 0.7
        self.longPressButton?.titleLabel?.alpha = 1.0
        self.longPressButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.singleTapButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        resetRecordButtonUIWithCurrentType()
    }
    
    func updatebottomScrollLabelToSingleTap() {
        currentRecordType = .singleTap
        self.singleTapButton?.titleLabel?.alpha = 1.0
        self.longPressButton?.titleLabel?.alpha = 0.7
        self.longPressButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.singleTapButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        resetRecordButtonUIWithCurrentType()
    }

    // MARK: 懒加载
    private lazy var recordBtn: UIButton = {
        
        let btn = UIButton()
        btn.addTarget(self, action: #selector(recordButtonTouchUp), for: .touchUpInside)
        btn.addTarget(self, action: #selector(recordButtonTouchDown), for: .touchDown)
        btn.addTarget(self, action: #selector(recordButtonTouchUp), for: .touchUpOutside)
        btn.setTitleColor(UIColor.black, for: .normal)
        
        let layer = CALayer()
        layer.backgroundColor = mainColor.cgColor
        
        layer.frame = CGRect(x: (startButtonWidth - layerWidth) / 2, y: (startButtonWidth - layerWidth) / 2, width: layerWidth, height: layerWidth)
        layer.cornerRadius = CGFloat(layerWidth / 2.0)
        layer.masksToBounds = true
        btn.layer.addSublayer(layer)
        self.startBtnCenterLayer = layer
        
        let circleLayer = CAShapeLayer()
        circleLayer.frame = CGRect(x: 0, y: 0, width: startButtonWidth, height: startButtonWidth)
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: startButtonWidth / 2, y: startButtonWidth / 2),
            radius: (startButtonWidth - strokeWidth ) * 0.5 ,
            startAngle: -1 * CGFloat(Double.pi / 2),
            endAngle: 3 * CGFloat(Double.pi / 2),
            clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = mainColor.cgColor
        circleLayer.opacity = 0.7
        circleLayer.lineWidth = strokeWidth
        btn.layer.addSublayer(circleLayer)
        self.startBtnCircleLayer = circleLayer
        
        let bigCircleLayerW = startButtonWidth + 26
        let bigCircleLayer = CAShapeLayer()
        bigCircleLayer.frame = CGRect(x: 0, y: 0, width: startButtonWidth, height: startButtonWidth)
        let bigcirclePath = UIBezierPath(
            arcCenter: CGPoint(x: startButtonWidth / 2, y: startButtonWidth / 2),
            radius: (bigCircleLayerW - strokeWidth ) * 0.5,
            startAngle: -1 * CGFloat(Double.pi / 2),
            endAngle: 3 * CGFloat(Double.pi / 2),
            clockwise: true)
        bigCircleLayer.path = bigcirclePath.cgPath
        bigCircleLayer.fillColor = UIColor.clear.cgColor
        bigCircleLayer.strokeColor = mainColor.cgColor
        bigCircleLayer.opacity = 0.7
        bigCircleLayer.lineWidth = strokeWidth
        bigCircleLayer.isHidden = true
        btn.layer.addSublayer(bigCircleLayer)
        self.startBtnBigCircleLayer = bigCircleLayer
        
        return btn
    }()
    
    lazy var switchScrollView: UIScrollView = {
        let bottomLabelW = screenW * 0.5 + 45 //45是碰出来的。。。 为了让label对准小点
        let bottomLabelH: CGFloat = 22
        let lscrollView = UIScrollView()
        lscrollView.delegate = self
        lscrollView.isPagingEnabled = true
        lscrollView.showsHorizontalScrollIndicator = false
        lscrollView.bounces = false
        
        lscrollView.contentSize = CGSize(width: bottomLabelW * 2, height: bottomLabelH)
        
        let long = UIButton()
        long.setTitle("长按拍摄", for: .normal)
        long.setTitleColor(UIColor.white, for: .normal)
        long.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        long.contentHorizontalAlignment = .right
        long.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        long.frame = CGRect(x: 0, y: 0, width: bottomLabelW, height: bottomLabelH)
        lscrollView.addSubview(long)
        self.longPressButton = long
        
        let single = UIButton()
        single.setTitle("单击拍摄", for: .normal)
        single.titleLabel?.alpha = 0.7
        single.setTitleColor(.white, for: .normal)
        single.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        single.contentHorizontalAlignment = .left
        single.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        single.frame = CGRect(x: bottomLabelW, y: 0, width: bottomLabelW, height: bottomLabelH)
        lscrollView.addSubview(single)
        self.singleTapButton = single
        
        return lscrollView
    }()
    
    private lazy var bottomIndictorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        return view
    }()
}
