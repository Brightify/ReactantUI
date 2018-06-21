//
//  TCPWatcher.swift
//  ReactantUI
//
//  Created by Filip Dolnik on 13.06.18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation
import RxSwift

// TODO Solve logging, errors, server selection, security
class TCPWatcher: Watcher {
    
    private enum Operation: UInt8 {
        case register = 0
        case unregister = 1
        case reloadFiles = 2
        case data = 3
    }
    
    private struct SocketState {
        static let closed: Int32 = -1
        static let sealed: Int32 = -2
        
        private init() {
        }
        
        static func isOpen(_ socket: Int32) -> Bool {
            return socket >= 0
        }
    }
    
    private static let serverUDPPort = 5000
    
    private var clientSocket: Int32 = SocketState.closed
    private let socketCondition = NSCondition()
    
    private var loadedFiles: [(file: String, data: Data)]? = nil
    private let loadedFilesCondition = NSCondition()
    private let reloadAllQueue = DispatchQueue(label: "ReloadAllQueue")
    
    private let startQueue = DispatchQueue(label: "StartQueue")
    private let tcpIncomingQueue = DispatchQueue(label: "TCPIncomingQueue")
    private let tcpOutgoingQueue = DispatchQueue(label: "TCPOutgoingQueue")
    
    private var watchedFiles: [String: (subject: ReplaySubject<(file: String, data: Data)>, lock: NSLock)] = [:]
    private let watchedFilesLock = NSLock()
    
    private var files: [String: Data] = [:]
    private let filesCondition = NSCondition()
    
    init() {
        startTCPConnection()
        startIncommingQueue()
    }
    
    deinit {
        closeTCPConnection(permanently: true)
        
        watchedFilesLock.lock()
        let watchedFiles = self.watchedFiles
        watchedFilesLock.unlock()
        
        for watchedFile in watchedFiles {
            watchedFile.value.lock.lock()
            watchedFile.value.subject.onCompleted()
            watchedFile.value.lock.unlock()
        }
    }
    
    func watch(file: String) -> Observable<(file: String, data: Data)> {
        watchedFilesLock.lock()
        let subject: ReplaySubject<(file: String, data: Data)>
        if let fileSubject = watchedFiles[file]?.subject {
            subject = fileSubject
            watchedFilesLock.unlock()
        } else {
            print("Register \(file)")
            
            subject = ReplaySubject<(file: String, data: Data)>.create(bufferSize: 1)
            let lock = NSLock()
            watchedFiles[file] = (subject, lock)
            watchedFilesLock.unlock()
            
            sendMessage(file: file, operation: .register)
            
            filesCondition.lock()
            while files[file] == nil {
                filesCondition.wait()
            }
            let data = files[file]
            filesCondition.unlock()
            
            if let data = data {
                lock.lock()
                subject.onNext((file, data))
                lock.unlock()
            }
        }
        
        return subject.asObserver().observeOn(MainScheduler.instance)
    }
    
    func stopWatching(file: String) {
        print("Unegister \(file)")
        
        watchedFilesLock.lock()
        let watchedFile = watchedFiles[file]
        watchedFiles.removeValue(forKey: file)
        watchedFilesLock.unlock()
        
        watchedFile?.lock.lock()
        watchedFile?.subject.onCompleted()
        watchedFile?.lock.unlock()
        
        sendMessage(file: file, operation: .unregister)
    }
    
    func preload(rootDir: String) {
        print("Preload files \(rootDir)")
        
        DispatchQueue(label: "PreloadQueue").async { [weak self] in
            _ = self?.reloadAll(in: rootDir)
        }
    }
    
    func reloadAll(in rootDir: String) -> [(file: String, data: Data)] {
        print("Reload files \(rootDir)")
        
        return reloadAllQueue.sync {
            loadedFilesCondition.lock()
            loadedFiles = nil
            loadedFilesCondition.unlock()
            
            sendMessage(file: rootDir, operation: .reloadFiles)
            
            loadedFilesCondition.lock()
            while loadedFiles == nil {
                loadedFilesCondition.wait()
            }
            let result = loadedFiles!
            loadedFilesCondition.unlock()
            
            return result
        }
    }
    
