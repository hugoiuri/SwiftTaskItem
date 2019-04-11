import Foundation

struct TodoRepository {
    private let networkService: NetworkService
    private let token: String

    init(network: NetworkService, token: String) {
        self.networkService = network
        self.token = token
    }

    func all(callback: (@escaping (Result<[Todo]>) -> Void)) {
        let resource = Resource(path: "todo",
                                method: .get,
                                body: nil,
                                queryItems: nil,
                                headers: ["Authorization": "Bearer \(token)"])

        try? networkService.callApi(resource: resource) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode([Todo].self, from: data)
                    callback(.success(response))
                } catch {
                    callback(.error(NetworkError.underlying(error)))
                }

                return
            case .failure(let error):
                callback(.error(NetworkError.underlying(error)))
                return
            }
        }
    }

    func create(taskTitle: String, callback: (@escaping ((Result<Todo>) -> Void))) {
        let resource = Resource(path: "todo",
                                method: .post,
                                body: ["task": taskTitle],
                                queryItems: nil,
                                headers: ["Authorization": "Bearer \(token)"])

        try? networkService.callApi(resource: resource) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Todo.self, from: data)
                    callback(.success(response))
                } catch {
                    callback(.error(NetworkError.underlying(error)))
                }

                return
            case .failure(let error):
                callback(.error(NetworkError.underlying(error)))
                return
            }
        }
    }

    func delete(id: Int, callback: @escaping ((Result<Void>) -> Void)) {
        let resource = Resource(path: "todo/\(id)",
                                method: .delete,
                                body: nil,
                                queryItems: nil,
                                headers: ["Authorization": "Bearer \(token)"])

        try? networkService.callApi(resource: resource) { (result) in
            switch result {
            case .success:
                callback(.success(()))
                return
            case .failure(let error):
                callback(.error(NetworkError.underlying(error)))
                return
            }
        }
    }

    func toggleComplete(id: Int, callback: @escaping ((Result<Todo>) -> Void)) {
        let resource = Resource(path: "todo/\(id)/complete",
            method: .put,
            body: nil,
            queryItems: nil,
            headers: ["Authorization": "Bearer \(token)"])

        try? networkService.callApi(resource: resource) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Todo.self, from: data)
                    callback(.success(response))
                } catch {
                    callback(.error(NetworkError.underlying(error)))
                }

                return
            case .failure(let error):
                callback(.error(NetworkError.underlying(error)))
                return
            }
        }
    }
}
