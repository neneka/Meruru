//
//  MirakurunApi.swift
//  Meruru
//
//  Created by castaneai on 2019/04/06.
//  Copyright © 2019 castaneai. All rights reserved.
//

import Foundation
import Alamofire

public struct Status: Codable {
    let version: String?
}

public struct Service: Codable {
    let id: Int
    let serviceId: Int
    let networkId: Int
    let name: String
    let channel: Channel
}

public struct Channel: Codable {
    let type: String
    let channel: String
}

public struct Program : Codable {
    let name: String?
    let startAt: Int64
    let duration: Int64
    let serviceId: Int
}

public class MirakurunAPI {
    
    init(baseURL: URL, user: String? = nil, pass: String? = nil) {
        self.baseURL = baseURL
        self.user = user
        self.pass = pass
        self.authorization = (user != nil && pass != nil) ? .authorization(username: user!, password: pass!) : nil
    }
    private let baseURL: URL
    private let user: String?
    private let pass: String?
    private let authorization: HTTPHeader?
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    public func fetchPrograms(service: Service, completion: @escaping (Result<[Program]>) -> Void) {
        let url = self.baseURL.appendingPathComponent("programs")
        let params: Parameters = [
            "serviceId": service.serviceId,
        ]
        AF.request(url, parameters: params, encoding: URLEncoding(destination: .queryString), headers: self.authorization != nil ? [self.authorization!] : [])
            .responseDecodable { response in
            completion(response.result)
        }
    }
    
    public func getStreamURL(service: Service) -> URL {
        var absoluteUrl = self.baseURL
            .appendingPathComponent("channels")
            .appendingPathComponent(service.channel.type)
            .appendingPathComponent(service.channel.channel)
            .appendingPathComponent("services")
            .appendingPathComponent(String(service.serviceId))
            .appendingPathComponent("stream").absoluteString
        if self.user != nil && self.pass != nil, let range = absoluteUrl.range(of: "//") {
            absoluteUrl.replaceSubrange(range, with: "//\(self.user!):\(self.pass!)@")
        }
        return URL(string: absoluteUrl)!
    }
    
    public func fetchStatus(completion: @escaping (Result<Status>) -> Void) {
        let url = self.baseURL.appendingPathComponent("status")
        AF.request(url, headers: self.authorization != nil ? [self.authorization!] : []).responseDecodable { response in
            completion(response.result)
        }
    }
    
    public func fetchServices(completion: @escaping (Result<[Service]>) -> Void) {
        let url = self.baseURL.appendingPathComponent("services")
        AF.request(url, headers: self.authorization != nil ? [self.authorization!] : []).responseDecodable { response in
            completion(response.result)
        }
    }
    
}
