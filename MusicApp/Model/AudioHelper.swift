//
//  AudioHelper.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//
import UIKit
import Foundation
import AVFoundation
import MediaPlayer//FOR MPREMOTECOMMANDCENTER



class AudioHelper: NSObject, ObservableObject {
    
    
    @Published var status: Box<PlayMode> = Box(.pause)
    //update playing track of slider and time
    var audioPosition: Box<AudioPosition?> = Box(nil)
    var audioPlayerObserver: Any?
    static let shared = AudioHelper()
    
    var audioPlayer = AVPlayer(playerItem: nil)
    var audioSession = AVAudioSession()
    
    let mpVolumeView = MPVolumeView()
    //MARK: control Command Center
    let center = MPRemoteCommandCenter.shared()
    let nowPlayingCenter = MPNowPlayingInfoCenter.default()
    
    deinit {
        
        if let observer = audioPlayerObserver {
            audioPlayer.removeTimeObserver(observer)
        }
        
        audioPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: nil)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
//                print("status \(status)")
            } else {
                status = .unknown
            }
            //TODO:when player is playing other song does not chang the button status
            switch status {
            case .readyToPlay:
                self.playMusic()
                self.status = Box(.playing)
                
            case .failed:
                print("failed to play")
                self.status = Box(.cannotPlay)
            case .unknown:
                print("unknown error occurred")
                self.status = Box(.cannotPlay)
            @unknown default:
                print("err")
            }
        }
    }
    
    
    
    
    
    func addTimeObserver() {
        self.audioPlayerObserver = self.audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main, using: { [weak self] CMTime in
            guard let self = self else { return }
            if let currentItem = self.audioPlayer.currentItem {
                let loadRanges = currentItem.seekableTimeRanges
                guard let range = loadRanges.first?.timeRangeValue, range.start.timescale > 0,range.duration.timescale > 0 else { return }
                let duration = (CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration));
                
                if !range.duration.flags.contains(.valid) || 0 >= duration{
                    return
                }
                let currentTime = currentItem.currentTime()
                self.audioPosition.value = AudioPosition(current: CMTimeGetSeconds(currentTime),durationTime: duration)
            }
        })
        
    }
    func playMusic(with url: URL) {
        
        
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        
        DispatchQueue.main.async {
            self.audioPlayer.replaceCurrentItem(with: item)
            self.audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
            
            self.addTimeObserver()
            self.audioPlayer.allowsExternalPlayback = true
            self.audioPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
        }
    }
    
    
    func handleAudioPLay(stringUrl: String) {
        if let url = URL(string: stringUrl) {
            
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
            
            DispatchQueue.main.async {
                self.audioPlayer.replaceCurrentItem(with: item)
                self.audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
                self.audioPlayer.allowsExternalPlayback = true
                self.audioPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
            }
        }
    }
    
    func playMusic() {
        audioPlayer.volume = 1
        audioPlayer.play()
        NotificationCenter.default.addObserver(self, selector: #selector(handlerAVSession(notification:)), name: AVAudioSession.interruptionNotification ,object: audioSession)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlerAVSession(notification:)), name: AVAudioSession.silenceSecondaryAudioHintNotification, object: audioSession) //other music is playing
        
        NotificationCenter.default.addObserver(self, selector: #selector(play(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.audioPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.play(notification:)),
                                               name: .AVPlayerItemFailedToPlayToEndTime, object: self.audioPlayer.currentItem)
//        status = .playing
    }
    
    func pauseMusic() {
        audioPlayer.pause()
        status = Box(.pause)
    }
    
    
    func getPlayStatusImage() -> UIImage? {
        var image: UIImage?
        status.bind { mode in
            switch mode {
            case .pause :
                image = UIImage(systemName: "play.fill")
            case .playing:
                image = UIImage(systemName: "pause.fill")
            case .cannotPlay:
                image = UIImage.init(systemName: "rays")
            case .endPlaying:
                image = UIImage.init(systemName: "play.fill")
                
            }
            print("image \(image)")
        }
        
        
        return image
//        return status == .playing ? UIImage.init(systemName: "pause.fill") : UIImage.init(systemName: "play.fill")
    }
    func authSessionAccess() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
          print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
    }
    
    func setNowPlayingInfo(music: Music) {
        
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = music.trackName//"YourMusicTitle"
        info[MPMediaItemPropertyArtist] = music.artistName//"YourMusicArtist"
        info[MPMediaItemPropertyAlbumTitle] = music.collectionName
        info[MPMediaItemPropertyPlaybackDuration] = audioPlayer.currentItem?.asset.duration.seconds
        info[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime().seconds
       
        DispatchQueue.global().async { [weak self] in
            
            if let artworkUrl = URL(string: music.artworkUrl100 ?? ""),
              let artworkData = try? Data(contentsOf: artworkUrl),
              let artworkImage = UIImage(data: artworkData) {
                if var currentInfo = self?.nowPlayingCenter.nowPlayingInfo {
                    currentInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
                    self?.nowPlayingCenter.nowPlayingInfo = currentInfo
                }
            }
        }
                
        AudioHelper.shared.nowPlayingCenter.nowPlayingInfo = info
    }
}


extension AudioHelper: AVAudioPlayerDelegate {
    
    
}

enum PlayMode { //TODO: need handler of status of not playing and cannot play
    case playing
    case pause
    case endPlaying
    case cannotPlay
    
}

class AudioPosition {
    let current: Double
    let durationTime: Double
    
    init(current: Double, durationTime: Double) {
        self.current = current
        self.durationTime = durationTime
    }
}



extension AudioHelper {
    @objc func play(notification: Notification) {
        
        switch notification.name {
        case .AVPlayerItemDidPlayToEndTime:
            print("you've played  \(notification.object)")
            
            
        case .AVPlayerItemFailedToPlayToEndTime:
            let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
            
            print("cannot play music \(error)")
        
        default:
            break
        }
    }
    
    @objc func handlerAVSession(notification: Notification) {
        
        print("diuiwehihdihewi\(notification.name)")
        switch notification.name {
        case AVAudioSession.interruptionNotification:
            //MARK: handler when music was interuptted accidently
            print("ekk")
            guard let info = notification.userInfo,
                    let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                        return
                }
                if type == .began {
                    // Interruption began, take appropriate actions (save state, update user interface)
                    print("!!!!please stop your music1")
                    status.value = .pause
                    
                }
                else if type == .ended {
                    guard let optionsValue =
                        info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                            return
                    }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        // Interruption Ended - playback should resume
                    }
                }
        case AVAudioSession.silenceSecondaryAudioHintNotification:
            print("!!!!please stop your music22")
            status.value = .pause
            
            guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
                  let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
                        return
                }
             
                if type == .begin {
                    // Other app audio started playing - mute secondary audio
                    print(" Other app audio started playing - mute secondary audio")
//                    status = .pause
                } else {
                    // Other app audio stopped playing - restart secondary audio
                    print("restart")
//                    status = .playing
                }
        default:
            print("???")
        }
    }
    
    
}


