//
//  UIViewExtensions.swift
//  NYC Schools
//
//  Created by Guillermo Anaya on 05/12/22.
//

import Foundation
import UIKit

extension UIView {
  
  private struct Keys {
    static var timer = "com.test.timer"
  }
  
  func displayMessage(_ message: String, backgroundColor: UIColor = .systemRed) {
    let wrapperView = UIView()
    wrapperView.backgroundColor = backgroundColor
    wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    wrapperView.layer.cornerRadius = 10.0
    
    let messageLabel = UILabel()
    messageLabel.text = message
    messageLabel.textColor = .white
    messageLabel.numberOfLines = 2
    messageLabel.textAlignment = .center
    messageLabel.lineBreakMode = .byTruncatingTail;
    messageLabel.backgroundColor = UIColor.clear
    
    let messagePadding = 0.8
    
    let maxMessageSize = CGSize(width: (self.bounds.size.width * messagePadding), height: self.bounds.size.height * messagePadding)
    let messageSize = messageLabel.sizeThatFits(maxMessageSize)
    let actualWidth = min(messageSize.width, maxMessageSize.width)
    let actualHeight = min(messageSize.height, maxMessageSize.height)
    messageLabel.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
    
    let messageRect = CGRect(x: 0.0, y: 0.0, width: messageLabel.bounds.size.width, height: messageLabel.bounds.size.height)
    
    let viewHeightPadding = 10.0
    
    let wrapperWidth = messageRect.width + viewHeightPadding
    let wrapperHeight = messageRect.height + viewHeightPadding
    
    wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
    messageLabel.center = CGPoint(x: wrapperView.bounds.size.width / 2.0, y: (wrapperView.frame.size.height / 2.0))
    wrapperView.addSubview(messageLabel)
    
    wrapperView.center = CGPoint(x: self.bounds.size.width / 2.0, y: (wrapperView.frame.size.height / 2.0) + 10.0)
    wrapperView.alpha = 0.0
    self.addSubview(wrapperView)
    
    
    //appear
    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      wrapperView.alpha = 1.0
    }) { _ in
      // 3 sec to dissappear
      let timer = Timer(timeInterval: 3.0, target: self, selector: #selector(UIView.timerDidFinish(_:)), userInfo: wrapperView, repeats: false)
      RunLoop.main.add(timer, forMode: .common)
      objc_setAssociatedObject(wrapperView, &Keys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  @objc
  private func timerDidFinish(_ timer: Timer) {
    guard let view = timer.userInfo as? UIView else { return }
    
    if let timer = objc_getAssociatedObject(view, &Keys.timer) as? Timer {
      timer.invalidate()
    }
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
      view.alpha = 0.0
    }) { _ in
      view.removeFromSuperview()
    }
  }
}
