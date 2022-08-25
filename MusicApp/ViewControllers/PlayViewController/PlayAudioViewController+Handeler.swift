//
//  PlayAudioViewController+Handeler.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import MediaPlayer

 let viewWidth = UIScreen.main.bounds.width
 let viewHeight = UIScreen.main.bounds.height

extension PlayAudioViewController {
    func setupView() {
        
//        view.addSubview(albumLabel)
//        view.addSubview(songLabel)
//        view.addSubview(imageView)
//        view.addSubview(stackView)
//        view.backgroundColor = .white
//        view.addSubview(slider)
//        view.addSubview(volumeSlider)
//        view.addSubview(leftLabel)
//        view.addSubview(rightLabel)
        view.backgroundColor = .white
        let labelStack = UIStackView(arrangedSubviews: [leftLabel, rightLabel])
        labelStack.distribution = .equalSpacing
        let sliderStack = UIStackView(arrangedSubviews: [slider, labelStack])
        sliderStack.axis = .vertical
        sliderStack.spacing = 1
        let mediumStack = UIStackView(arrangedSubviews: [imageView, albumLabel, songLabel, sliderStack, stackView, volumeSlider])
        mediumStack.axis = .vertical
        mediumStack.distribution = .equalSpacing
        mediumStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mediumStack)
        //TODO: force layout to vertical not allowed horizontal
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: viewWidth / 3 * 2),
            imageView.heightAnchor.constraint(equalToConstant: viewWidth / 3 * 2),
//            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mediumStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            mediumStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            mediumStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            mediumStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
//
        
        slider.addTarget(self, action: #selector(musicProgressAdjust(_:)), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(volumeAdjust), for: .valueChanged)
        prevButton.addTarget(self, action: #selector(prevTenSeconds), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTenSeconds), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(toggletPlay), for: .touchUpInside)
    }

    
    @objc func nextTenSeconds() {
        
        let cmTime = AudioHelper.shared.audioPlayer.currentTime() + CMTime(seconds: 10, preferredTimescale: 1000)
        AudioHelper.shared.audioPlayer.seek(to: cmTime, completionHandler: { success in
            print(success == true ? "seek time success." : "seek time failure.")
        })
    }
    
    @objc func prevTenSeconds() {
        
        let cmTime = AudioHelper.shared.audioPlayer.currentTime() - CMTime(seconds: 10, preferredTimescale: 1000)
        AudioHelper.shared.audioPlayer.seek(to: cmTime, completionHandler: { success in
            
            print(success == true ? "seek time success." : "seek time failure.")
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
