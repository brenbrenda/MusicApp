//
//  ViewModel.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/27.
//

import Foundation

class ViewModel {
    
    var musicData: MusicData?
    
    init() {
        musicData = nil
    }
    
    func loadData(term: String, entity: String?) async {
        
        do {
            let res = try await Network.shared.fetchDatawithAsyn(term: term, entity: entity)
            self.musicData = res
            
        } catch {
            print("error \(error)")
        }
        
    }
}
