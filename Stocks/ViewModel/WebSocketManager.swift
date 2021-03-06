//
//  WebhookManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 15.03.2021.
//

import Foundation

class WebSocketManager {
    
    // Web Socket иногда перестаёт работать либо из-за технических работ на сайте предоставителя услуг
    // Web Socket выгружается при сворачивании приложения и, как я вычитал в интернете, - это баг самой iOS и можно только перезапустить её, однако я не очень понял как, потому что тривиальный вызов функции connectToWebSocket() не даёт ожидаемого результат. Возможно нужно переподключиться и переподписаться на всё, что было до выгрузки
    
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
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
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
