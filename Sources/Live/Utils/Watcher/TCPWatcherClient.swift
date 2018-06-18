//
//  TCPWatcherClient.swift
//  ReactantLiveUI
//
//  Created by Filip Dolnik on 13.06.18.
//

import Foundation

public class TCPWatcherClient {
    
    private enum Operation: UInt8 {
        case register = 0
        case unregister = 1
    }
    
    private static let serverUDPPort = 5000
    
    private var watchers: [String: [(TCPWatcher, (String, Data) -> Void)]] = [:]
    
    private let udpSocket: Int32
    private let tcpSocket: Int32
    private var clientSocket: Int32 = -1
    
    private let tcpQueue = DispatchQueue(label: "TCPQueue")
    private let tcpIncommingQueue = DispatchQueue(label: "TCPIncommingQueue")
    private let watchersQueue = DispatchQueue(label: "WatchersQueue")
    
    init() {
        udpSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        tcpSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
       
        if udpSocket == -1 || tcpSocket == -1 {
            print("Error socket\n")
        }
        
        var udpAddress = sockaddr_in()
        udpAddress.sin_family = sa_family_t(AF_INET)
        udpAddress.sin_port = in_port_t(TCPWatcherClient.serverUDPPort).bigEndian
        udpAddress.sin_addr.s_addr = in_addr_t(INADDR_BROADCAST)
        
        var tcpAddress = sockaddr_in()
        
        var slen = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        listen(tcpSocket, 1)
        let retCode = withUnsafeMutablePointer(to: &tcpAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                getsockname(tcpSocket, $0, &slen)
            }
        }
        if retCode == -1 {
            print("Error bind\n")
        }
        
        let tcpPort = tcpAddress.sin_port.bigEndian
        
        print("Port: \(tcpPort)")
        
        var enabled = 1
        setsockopt(udpSocket, SOL_SOCKET, SO_BROADCAST, &enabled, socklen_t(MemoryLayout<Int>.size))
        
        var sendBuffer = [UInt8](repeating: 0, count: 2)
        sendBuffer[0] = UInt8(tcpPort >> 8)
        sendBuffer[1] = UInt8(tcpPort & 0xff)
        
        let count = withUnsafeMutablePointer(to: &udpAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                sendto(udpSocket, sendBuffer, 2, 0, $0, slen)
            }
        }
        if count == -1 {
            print("Error send")
        }
        
        tcpQueue.async {
            self.clientSocket = withUnsafeMutablePointer(to: &tcpAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    accept(self.tcpSocket, $0, &slen)
                }
            }
            if self.clientSocket == -1 {
                print("Error accept")
            }
            
            DispatchQueue.main.sync {
                print("Connection established.\n")
            }
            
            self.tcpIncommingQueue.async {
                while true {
                    var headerBuffer = [UInt8](repeating: 0, count: 8)
                    let receivedHeaderCount = recv(self.clientSocket, &headerBuffer, 8, 0)
                    if receivedHeaderCount == 8 {
                        let nameSize = Int(headerBuffer[0] << 24) +
                            Int(headerBuffer[1]) << 16 +
                            Int(headerBuffer[2]) << 8 +
                            Int(headerBuffer[3]) << 0
                        let bodySize = Int(headerBuffer[4] << 24) +
                            Int(headerBuffer[5]) << 16 +
                            Int(headerBuffer[6]) << 8 +
                            Int(headerBuffer[7]) << 0
                        // Size + 1 for C string null terminator
                        var nameBuffer = [UInt8](repeating: 0, count: nameSize + 1)
                        var bodyBuffer = [UInt8](repeating: 0, count: bodySize)
                        let receivedNameCount = recv(self.clientSocket, &nameBuffer, nameSize, 0)
                        let receivedBodyCount = recv(self.clientSocket, &bodyBuffer, bodySize, 0)
                        if receivedNameCount == nameSize && receivedBodyCount == bodySize {
                            let fileName = String(cString: nameBuffer)
                            let body = Data(bodyBuffer)

                            print("Incomming file: " + fileName + "\n")
                            
                            self.watchersQueue.async {
                                if let watchers = self.watchers[fileName] {
                                    for watcher in watchers {
                                        watcher.1(fileName, body)
                                    }
                                }
                            }
                        } else {
                            print("Error data")
                        }
                    }
                }
            }
        }
        
        close(udpSocket)
    }
    
    deinit {
        close(tcpSocket)
    }
    
    func register(watcher: TCPWatcher, eventHandler: @escaping (String, Data) -> Void) {
        watchersQueue.sync {
            if watchers[watcher.path] == nil {
                watchers[watcher.path] = []
            }
            watchers[watcher.path]?.append((watcher, eventHandler))
        }
        print("Register \(watcher.path)\n")
        sendMessage(file: watcher.path, operation: .register)
    }
    
    func unregister(watcher: TCPWatcher) {
        watchersQueue.sync {
            let index = watchers[watcher.path]?.index(where: { $0.0 === watcher })
            if let index = index {
                watchers[watcher.path]?.remove(at: index)
                if watchers[watcher.path]?.count == 0 {
                    watchers.removeValue(forKey: watcher.path)
                }
            }
        }
        print("Unegister \(watcher.path)\n")
        sendMessage(file: watcher.path, operation: .unregister)
    }
    
    private func sendMessage(file: String, operation: Operation) {
        tcpQueue.async {
            let bufferSize = 1 + 4 + file.utf8.count
            var sendBuffer = [UInt8](repeating: 0, count: bufferSize)
            sendBuffer[0] = operation.rawValue
            sendBuffer[1] = UInt8((file.count >> 24) & 0xff)
            sendBuffer[2] = UInt8((file.count >> 16) & 0xff)
            sendBuffer[3] = UInt8((file.count >> 8) & 0xff)
            sendBuffer[4] = UInt8((file.count >> 0) & 0xff)
            sendBuffer.replaceSubrange(5..<bufferSize, with: file.utf8)
            
            let sendResult = send(self.clientSocket, sendBuffer, bufferSize, 0)
            if sendResult == -1 {
                print("Error send message")
            }
        }
    }
}
