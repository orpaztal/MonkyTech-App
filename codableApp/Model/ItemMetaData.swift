//
//  GifMetaData.swift
//  codableApp
//
//  Created by Or paz tal on 02/07/2019.
//  Copyright © 2019 Or paz tal. All rights reserved.
//

import UIKit

struct ItemMetaData: Codable { 
    let type: String
    let id: String
    let url: String
    let title : String?
    let images : ImagesMetaData?

//    let slug : String?
//    let bitly_gif_url : String?
//    let bitly_url : String?
//    let embed_url : String?
//    let username : String?
//    let source : String?
//    let rating : String?
//    let content_url : String?
//    let source_tld : String?
//    let source_post_url : String?
//    let is_sticker : Int?
//    let import_datetime : String?
//    let trending_datetime : String?
//    let analytics : Analytics?
}

struct ImagesMetaData: Codable {
    let fixed_height : FixedHeightMetaData?
}

struct FixedHeightMetaData: Codable {
    let url : String?
    let width : String?
    let height : String?
    let size : String?
}

