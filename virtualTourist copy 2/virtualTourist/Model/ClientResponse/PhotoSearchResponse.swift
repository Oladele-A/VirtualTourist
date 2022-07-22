//
//  SearchImageResponse.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/28/22.
//

import Foundation

struct PhotoSearchResponse: Codable{
    let photos: Photos
    let status: String
    
    enum CodingKeys: String, CodingKey{
        case photos
        case status = "stat"
    }
}
