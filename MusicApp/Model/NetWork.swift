//
//  NetWork.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import Foundation

class Network {
    
    static let shared = Network()
    
    func fetchData(term: String, entity: String?, completionHandler: @escaping (Result<MusicData, FetchError>) -> Void) {
        
        let string = entity == nil ? "https://itunes.apple.com/search?term=\(term)" : "https://itunes.apple.com/search?term=\(term)&entity=\(entity!)"
        //&entity=allArtist&attribute=allArtistTerm
        if let urlStr = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlStr){
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(MusicData.self, from: data)
                        
                        if response.results.isEmpty {
                            completionHandler(.failure(FetchError.noData))
                        } else {
                            completionHandler(.success(response))
                        }
                    }
                    catch {
                        print("error",error)
                        completionHandler(.failure(FetchError.failledToDecode))
                    }
                } else {
                    completionHandler(.failure(FetchError.parsingError))
                }
            }.resume()
        }
    }
}



enum FetchError: Error {
    case parsingError
    case failledToDecode
    case noData
}


struct MusicData: Decodable {
    let resultCount: Int?
    let results: [Music]
}
struct Music: Decodable {
    let artistId: Int?
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let trackViewUrl: URL?
    let collecitonViewUrl: URL?
    let previewUrl: URL?
    let artworkUrl100: String?
    let artworkUrl500: String?
    let trackPrice: Double?
}
