//
//  WebhookManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 15.03.2021.
//

import Foundation

class WebSocketManager {
    
    // Web Socket иногда перестаёт работать из-за просрочки токена, хотя на сайте про это ничего не говориться, он просто перестаёт работать и всё тут, поэтому его нужно регулярно обновлять
    
    public static let shared = WebSocketManager()
    private init(){}
    
    private var dataArray: [WebSocket] = []
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c1bgv9n48v6rcdqa0kn0")!)
    
    public func connectToWebSocket() {
        webSocketTask.resume()
//        self.receiveData() { _ in }
    }
    
    public func subscribe(symbol: String) {
        let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}")
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    public func unSubscribe(symbol: String) {
        let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}")
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    func receiveData(completion: @escaping ([WebSocket]?) -> Void) {
        print("1")
        webSocketTask.receive { result in
            print("2")
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print(text)
                    let data: Data? = text.data(using: .utf8)
                    let srvData = try? WebSocketModel.decode(from: data ?? Data())
                    
                    for singleData in srvData?.data ?? [] {
                        self.dataArray.append(WebSocket(s: singleData.s, p: singleData.p, t: singleData.t, v: singleData.v, c: singleData.c))
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
                
//                self.receiveData() { (dataArray) in completion(dataArray) }
            }
        }
        completion(self.dataArray)
        dataArray = []
    }
}
