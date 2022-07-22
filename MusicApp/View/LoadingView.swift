//
//  LoadingView.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/20.
//

import Foundation
import UIKit


public class LoadingView {
    
    private static var keyframeAnimation: CAKeyframeAnimation!
    
    public static func bounceAnimation() -> CAAnimation {
        
        keyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyframeAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        keyframeAnimation.duration = TimeInterval(0.3)
        keyframeAnimation.calculationMode = CAAnimationCalculationMode.cubic
        
        return keyframeAnimation
    }
    
    
    private static var loadingView: UIView?
    private static var spinner: UIActivityIndicatorView?
    private static var messageLabel: UILabel?
    
    public static func addToast(message: String?) {
        
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        
        if loadingView == nil, let window = keyWindow {
            loadingView = UIView()
            loadingView?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            loadingView?.center = window.center
            loadingView?.backgroundColor = .darkGray
            loadingView?.alpha = 0.9
            loadingView?.layer.cornerRadius = 10
            loadingView?.clipsToBounds = true
            spinner = UIActivityIndicatorView()
            spinner?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            spinner?.center = CGPoint(x: loadingView!.bounds.midX, y: loadingView!.bounds.midY - 15)
            spinner?.style = .large
            spinner?.startAnimating()
            messageLabel = UILabel()
            messageLabel?.frame = CGRect(x: 0, y: loadingView!.bounds.midY + 20, width: 200, height: 20)
            messageLabel?.center = CGPoint(x: window.center.x, y: window.center.y + 20)
            messageLabel?.textColor = .white
            messageLabel?.font = UIFont(name: "TaipeiSansTCBeta-Regular", size: 15)
            messageLabel?.textAlignment = .center
            messageLabel?.text = message
            loadingView?.addSubview(spinner!)
            window.addSubview(loadingView!)
            window.addSubview(messageLabel!)
        }
    }
    
    public static func removeToast(message: String?) {
        
        DispatchQueue.main.async {
            
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            
            if let loadingView = loadingView, let window = keyWindow {
                UIView.animate(withDuration: 0.4, animations: {
                    loadingView.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
                    loadingView.center = window.center
                    spinner?.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY)
                    messageLabel?.center = window.center
                    messageLabel?.text = message
                    spinner?.alpha = 0
                }) { _ in
                    UIView.animate(withDuration: 1.2, animations: {
                        messageLabel?.center.y -= 50
                        messageLabel?.alpha = 0
                        loadingView.center.y -= 50
                        loadingView.alpha = 0
                    }, completion: { _ in
                        remove()
                    })
                }
            }
        }
    }
    
    public static func remove() {
        self.loadingView?.removeFromSuperview()
        self.messageLabel?.removeFromSuperview()
        self.loadingView = nil
        self.messageLabel = nil
        self.spinner = nil
    }
    
}
