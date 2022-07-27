//
//  ViewController+TableViewDataSourceDelegate.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/20.
//
import UIKit

//MARK: TableViewDataSource and Delegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return musicData?.resultCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SongCell
        if let music = musicData?.results[indexPath.row], let imageUrl = music.artworkUrl100, let price = music.trackPrice {
            cell.musicImage.loadPreviewUrl(imageUrl)
            cell.musicNameLabel.text = music.trackName
            cell.albulmNameLabel.text = music.collectionName
            cell.priceButton.setTitle("$\(price)", for: .normal)
            //cell.textLabel?.text = music.artistName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        guard let music = musicData?.results[indexPath.row] else { return }
        
        self.indexPath = indexPath
        
        currentPlayLabel.text = " " + (music.trackName ?? "")
        
        guard let previewUrl = music.previewUrl, let imageUrl = music.artworkUrl100 else {
            //TODO: handler when there is no previewURL (that means cannot play the music)
            return
        }
        
        AudioHelper.shared.status = .playing
        AudioHelper.shared.playMusic(with: previewUrl)
        AudioHelper.shared.setNowPlayingInfo(music: music)
        playButton.value.setImage(AudioHelper.shared.getPlayStatusImage(), for: .normal)
        imageView.loadPreviewUrl(imageUrl)
        floatingPlayView.alpha = 1
    }
}

extension ViewController: PlayAudioButtonDelegate {
    
    func didUpdatePlayButton() {
        playButton.value.setImage(AudioHelper.shared.getPlayStatusImage(), for: .normal)
    }
    func finishPlaying() {
        playNext()
    }
    
    @objc func playPressByFloatView(sender: UIButton) {
        
        AudioHelper.shared.status = AudioHelper.shared.status == .playing ? .pause : .playing
        
        playButton.value.setImage(AudioHelper.shared.getPlayStatusImage(), for: .normal)
        
        let _ = AudioHelper.shared.status == .playing ? AudioHelper.shared.playMusic() : AudioHelper.shared.pauseMusic()
        
    }
    
    @objc func playNext() {
        
        guard let indexPath = indexPath else { return }
        let IndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        self.indexPath = IndexPath
        
        guard let addedIndexPath = self.indexPath, let music = musicData?.results[addedIndexPath.row] else { return }
        currentPlayLabel.text = " " + (music.trackName ?? "")
        
        guard let previewUrl = music.previewUrl, let imageUrl = music.artworkUrl100 else {
            //TODO: handler when there is no previewURL (that means cannot play the music)
            return
        }
        
        AudioHelper.shared.status = .playing
        AudioHelper.shared.playMusic(with: previewUrl)
        AudioHelper.shared.setNowPlayingInfo(music: music)
        playButton.value.setImage(AudioHelper.shared.getPlayStatusImage(), for: .normal)
        imageView.loadPreviewUrl(imageUrl)
        floatingPlayView.alpha = 1
    }
}


