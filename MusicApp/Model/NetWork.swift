//
//  NetWork.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import Foundation

class Network {
    
    static let shared = Network()
    
    
    func fetchDatawithAsyn(term: String, entity: String?) async throws ->  MusicData {
        let string = entity == nil ? "https://itunes.apple.com/search?term=\(term)" : "https://itunes.apple.com/search?term=\(term)&entity=\(entity!)"
        //&entity=allArtist&attribute=allArtistTerm
        guard let urlStr = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlStr) else {
            throw FetchError.notValidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.failedToRequest }
        do {
            let result = try  JSONDecoder().decode(MusicData.self, from: data)
            if result.results.isEmpty {
                throw FetchError.noData
            } else {
                return result
            }
        } catch {
            throw FetchError.failledToDecode
            
        }
    }
    
    
    func fetchData(term: String, entity: String?, completionHandler: @escaping (Result<MusicData, FetchError>) -> Void) {
        
        let string = entity == nil ? "https://itunes.apple.com/search?term=\(term)" : "https://itunes.apple.com/search?term=\(term)&entity=\(entity!)"
        //&entity=allArtist&attribute=allArtistTerm
        if let urlStr = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlStr) {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("data \(data) \n res\(response)  err\(error.debugDescription) \(error?.localizedDescription)")
                
                
                if (response as? HTTPURLResponse)?.statusCode != 200 {
//                    print("data \(data) \n res\(response)  err\(error)")
                    completionHandler(.failure(FetchError.failedToRequest))
                }
                
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
                    if let description = error?.localizedDescription, description == "The Internet connection appears to be offline." {
                        completionHandler(.failure(FetchError.offLine))
                    }
                    
                   
                }
            }.resume()
        }
    }
}



enum FetchError: Error {
    case parsingError
    case failledToDecode
    case noData
    case failedToRequest
    case notValidUrl
    case offLine
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
