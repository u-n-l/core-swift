//
//  LocationService.swift
//  core
//
//  Created by Bogdan Simon on 27/01/2021.
//  Copyright © 2021 unl. All rights reserved.
//

public struct LocationService {
    private static let  getRequestMethod: String = "GET";
    private static let  authorizationHeader: String = "Authorization";
    private static let  bearerAuthorization: String = "Bearer ";
    
    public static func callEndpoint(endPoint: String, apiKey: String,  onSuccess: @escaping (Data) -> Void, onFailure: @escaping (Error) -> Void) {
        let url = URL(string: endPoint);
        guard let requestUrl = url else { onFailure(UnlCoreError.httpRequestError(message: "Error: invalid url!")); return; }
        var request = URLRequest(url: requestUrl);
        request.httpMethod = LocationService.getRequestMethod;
        
        request.setValue(LocationService.bearerAuthorization + apiKey, forHTTPHeaderField: LocationService.authorizationHeader);
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                onFailure(error!);
                return;
            }
            guard let data = data else {
                onFailure(UnlCoreError.httpRequestError(message: "Error: did not receive data!"));
                return;
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                onFailure(UnlCoreError.httpRequestError(message: "Error: HTTP request failed!"));
                return;
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                onFailure(UnlCoreError.httpRequestError(message: "Error: could not convert data to JSON object"));
                return;
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject["location"] ?? jsonObject, options: .prettyPrinted) else {
                onFailure(UnlCoreError.httpRequestError(message: "Error: could not convert data to JSON object to pretty JSON data"));
                return;
            }
            
            onSuccess(jsonData);
        }.resume();
    }
}
