//
//  PlayAudioViewController+Handeler.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import MediaPlayer

extension PlayAudioViewController {
    func setupView() {
        
        view.addSubview(albumLabel)
        view.addSubview(songLabel)
        view.addSubview(imageView)
        view.addSubview(stackView)
        view.backgroundColor = .white
        view.addSubview(slider)
        view.addSubview(volumeSlider)
        view.addSubview(leftLabel)
        view.addSubview(rightLabel)
        
        slider.addTarget(self, action: #selector(musicProgressAdjust(_:)), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(volumeAdjust), for: .valueChanged)
        prevButton.addTarget(self, action: #selector(prevTenSeconds), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTenSeconds), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(toggletPlay), for: .touchUpInside)
    }

    
    @objc func nextTenSeconds() {
        
        let cmTime = AudioHelper.shared.audioPlayer.currentTime() + CMTime(seconds: 10, preferredTimescale: 1000)
        AudioHelper.shared.audioPlayer.seek(to: cmTime, completionHandler: { success in
            if success {
                print("seek time success.")
            } else {
                print("seek time failure.")
            }
        })
    }
    
    @objc func prevTenSeconds() {
        
        let cmTime = AudioHelper.shared.audioPlayer.currentTime() - CMTime(seconds: 10, preferredTimescale: 1000)
        AudioHelper.shared.audioPlayer.seek(to: cmTime, completionHandler: { success in
            if success {
                print("seek time success.")
            } else {
                print("seek time failure.")
            }
        })
    }
    
    //Media
    @objc func musicProgressAdjust(_ sender: UISlider) {
        
        let seconds : Float64 = Float64((slider.value * 30))
        
        let targetTime:CMTime = CMTimeMakeWithSeconds(seconds, preferredTimescale: Int32(NSEC_PER_SEC))
        
        AudioHelper.shared.audioPlayer.seek(to: targetTime)
        
        detailViewModel?.setNowPlayingInfo()
//        if let music = detailViewModel?.music {
//            AudioHelper.shared.setNowPlayingInfo(music: music)
//        }
    }
}
