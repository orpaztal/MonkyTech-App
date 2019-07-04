//
//  PGOperation.swift
//  codableApp
//
//  Created by Or paz tal on 03/07/2019.
//  Copyright © 2019 Or paz tal. All rights reserved.
//

import UIKit
import Foundation

class PGOperation: Operation {

    var downloadHandler: GipDownloadHandler?
    var gifUrl: URL!
    private var indexPath: IndexPath?
    
    override var isAsynchronous: Bool {
        get {
            return  true
        }
    }
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
    required init (url: URL, indexPath: IndexPath?) {
        self.gifUrl = url
        self.indexPath = indexPath
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
       
        self.executing(true)
        //Asynchronous logic (eg: n/w calls) with callback
        self.downloadImageFromUrl()
    }
    
    func downloadImageFromUrl() {
        let newSession = URLSession.shared
        let downloadTask = newSession.dataTask(with: self.gifUrl) { (data, urlResponse, error) in
            if let data = data {
                let image = UIImage(data: data)
                self.downloadHandler?(image, self.gifUrl, self.indexPath, error)
            }
//            self.finish(true)
            self.executing(false)
        }
        downloadTask.resume()

        //        if let url = URL(string: "https://media1.giphy.com/media/cZ7rmKfFYOvYI/200.gif") {
        //            //"https://media1.giphy.com/media/cZ7rmKfFYOvYI/200.gif" data.images?.fixed_height?.url ?? ""
        //            DispatchQueue.global().async { [weak self] in
        //                if let data = try? Data(contentsOf: url) {
        //                    if let image = UIImage(data: data) {
        //                        DispatchQueue.main.async() {
        //                            self?.cellImageView.image = image
        //                        }
        //                    }
        //                }
        //            }
        //        }
        

    }
}
