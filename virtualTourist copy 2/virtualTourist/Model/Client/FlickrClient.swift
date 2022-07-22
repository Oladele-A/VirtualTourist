//
//  FlickrClient.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/26/22.
//

import Foundation

class FlickrClient{
    static let apiKey = "13ea729b0c969d814cb7aede045a06b3"
    static let secret = "0ad300694eaa71ed"
    
    enum EndPoints{
        static let flickrBaseUrl = "https://www.flickr.com/services/rest/?method="
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        static let downloadImageBase = "https://live.staticflickr.com/"
        
        case flickrPhotoSearch(Double, Double)
       
        
        var stringValue: String{
            switch self {
            case .flickrPhotoSearch(let lat, let lon):
                return EndPoints.flickrBaseUrl + "flickr.photos.search" + EndPoints.apiKeyParam + "&lat=\(lat)&lon=\(lon)&per_page=3&page=\(Int.random(in: 1...10))&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func flickrPhotoSearch(lat: Double, lon: Double, completionHandler:@escaping (PhotoSearchResponse?, Error?)->Void){
        taskForGetRequest(url: EndPoints.flickrPhotoSearch(lat, lon).url, response: PhotoSearchResponse.self) { response, error in
            if let response = response {
                completionHandler(response.self, nil)
            }else{
                completionHandler(nil, error)
            }
        }
    }
    
    class func getPhotoImage(imageURL:URL, completionHandler:@escaping (Data?, Error?)->Void){
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        }
        task.resume()
        
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler:@escaping (ResponseType?, Error?)->Void){
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            }catch{
                print(error)
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
}
