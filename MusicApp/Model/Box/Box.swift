//
//  Box.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import Foundation

//MARK: Generic Type to bind Data
final class Box<T> {
    //1
    typealias Listener = (T) -> Void
    var listener: Listener?
    //2
    var value: T {
        didSet {
            listener?(value)
        }
    }
    //3
    init(_ value: T) {
        self.value = value
    }
    //4
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