    private func startTCPConnection() {
        startQueue.async { [weak self] in
            self?.socketCondition.lock()
            guard self?.clientSocket == SocketState.closed else {
                self?.socketCondition.unlock()
                return
            }
            self?.socketCondition.unlock()
            
            guard let tcp = TCPWatcher.setupTCP(), let udp = TCPWatcher.setupUDP() else {
                return
            }
            
            DispatchQueue(label: "TCPQueue").async { [weak self] in
                while true {
                    self?.socketCondition.lock()
                    guard self?.clientSocket == SocketState.closed else {
                        self?.socketCondition.unlock()
                        break
                    }
                    self?.socketCondition.unlock()
                    
                    var address = tcp.address
                    var addressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
                    let socket = withUnsafeMutablePointer(to: &address) {
                        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                            accept(tcp.socket, $0, &addressLength)
                        }
                    }
                    if socket == -1 {
                        print("Error accept")
                    } else {
                        print("Connection established")
                        
                        self?.socketCondition.lock()
                        self?.clientSocket = socket
                        self?.socketCondition.unlock()
                        self?.socketCondition.broadcast()
                        
                        break
                    }
                }
            }
            
            self?.socketCondition.lock()
            while self?.clientSocket == SocketState.closed {
                TCPWatcher.sendBroadcast(socket: udp.socket, address: udp.address, tcpPort: tcp.port)
                self?.socketCondition.wait(until: Date().addingTimeInterval(1))
            }
            self?.socketCondition.unlock()
            
            shutdown(udp.socket, SHUT_RDWR)
            shutdown(tcp.socket, SHUT_RDWR)
            close(udp.socket)
            close(tcp.socket)
            
            self?.watchedFilesLock.lock()
            for file in (self?.watchedFiles ?? [:]) {
                self?.sendMessage(file: file.key, operation: .register)
            }
            self?.watchedFilesLock.unlock()
        }
    }
    
    private func startIncommingQueue() {
        tcpIncomingQueue.async { [weak self] in
            while true {
                self?.socketCondition.lock()
                while self?.clientSocket == -1 {
                    self?.socketCondition.wait()
                }
                guard let socket = self?.clientSocket, socket != SocketState.sealed else {
                    self?.socketCondition.unlock()
                    break
                }
                self?.socketCondition.unlock()
                
                var operationBuffer = [UInt8](repeating: 0, count: 1)
                let receivedHeaderCount = recv(socket, &operationBuffer, 1, MSG_WAITALL)
                if receivedHeaderCount == 1 {
                    switch Operation(rawValue: operationBuffer[0]) {
                    case .data?:
                        let result = self?.receiveFile(from: socket)
                        if let result = result {
                            self?.watchedFilesLock.lock()
                            let watchedFile = self?.watchedFiles[result.file]
                            self?.watchedFilesLock.unlock()
                            
                            watchedFile?.lock.lock()
                            watchedFile?.subject.onNext((result.file, result.data))
                            watchedFile?.lock.unlock()
                        }
                    case .reloadFiles?:
                        var countBuffer = [UInt8](repeating: 0, count: 4)
                        let receivedHeaderCount = recv(socket, &countBuffer, 4, MSG_WAITALL)
                        var files: [(String, Data)] = []
                        if receivedHeaderCount == 4 {
                            let fileCount = TCPWatcher.decode(from: countBuffer, offset: 0)
                            for _ in 0..<fileCount {
                                if let file = self?.receiveFile(from: socket) {
                                    files.append(file)
                                }
                            }
                        } else {
                            print("Error count")
                            self?.restartTCPConnection(close: socket)
                        }
                        
                        self?.loadedFilesCondition.lock()
                        self?.loadedFiles = files
                        self?.loadedFilesCondition.unlock()
                        self?.loadedFilesCondition.signal()
                    default:
                        print("Error unknown operation")
                        self?.restartTCPConnection(close: socket)
                    }
                } else {
                    print("Error operation")
                    self?.restartTCPConnection(close: socket)
                }
            }
        }
    }
    
    private func closeTCPConnection(closeOnly socket: Int32? = nil, permanently: Bool = false) {
        socketCondition.lock()
        if (clientSocket == socket || socket == nil) && SocketState.isOpen(clientSocket) {
            shutdown(clientSocket, SHUT_RDWR)
            close(clientSocket)
            clientSocket = permanently ? SocketState.sealed : SocketState.closed
        }
        socketCondition.unlock()
        socketCondition.broadcast()
    }
    
    private func restartTCPConnection(close socket: Int32) {
        closeTCPConnection(closeOnly: socket)
        startTCPConnection()
    }
    
    private func sendMessage(file: String, operation: Operation) {
        tcpOutgoingQueue.async { [weak self] in
            self?.socketCondition.lock()
            while self?.clientSocket == -1 {
                self?.socketCondition.wait()
            }
            guard let socket = self?.clientSocket, socket != SocketState.sealed else {
                self?.socketCondition.unlock()
                return
            }
            self?.socketCondition.unlock()
            
            let bufferSize = 1 + 4 + file.utf8.count
            var sendBuffer = [UInt8](repeating: 0, count: bufferSize)
            
            sendBuffer[0] = operation.rawValue
            TCPWatcher.encode(number: file.utf8.count, to: &sendBuffer, offset: 1)
            sendBuffer.replaceSubrange(5..<bufferSize, with: file.utf8)
            
            let sendResult = send(socket, sendBuffer, bufferSize, 0)
            if sendResult == -1 {
                print("Error send message")
                self?.restartTCPConnection(close: socket)
            }
        }
    }
    
    private func receiveFile(from socket: Int32) -> (file: String, data: Data)? {
        var headerBuffer = [UInt8](repeating: 0, count: 8)
        let receivedHeaderCount = recv(socket, &headerBuffer, 8, MSG_WAITALL)
        if receivedHeaderCount == 8 {
            let nameSize = TCPWatcher.decode(from: headerBuffer, offset: 0)
            let bodySize = TCPWatcher.decode(from: headerBuffer, offset: 4)
            
            // Size + 1 for C string null terminator
            var nameBuffer = [UInt8](repeating: 0, count: nameSize + 1)
            var bodyBuffer = [UInt8](repeating: 0, count: bodySize)
            
            let receivedNameCount = recv(socket, &nameBuffer, nameSize, MSG_WAITALL)
            let receivedBodyCount = recv(socket, &bodyBuffer, bodySize, MSG_WAITALL)
            
            if receivedNameCount == nameSize && receivedBodyCount == bodySize {
                let file = String(cString: nameBuffer)
                let body = Data(bodyBuffer)
                
                print("Incomming file: \(file)")
                
                filesCondition.lock()
                files[file] = body
                filesCondition.unlock()
                filesCondition.broadcast()
                
                return (file, body)
            } else {
                print("Error file data")
                restartTCPConnection(close: socket)
            }
        } else {
            print("Error file header")
            restartTCPConnection(close: socket)
        }
        return nil
    }
    
    private static func setupTCP() -> (socket: Int32, address: sockaddr_in, port: in_port_t)? {
        let tcpSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        guard tcpSocket != -1 else {
            print("Error TCP socket")
            return nil
        }
        
        var address = sockaddr_in()
        var addressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        listen(tcpSocket, 1)
        let bindResult = withUnsafeMutablePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                getsockname(tcpSocket, $0, &addressLength)
            }
        }
        if bindResult == -1 {
            print("Error TCP bind")
        }
        
        let port = address.sin_port.bigEndian
        print("Port: \(port)")
        
        return (tcpSocket, address, port)
    }
    
    private static func setupUDP() -> (socket: Int32, address: sockaddr_in)? {
        let udpSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        guard udpSocket != -1 else {
            print("Error UDP socket")
            return nil
        }
        
        var address = sockaddr_in()
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = in_port_t(TCPWatcher.serverUDPPort).bigEndian
        address.sin_addr.s_addr = in_addr_t(INADDR_BROADCAST)
        
        var enabled = 1
        setsockopt(udpSocket, SOL_SOCKET, SO_BROADCAST, &enabled, socklen_t(MemoryLayout<Int>.size))
        
        return (udpSocket, address)
    }
    
    private static func sendBroadcast(socket: Int32, address: sockaddr_in, tcpPort: in_port_t) {
        print("Sending broadcast")
        
        var address = address
        let buffer = [UInt8(tcpPort >> 8), UInt8(tcpPort & 0xff)]
        
        let sendCount = withUnsafeMutablePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                sendto(socket, buffer, 2, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        if sendCount != 2 {
            print("Error send broadcast")
        }
    }
    
    private static func encode(number: Int, to buffer: inout [UInt8], offset: Int) {
        buffer[0 + offset] = UInt8((number >> 24) & 0xff)
        buffer[1 + offset] = UInt8((number >> 16) & 0xff)
        buffer[2 + offset] = UInt8((number >> 8) & 0xff)
        buffer[3 + offset] = UInt8((number >> 0) & 0xff)
    }
    
    private static func decode(from buffer: [UInt8], offset: Int) -> Int {
        var result: Int32 = 0
        result |= Int32(buffer[0 + offset]) << 24
        result |= Int32(buffer[1 + offset]) << 16
        result |= Int32(buffer[2 + offset]) << 8
        result |= Int32(buffer[3 + offset]) << 0
        return Int(result)
    }
}
