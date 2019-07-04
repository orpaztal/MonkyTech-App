//
//  GiphyManager.swift
//  codableApp
//
//  Created by Or paz tal on 03/07/2019.
//  Copyright © 2019 Or paz tal. All rights reserved.
//

import UIKit
import Foundation

let apiKey = "zWCZkAM7y1LeBM1nLDxZ8TJKx3xWaKYS"
let temp = "ryan+gosling&api_key=zWCZkAM7y1LeBM1nLDxZ8TJKx3xWaKYS&limit=5" //TODO - DELETE
let searchPrefix = "https://api.giphy.com/v1/gifs/search"
let limit = "30"

class GiphyManager {

    func giphySearchQuery(query: String, page: Int = 1, completion : @escaping (_ results: SearchResultsMetaData?, _ error: NSError?) -> Void) {
    
        guard let searchURL = getSearchQueryUrl(query, page: page) else {
            let APIError = NSError(domain: "GiphySearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "Could Not Generate URL From Query"])
            completion(nil, APIError)
            return
        }
        
        URLSession.shared.dataTask(with: searchURL) { data, response, error in
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(SearchResultsMetaData.self, from: data)
                    OperationQueue.main.addOperation({
                        completion(res, nil)
                    })
                    
                } catch let error {
                    print(error) //TODO - DELETE
                    
                    let APIError = NSError(domain: "GiphySearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: error.localizedDescription])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    
                }
            } else if let error = error {
                print(error)
            }
            }.resume()
    }
    
    func getSearchQueryUrl(_ query: String, page: Int = 0) -> URL? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let urlString = "\(searchPrefix)?q=\(encodedQuery)&api_key=\(apiKey)&offset=\(page)&limit=\(limit)"
        return URL(string: urlString)
    }
}
