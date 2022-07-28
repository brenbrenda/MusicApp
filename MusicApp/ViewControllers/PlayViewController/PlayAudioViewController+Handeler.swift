//
//  PlayAudioViewController+Handeler.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import MediaPlayer

extension PlayAudioViewController {
    
    func bindProgress() {
        //bind value of music progress
        AudioHelper.shared.audioPosition.bind { [weak self] audioPosition in
            if let audioPosition = audioPosition {
                
                guard let self = self else { return }
                
                self.slider.value = Float(audioPosition.current)/Float(audioPosition.durationTime)
                if Float(audioPosition.current)/Float(audioPosition.durationTime) == 1 {
                    self.slider.maximumTrackTintColor = .gray
                    
//                    self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
                    //TODO handling not playing status
                    self.delegate?.finishPlaying()
                    
                } else {
                    self.slider.maximumTrackTintColor = .systemGray6//right side
                    self.slider.minimumTrackTintColor = .gray //left side
                }
                self.leftLabel.text = self.getTimeTrack(time: audioPosition.current)
                self.rightLabel.text = self.getTimeTrack(time: audioPosition.durationTime - audioPosition.current)
            }
        }
    }
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

    func getTimeTrack(time: Double) -> String {
        
        let secondString = String(format: "%02d", Int(time)%60)
        let minuteString = String(format: "%02d", Int(time)/60)
        return "\(minuteString):\(secondString)"
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
        
        if let music = detailViewModel?.music {
            AudioHelper.shared.setNowPlayingInfo(music: music)
        }
    }
}
