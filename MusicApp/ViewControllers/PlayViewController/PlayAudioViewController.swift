//
//  PlayAudioViewController.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import UIKit
import MediaPlayer
protocol PlayAudioButtonDelegate{
    func didUpdatePlayButton()
    func finishPlaying()
}

class PlayAudioViewController: UIViewController {

    lazy var imageView: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "music.note"))
        image.contentMode = .scaleAspectFill//.scaleAspectFit//.scaleAspectFit//.scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        if let music = detailViewModel?.music, let url = music.artworkUrl100  {
            image.loadPreviewUrl(url)
            albumLabel.text = music.collectionName
            songLabel.text = music.trackName
        }
        return image
    }()
    let leftLabel = UILabel().setNormalLabel(textColor: .systemGray2, size: 9)
    let rightLabel = UILabel().setNormalLabel(textColor: .systemGray2, size: 9)
    let albumLabel = UILabel().setNormalLabel(textColor: .black, size: 13)
    let songLabel = UILabel().setSemiboldLabel(textColor: .black)
    
    var delegate: PlayAudioButtonDelegate?
    let playButton = UIButton().playButton()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "goforward.10"), for: .normal)
        return button
    }()
    
    let prevButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "gobackward.10"), for: .normal)
        return button
    }()
    
    var slider: UISlider = {
        let slider = UISlider()
        slider.maximumTrackTintColor = .systemGray6//right side
        slider.minimumTrackTintColor = .gray //left side
        slider.thumbTintColor = .clear
        return slider
    }()
        
    
    
    var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.maximumTrackTintColor = .systemGray6//right side
        slider.minimumTrackTintColor = .gray //left side
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.maximumValueImage = UIImage(systemName: "speaker.wave.2")
        slider.minimumValueImage = UIImage(systemName: "speaker.wave.1")
        let originVolume = AudioHelper.shared.audioSession.outputVolume
        slider.value = originVolume
        return slider
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [prevButton, playButton, nextButton])
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        return stack
    }()
    var detailViewModel: DetailViewModel?
    
    init(detailViewModel: DetailViewModel) {
        self.detailViewModel = detailViewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupView()
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
        
        setupRemoteCommand()
    }
    
    private func getTimeTrack(time: Double) -> String {
        
        let secondString = String(format: "%02d", Int(time)%60)
        let minuteString = String(format: "%02d", Int(time)/60)
        return "\(minuteString):\(secondString)"
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: view.frame.midX-100, y: 100, width: 200, height: 200)
        
        albumLabel.frame = CGRect(x: view.frame.midX-150, y: 350, width: 300, height: 30)
        songLabel.frame = CGRect(x: view.frame.midX-100, y: 390, width: 200, height: 20)
        slider.frame = CGRect(x: view.frame.midX-150, y: 100+300+30, width: 300, height: 25)
        leftLabel.frame = CGRect(x: view.frame.midX-150, y: 100+300+30+25+1, width: 30, height: 10)
        rightLabel.frame = CGRect(x: view.frame.midX-150+300-30, y: 100+300+30+25+1, width: 30, height: 10)
        stackView.frame = CGRect(x: view.frame.midX-150, y: 100+300+30+55, width: 300, height: 60)
        volumeSlider.frame = CGRect(x: view.frame.midX-150, y: 485+60+30, width: 300, height: 35)
    }
    
    @objc func toggletPlay() {
        
         AudioHelper.shared.status = AudioHelper.shared.status == .playing ? .pause : .playing
         
         playButton.setImage(AudioHelper.shared.getPlayStatusImage(), for: .normal)
         
         let _ = AudioHelper.shared.status == .playing ? AudioHelper.shared.playMusic() : AudioHelper.shared.pauseMusic()
        
        delegate?.didUpdatePlayButton()
    }
    
    
    @objc func volumeAdjust(sender: UISlider) {
        
        volumeSlider = (AudioHelper.shared.mpVolumeView.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first) as! UISlider
        
        volumeSlider.setValue(sender.value, animated: false)
    }
    
}
