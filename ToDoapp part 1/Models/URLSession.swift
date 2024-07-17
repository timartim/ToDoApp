//
//  URLSession.swift
//  ToDoapp part 1
//
//  Created by Артемий on 16.07.2024.
//

import Foundation
extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                let task = self.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data = data, let response = response else {
                        let unknownError = NSError(
                            domain: NSURLErrorDomain,
                            code: NSURLErrorUnknown,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]
                        )
                        continuation.resume(throwing: unknownError)
                        return
                    }
                    
                    continuation.resume(returning: (data, response))
                }
                task.resume()
                
            }
        } onCancel: {
            
        }
    }
}
extension CheckedContinuation {
    var isResumed: Bool {
        return Mirror(reflecting: self).children.contains { $0.label == "resumed" }
    }
}
