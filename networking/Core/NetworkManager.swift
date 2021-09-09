//
//  NetworkManager.swift
//  networking
//
//  Created by Denys Nikolaichuk on 02.08.2021.
//

import Foundation

class NetworkManager {
    
    enum HTTPMethod: String {
        case POST
        case PUT
        case GET
        case DELETE
    }
    
    enum APIs: String {
        case posts
        case users
        case comments
    }
    
    enum Headers: String {
        case ContentLengh = "Content-Lengh"
        case ContentType = "Content-Type"
        case Path = "application/json"
    }
    
    private var baseURL = "https://jsonplaceholder.typicode.com/"
    
    func getAll<T: Codable>(chooseApi: APIs, decodingType: T.Type,_ completionHandler: @escaping(T, Error?) -> Void) {
        if let url = URL(string: baseURL + chooseApi.rawValue) {
            URLSession.shared.dataTask(with: url) { data, responce, error in
                if error != nil {
                    print("error in request")
                } else {
                    if let resp = responce as? HTTPURLResponse,
                       resp.statusCode == 200,
                       let responceData = data {
                        guard let posts = try? JSONDecoder().decode(decodingType, from: responceData) else { return }
                        completionHandler(posts, nil)
                    }
                }
            }.resume()
        }
    }
    
    func delete<T:Encodable>(currentId: Int, _ model: T, complitionHandler: @escaping (Error?) -> Void) {
        let sendData = try? JSONEncoder().encode(model)
        guard let url = URL(string: baseURL + APIs.users.rawValue + "/\(currentId)"),
            let data = sendData
        else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.DELETE.rawValue
        request.httpBody = data
        request.setValue("\(data.count)", forHTTPHeaderField: Headers.ContentLengh.rawValue)
        request.setValue(Headers.Path.rawValue, forHTTPHeaderField: Headers.ContentType.rawValue)
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                print("error")
            } else if let resp = response as? HTTPURLResponse,
                resp.statusCode == 200 {
                 complitionHandler(nil)
                }
            }.resume()
    }
    
    func create<T:Codable>(chooseApi: APIs, model: T, decodingType: T.Type, complitionHandler: @escaping (T, Error?) -> Void) {
        let sendData = try? JSONEncoder().encode(model)
        guard let url = URL(string: baseURL + chooseApi.rawValue),
              let data = sendData else { return }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.httpBody = data
        request.setValue("\(data.count)", forHTTPHeaderField: Headers.ContentLengh.rawValue)
        request.setValue(Headers.Path.rawValue, forHTTPHeaderField: Headers.ContentType.rawValue)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                print("error")
            } else if let resp = response as? HTTPURLResponse,
                      resp.statusCode == 201,
                      let responseData = data {
                if let responsePost = try? JSONDecoder().decode(decodingType, from: responseData) {
                    complitionHandler(responsePost, nil)
                }
            }
        }.resume()
    }
    
    func edit<T:Codable>(chooseApi: APIs, currentId: Int, model: T, decodingType: T.Type, complitionHandler: @escaping (T, Error?) -> Void) {
        let sendData = try? JSONEncoder().encode(model)
        guard let url = URL(string: baseURL + chooseApi.rawValue + "/\(currentId)"),
              let data = sendData else { return }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = HTTPMethod.PUT.rawValue
        request.httpBody = data
        request.setValue("\(data.count)", forHTTPHeaderField: Headers.ContentLengh.rawValue)
        request.setValue(Headers.Path.rawValue, forHTTPHeaderField: Headers.ContentType.rawValue)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                print("error")
            } else if let resp = response as? HTTPURLResponse,
                      resp.statusCode == 200,
                      let responseData = data {
                if let responseUser = try? JSONDecoder().decode(decodingType, from: responseData) {
                    complitionHandler(responseUser, nil)
                }
                
            }
        }.resume()
    }
    
    func getAllById<T:Codable>(chooseApi: APIs, nameId: String, currentId: Int, decodingType: T.Type, complitionHandler: @escaping(T?, Error?) -> Void) {
        guard let url = URL(string: baseURL + chooseApi.rawValue) else { return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "\(nameId)", value: "\(currentId)")]
        
        guard let queryURL = components?.url else { return }
        
        URLSession.shared.dataTask(with: queryURL) { data, response, error in
            if error != nil {
                print("error get Post By")
            } else if let resp = response as? HTTPURLResponse,
                      resp.statusCode == 200,
                      let reciveData = data {
                let posts = try? JSONDecoder().decode(decodingType, from: reciveData)
                complitionHandler(posts, nil)
            }
        }.resume()
    }
}
