import Foundation

class CustomSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct TodoListResponse: Codable {
    let list: [TodoItem]
    let revision: Int
}

struct TodoListElementResponse: Codable{
    let element: TodoItem
}

struct DefaultNetworkingService {
    let baseURL = "https://hive.mrdekk.ru/todo"
    func synchronizeItemsWithServer(revision: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/list") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(revision, forHTTPHeaderField: "X-Last-Known-Revision")
        
        do {
            let (responseData, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return false
            }
            return true
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
    
    let session: URLSession
    let token = "Aegnor"
    init() {
        let sessionDelegate = CustomSessionDelegate()
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
    }
    func getListFromServer() async -> ([TodoItem], Int) {
        guard let url = URL(string: "\(baseURL)/list") else {
            print("Invalid URL")
            return ([], 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            print("Responce getting list: \(response)")
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return ([], 0)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let todoListResponse = try decoder.decode(TodoListResponse.self, from: data)
            print("List data: \(todoListResponse)")
            return (todoListResponse.list, todoListResponse.revision)
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return ([], 0)
        }
    }
    func getItemFromServer(id: String) async -> TodoItem? {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let todoListElementResponse = try decoder.decode(TodoListElementResponse.self, from: data)
            
            return todoListElementResponse.element
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    func addItemToServer(todoItem: TodoItem, revision: Int) async -> Bool {
        guard let url = URL(string: "\(baseURL)/list") else {
            print("Invalid URL")
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let todoElement = TodoListElementResponse(element: todoItem)
            let data = try encoder.encode(todoElement)
            request.httpBody = data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Request JSON: \(jsonString)")
                print("Revision: \(revision)")
            }

            let (responseData, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let responseData = String(data: responseData, encoding: .utf8) {
                    print("Server Response: \(responseData)")
                }
                print("Invalid response: \(response)")
                return false
            }
            
            return true
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
    func updateItemOnServer(todoItem: TodoItem, revision: Int) async -> Bool {
        guard let url = URL(string: "\(baseURL)/list/\(todoItem.id)") else {
            print("Invalid URL")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(todoItem)
            request.httpBody = data
            
            let (responseData, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response \(response)")
                return false
            }
            return true
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
    func deleteItemFromServer(id: String, revision: Int) async -> Bool {
        guard let url = URL(string: "\(baseURL)/list/\(id)") else {
            print("Invalid URL")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        do {
            let (responseData, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response \(response)")
                return false
            }
            return true
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }

}
