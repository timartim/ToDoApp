import XCTest
import CocoaLumberjack
import CocoaLumberjackSwift

final class dataTaskTest: XCTestCase {

    override func setUpWithError() throws {
        DDLog.add(DDOSLogger.sharedInstance)
    }

    override func tearDownWithError() throws {
        DDLog.removeAllLoggers()
    }

    func testSuccessfulRequest() async throws {
        let urlRequest = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        do {
            let (data, response) = try await URLSession.shared.dataTask(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                XCTFail("Response was not an HTTPURLResponse")
                return
            }

            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertNotNil(data)
            DDLogInfo("testSuccessfulRequest passed")
        } catch {
            XCTFail("Request failed with error: \(error)")
        }
    }

    func testRequestWithError() async throws {
        let urlRequest = URLRequest(url: URL(string: "https://invalid.url")!)
        do {
            let _ = try await URLSession.shared.dataTask(for: urlRequest)
            XCTFail("Request should have failed")
        } catch {
            DDLogError("Request failed as expected with error: \(error)")
        }
    }

    func testCancelledRequest() async throws {
        let urlRequest = URLRequest(url: URL(string: "https://httpbin.org/delay/5")!)
        let task = Task {
            do {
                let _ = try await URLSession.shared.dataTask(for: urlRequest)
                XCTFail("Request should have been cancelled")
            } catch {
                XCTAssertEqual((error as NSError).code, NSUserCancelledError)
                DDLogError("Request was cancelled as expected with error: \(error)")
            }
        }
        task.cancel()
        await task.value
    }

    func testConcurrentRequests() async throws {
        let urlRequest1 = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        let urlRequest2 = URLRequest(url: URL(string: "https://httpbin.org/headers")!)
        let urlRequest3 = URLRequest(url: URL(string: "https://httpbin.org/ip")!)
        async let (data1, response1) = URLSession.shared.dataTask(for: urlRequest1)
        async let (data2, response2) = URLSession.shared.dataTask(for: urlRequest2)
        async let (data3, response3) = URLSession.shared.dataTask(for: urlRequest3)

        do {
            let results = try await [data1, data2, data3]
            for (index, data) in results.enumerated() {
                XCTAssertNotNil(data)
                DDLogInfo("Concurrent request \(index + 1) completed successfully")
            }
        } catch {
            XCTFail("Concurrent requests failed with error: \(error)")
        }
    }
}

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
            DDLogInfo("Task cancelled sucsessfully")
        }
    }
}
extension CheckedContinuation {
    var isResumed: Bool {
        return Mirror(reflecting: self).children.contains { $0.label == "resumed" }
    }
}

