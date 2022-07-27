//
//  Activity.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/25.
//


import AsyncDisplayKit
import UIKit
class CountNode: ASDisplayNode {
    let countLabel = ASTextNode()

    let horizontalPadding: CGFloat = 13.0
    let verticalPadding: CGFloat = 2.0
    
    let attributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor: UIColor.lightGray,
        NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
    ]
    
    init(count: Int) { //calculate the number of words and assign to label
        
        super.init()
        self.countLabel.attributedText = NSAttributedString.init(string: "\(count)", attributes: attributes)

        self.automaticallyManagesSubnodes = true
    }

    override func didLoad() {
        super.didLoad()
        
        self.backgroundColor = .systemGray2
        self.view.clipsToBounds = true
    }

    override func layoutDidFinish() {
        super.layoutDidFinish()
        self.layer.cornerRadius = self.frame.height / 2
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding), child: countLabel)
    }

}
