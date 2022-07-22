//
//  PlayAudioViewController+setupRemoteCommand.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/20.
//

import Foundation
import MediaPlayer

extension PlayAudioViewController {
    
    
    func setupRemoteCommand() {
        
        let center = AudioHelper.shared.center
        // Set the closures to process user's activites.
        
        center.playCommand.isEnabled = true
        center.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            AudioHelper.shared.playMusic()
           
               
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPNowPlayingInfoPropertyElapsedPlaybackTime:  AudioHelper.shared.audioPlayer.currentTime().seconds,
                MPMediaItemPropertyPlaybackDuration: AudioHelper.shared.audioPlayer.currentTime().seconds
            ]
            return .success
        }
        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            AudioHelper.shared.pauseMusic()
            return .success
        }
        center.changePlaybackPositionCommand.isEnabled = true
        center.changePlaybackPositionCommand.addTarget { event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent, let durationTime = AudioHelper.shared.audioPosition.value?.durationTime else { return .commandFailed }
            
//            let percent = Float64(Float(positionEvent.positionTime)/Float(durationTime))
//
//            let targetTime:CMTime = CMTimeMakeWithSeconds(percent, preferredTimescale: Int32(NSEC_PER_SEC))
            guard let totalTime = AudioHelper.shared.audioPlayer.currentItem?.asset.duration else { return .commandFailed }
            
            let targetTime = CMTimeMake(value: (totalTime.value * Int64(positionEvent.positionTime))/Int64(CMTimeGetSeconds(totalTime)), timescale: totalTime.timescale)
            AudioHelper.shared.audioPlayer.seek(to: targetTime)
            
            print("rate \(AudioHelper.shared.audioPlayer.rate) ")
            if AudioHelper.shared.audioPlayer.rate == 0
            {
                AudioHelper.shared.audioPlayer.play()
            }
            
            
            return .success
        }
       
        
        //diabled the function to play previous track
        center.previousTrackCommand.isEnabled = true
        //diabled the function to play next track
        center.nextTrackCommand.isEnabled = true
        
        //
        center.skipForwardCommand.isEnabled = true
        center.skipForwardCommand.preferredIntervals = [NSNumber(100)]
        center.skipForwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            
            //TODO: command center did not update the slider
            
            AudioHelper.shared.audioPlayer.seek(to: AudioHelper.shared.audioPlayer.currentTime() + CMTime(seconds: 10, preferredTimescale: 1000), completionHandler: { success in
                if success {
                   
                    print("seek time success.")
                } else {
                    print("seek time failure.")
                }
            })
            return .success
        }
        center.skipBackwardCommand.isEnabled = true
        center.skipBackwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            AudioHelper.shared.audioPlayer.seek(to: AudioHelper.shared.audioPlayer.currentTime() - CMTime(seconds: 10, preferredTimescale: 1000), completionHandler: { success in
                if success {
                    print("seek time success.")
                } else {
                    print("seek time failure.")
                }
            })
            return .success
        }
    }
    
    @objc func playCommand(_ remoteCommand: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        return .success
    }
}
