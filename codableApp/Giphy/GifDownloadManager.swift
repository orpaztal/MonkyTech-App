//
//  GifDownloadManager.swift
//  codableApp
//
//  Created by Or paz tal on 03/07/2019.
//  Copyright © 2019 Or paz tal. All rights reserved.
//

import UIKit

// this class will create a singleton instance and have NSCache instance to cache the images that have been downloaded

typealias GipDownloadHandler = (_ image: UIImage?, _ url: URL, _ indexPath: IndexPath?, _ error: Error?) -> Void

final class GifDownloadManager {
   
    static let shared = GifDownloadManager()
    private var completionHandler: GipDownloadHandler?
  
    lazy var gifDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "giphyDownloadqueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
  
    let imageCache = NSCache<NSString, UIImage>()
  
    private init () {}
    
    func downloadImage(_ gif: ItemMetaData, indexPath: IndexPath?, size: String = "m", handler: @escaping GipDownloadHandler) {
        self.completionHandler = handler

        guard let url = URL(string: gif.images?.fixed_height?.url ?? "") else {
            return
        }
       
        // check for cached image (by its url), if exist then returns the cached image
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            print("Returned cached gif for \(url)")
            self.completionHandler?(cachedImage, url, indexPath, nil)
        }
        
        // check if there is a download task that is currently downloading this image
        else {
            if let operations = (gifDownloadQueue.operations as? [PGOperation])?.filter({$0.gifUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
                print("Increased the priority for \(url)")
                operation.queuePriority = .veryHigh
            }
            
            // creats a new task to download the image
            else {
                print("Created a new task for \(url)")
                let operation = PGOperation(url: url, indexPath: indexPath)
                if indexPath != nil {
                    operation.queuePriority = .high
                }
                
                // cashing the new image we downloaded
                operation.downloadHandler = { (image, url, indexPath, error) in
                    if let newImage = image {
                        self.imageCache.setObject(newImage, forKey: url.absoluteString as NSString)
                    }
                    self.completionHandler?(image, url, indexPath, error)
                }
                gifDownloadQueue.addOperation(operation)
            }
        }
    }
    
    // Reduce the priority of the network operation in case the user scrolls and an image is no longer visible.
//    func slowDownImageDownloadTaskfor (_ gif: ItemMetaData) {
//        guard let url = URL(string: gif.url) else {
//            return
//        }
//      
//        if let operations = (gifDownloadQueue.operations as? [PGOperation])?.filter({$0.gifUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
//            print("Reduce the priority for \(url)")
//            operation.queuePriority = .low
//        }
//    }
    
    func cancelAll() {
        gifDownloadQueue.cancelAllOperations()
    }
    
}


