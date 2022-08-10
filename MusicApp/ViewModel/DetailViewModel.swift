//
//  DetailViewModel.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import Foundation
import CoreMIDI
import UIKit


class DetailViewModel {
    
    let music: Music?
    
    let musicUrl: Box<String> = Box(" ")
    let collectionName: Box<String> = Box(" ")
    let songName: Box<String> = Box(" ")
    
    init(music: Music?) {
        self.music = music
        
        setup()
    }
    
    func setup() {
        
        self.musicUrl.value = music?.artworkUrl100 ?? ""
        self.collectionName.value = music?.collectionName ?? ""
        self.songName.value = music?.trackName ?? ""
    }
    
    func setNowPlayingInfo() {
        if let music = music {
            AudioHelper.shared.setNowPlayingInfo(music: music)
        }
    }
    
}
