# NetworkLibrary

[![UnitTests](https://github.com/Mc231/NetworkLibrary/actions/workflows/unit_tests.yml/badge.svg?branch=master)](https://github.com/Mc231/NetworkLibrary/actions/workflows/unit_tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Simple lightweight implementation that could be used as a network layer, completely covered with unit tests.


# How to use

## Step1 Define Endpoint

Define Endpoint that will describe Request

```swift
enum Endpoint: EndPoint {
    case request
    case requestWithBody
    case requestWithEncodableParameters
    case requestWithParameters
    case requestWithParametersAndHeaders
    case upload
    case formDataRequest
	
    // Path component
    var path: String {
        return "/path1/"
    }
	
    // Method of request
    var httpMethod: NetworkLibrary.HttpMethod {
        return .get
    }
  
    /// Additional headers that is needed
    var headers: NetworkLibrary.HttpHeaders? {
        return ["SomeHeader": "Header"]
    }
	
    /// Task of endpoint
    var task: NetworkLibrary.HttpTask {
    switch self {
    case .request:
        // Simple request with specific content type application/Json is default one
        return .request()
    case .requestWithBody:
        // Request with specific body in case if it is Data it will be used as body otherwise there will be attempt to serialize body using JSONSerialization
        let body: Any = "Test".data(using: .utf8)
        return .requestWithBody(body: body)
    case .requestWithEncodableParameters:
        // Request where encodable model will be used, you can define encodingStrategy of keys like convertToSnakeCase, useDefaultKeys is the standard one
        let encodable: Encodable = SomeModel(field: "Test")
        return .requestWithEncodableParameters(body: encodable, encodingStrategy: .useDefaultKeys)
    case .requestWithParameters:
        /// Request with parameters that will be used in body or url
        let bodyParameters: Parameters = ["Param1": "String", "Param2": 231]
        let urlParameters: Parameters = ["Param3": "String", "Param4": 231]
        return .requestWithParameters(body: bodyParameters, url: urlParameters)
    case .requestWithParametersAndHeaders:
        /// Request with parameters that will be used in body or url and headers
        let bodyParameters: Parameters = ["Param1": "String", "Param2": 231]
        let urlParameters: Parameters = ["Param3": "String", "Param4": 231]
        let headers: HttpHeaders = ["Header": "Test"]
        return .requestWithParametersAndHeaders(body: bodyParameters, url: urlParameters, headers: headers)
    case .upload:
        /// Multipart upload request
        let body = MultipartBody(parameters: ["Param": "test"], fileUrls: [URL(string: "path to file")!], mimeType: "Mime type of file")
        return .upload(body: body)
    case .formDataRequest:
        /// Request with form data body
        let parameters: Parameters = ["Param1": "String", "Param2": 231]
        return .formDataRequest(body: parameters)
     }
   }
}
```

## Step2 Create Router

Create router to perform requests

```swift
    let router = try URLSessionRouter(baseURL: "https://someurl.com")
```

## Step3 Call API methods

There are 2 possible ways of performing request
 * Using completion callbacks
 * Using async/await
 
### Perform Request and parse response as decodable model

This variation allow to perform request and parse response as decodable model

#### Completion block variation
 
```swift
// Request with decoded body as Decodable model, you can also provide key decoding strategy default on is .useDefaultKeys
router.performTask(to: Endpoint.request) { result in
    switch result {
    case let .success(decodable):
      // Decodable representation of response
    case let .failure(error):
      // Handle Error
      print(error)
    }
}
```

#### Async Await variation

```swift
// Request with decoded body as Decodable model, you can also provide key decoding strategy default on is .useDefaultKeys
let result: SomeModel =  try await router.performTask(to: Endpoint.request)
print(result)
```

### Perform Request with response

This variation allow to retrieve response object of the request

#### Completion block variation

```swift
// Request with response
router.performTask(to: Endpoint.request) { result, response in
    // Print response of request
    print(response)
    switch result {
    case let .success(data):
      // Handle response data of type Data
      print(data)
    case let .failure(error):
      // Handle Error
      print(error)
    }
}
```

#### Async Await variation

```swift
// Request with response
let result: ResponseEntry = try await router.performTask(to: Endpoint.request)
print(result.data) // Data of response body
print(result.response) // Response of request
```

### Perform Request to get body of the response

This variation allow to retrieve response body Data representation

#### Completion block variation

```swift
// Request with Data response
router.performTask(to: Endpoint.request) { result in
    switch result {
    case let .success(data):
      // Handle response data of type Data
      print(data)
    case let .failure(error):
      // Handle Error
      print(error)
    }
}
```

#### Async Await variation

```swift
// Request with Data response
let result: Data = try await router.performTask(to: Endpoint.request)
print(result) // Data of response body
```

### Perform Request without return type

This variation allow to perform request without parsing response

#### Completion block variation

```swift
// Request without parsing body
router.performVoidTask(to: Endpoint.request) { result in
    switch result {
    case let .success(_):
      // Request was successful perform further actions
    case let .failure(error):
      // Handle Error
      print(error)
    }
}
```

#### Async Await variation

```swift
// Request without parsing body
try await router.performVoidTask(to: Endpoint.request)
```

## License

This project is licensed under the MIT license. See the [LICENSE](https://github.com/Mc231/NetworkLibrary/blob/master/LICENSE.md) file for more info.
