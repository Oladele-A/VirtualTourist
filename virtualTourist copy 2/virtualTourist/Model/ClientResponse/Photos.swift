//
//  Photos.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/28/22.
//

import Foundation

struct Photos:Codable{
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [Photo]
    
    enum CodingKeys: String, CodingKey{
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}
