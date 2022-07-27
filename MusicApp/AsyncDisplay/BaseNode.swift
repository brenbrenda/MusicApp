//
//  BaseNode.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/25.
//

import AsyncDisplayKit

class BaseNode: ASDisplayNode {
    
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }
}

