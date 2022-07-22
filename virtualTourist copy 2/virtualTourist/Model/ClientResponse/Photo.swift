//
//  Photo.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/28/22.
//

import Foundation

struct Photo: Codable{
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey{
        case id
        case owner
        case secret
        case server
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
