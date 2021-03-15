//
//  WebhookManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 15.03.2021.
//

import Foundation

class WebSocketManager {
    
    public static let shared = WebSocketManager() // создаем Синглтон
    private init(){}
    
    private var dataArray: [StockQuote] = []
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c16k5t748v6ppg7etbig")!)
    
    //функция вызова подключения
    public func connectToWebSocket() {
        webSocketTask.resume()
        self.receiveData() { _ in }
    }
    
    //функция подписки на что либо
    public func subscribeBtcUsd(symbol: String) {
        let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}")
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    //функция отписки от чего либо
    public func unSubscribeBtcUsd(symbol: String) {
        let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}")
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    //функция получения данных, с эскейпингом чтобы получить данные наружу
    func receiveData(completion: @escaping ([StockQuote]?) -> Void) {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print(text)
                    let data: Data? = text.data(using: .utf8)
                    let singleData = try? StockQuote.decode(from: data ?? Data())
//                    for singleData in srvData ?? [] {
                    if singleData != nil {
                        self.dataArray.append(StockQuote(c: singleData!.c, h: singleData!.h, l: singleData!.l, o: singleData!.o, pc: singleData!.pc, t: singleData!.t))
                    }
//                    }
                case .data(let data):
                    // В вашем варианте данные могут приходить сразу сюда
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
                
                self.receiveData() {_ in } // рекурсия
            }
        }
        completion(self.dataArray) // отправляем в комплишн то что насобирали в нашу модель
    }
}
