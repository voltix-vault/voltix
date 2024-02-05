//
//  KeysignDiscovery.swift
//  VoltixApp

import Mediator
import OSLog
import SwiftUI

private let logger = Logger(subsystem: "keysign-discovery", category: "view")
struct KeysignDiscoveryView: View {
    enum KeysignDiscoveryStatus {
        case WaitingForDevices
        case FailToStart
        case Keysign
    }

    @Binding var presentationStack: [CurrentScreen]
    @EnvironmentObject var appState: ApplicationState
    @State private var peersFound = [String]()
    @State private var selections = Set<String>()
    private let mediator = Mediator.shared
    private let serverAddr = "http://127.0.0.1:8080"
    private let sessionID = UUID().uuidString
    @State private var discoverying = true
    @State private var currentState = KeysignDiscoveryStatus.WaitingForDevices
    @State private var localPartyID = ""
    let keysignMessage: String
    let chain: Chain
    
    var body: some View {
        VStack {
            switch self.currentState {
            case .WaitingForDevices:
                Text("Scan the following QR code to join keysign session")
                Image(uiImage: self.getQrImage(size: 100))
                    .resizable()
                    .scaledToFit()
                    .padding()
                Text("Available devices")
                List(self.peersFound, id: \.self, selection: self.$selections) { peer in
                    HStack {
                        Image(systemName: self.selections.contains(peer) ? "checkmark.circle" : "circle")
                        Text(peer)
                    }
                    .onTapGesture {
                        if self.selections.contains(peer) {
                            self.selections.remove(peer)
                        } else {
                            self.selections.insert(peer)
                        }
                    }
                }
                Button("Sign") {
                    self.startKeysign(allParticipants: self.selections.map { $0 })
                    self.currentState = .Keysign
                    self.discoverying = false
                }
                .disabled(self.selections.count < self.appState.currentVault?.getThreshold() ?? Int.max)
            case .FailToStart:
                Text("fail to start keysign")
            case .Keysign:
                KeysignView(presentationStack: self.$presentationStack,
                            keysignCommittee: self.selections.map { $0 },
                            mediatorURL: self.serverAddr,
                            sessionID: self.sessionID,
                            keysignType: self.chain.signingKeyType,
                            messsageToSign: self.keysignMessage,
                            localPartyKey: self.localPartyID)
            }
        }
        .onAppear {
            if self.appState.currentVault == nil {
                self.currentState = .FailToStart
                return
            }
            if let localPartyID = appState.currentVault?.localPartyID, !localPartyID.isEmpty {
                self.localPartyID = localPartyID
            } else {
                self.localPartyID = UIDevice.current.name
            }
        }
        .task {
            // start the mediator , so other devices can discover us
            self.mediator.start()
            self.startKeysignSession()
            Task {
                repeat {
                    self.getParticipants()
                    try await Task.sleep(nanoseconds: 1_000_000_000) // wait for a second to continue
                } while self.discoverying
            }
        }
        .onDisappear {
            logger.info("mediator server stopped")
            self.discoverying = false
            self.mediator.stop()
        }
    }

    private func startKeysign(allParticipants: [String]) {
        let urlString = "\(self.serverAddr)/start/\(self.sessionID)"
        logger.debug("url:\(urlString)")
        
        guard let url = URL(string: urlString) else {
            logger.error("URL can't be constructed from: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(allParticipants)
            request.httpBody = jsonData
        } catch {
            logger.error("Failed to encode body into JSON string: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                logger.error("Failed to start session, error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response code")
                return
            }
            
            logger.info("Keygen started successfully.")
        }.resume()
    }
    
    private func startKeysignSession() {
        let urlString = "\(self.serverAddr)/\(self.sessionID)"
        logger.debug("url:\(urlString)")
        
        guard let url = URL(string: urlString) else {
            logger.error("URL can't be constructed from: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [self.localPartyID]
        
        do {
            let jsonEncoder = JSONEncoder()
            request.httpBody = try jsonEncoder.encode(body)
        } catch {
            logger.error("Failed to encode body into JSON string: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                logger.error("Failed to start session, error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response code")
                return
            }
            
            logger.info("Started keysign session successfully.")
        }
        
        task.resume()
    }

    private func getParticipants() {
        let urlString = "\(self.serverAddr)/\(self.sessionID)"

        guard let url = URL(string: urlString) else {
            logger.error("URL can't be constructed from: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logger.error("Failed to start session, error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response code")
                return
            }
            
            guard let data = data else {
                logger.error("No participants available yet")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let peers = try decoder.decode([String].self, from: data)
                
                for peer in peers {
                    if !self.peersFound.contains(peer) {
                        self.peersFound.append(peer)
                    }
                }
            } catch {
                logger.error("Failed to decode response to JSON: \(error)")
            }
        }.resume()
    }

    func getQrImage(size: CGFloat) -> UIImage {
        let context = CIContext()
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return UIImage(systemName: "xmark") ?? UIImage()
        }
        
        let keysignMsg = KeysignMessage(sessionID: self.sessionID, keysignMessage: self.keysignMessage)
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(keysignMsg)
            qrFilter.setValue(jsonData, forKey: "inputMessage")
        } catch {
            logger.error("fail to encode keysign messages to json,error:\(error)")
        }
        
        guard let qrCodeImage = qrFilter.outputImage else {
            return UIImage(systemName: "xmark") ?? UIImage()
        }
        
        let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: size, y: size))
        
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return UIImage(systemName: "xmark") ?? UIImage()
        }
        
        return UIImage(cgImage: cgImage)
    }
}

struct KeysignMessage: Codable {
    let sessionID: String
    let keysignMessage: String
}

#Preview {
    KeysignDiscoveryView(presentationStack: .constant([]), 
                         keysignMessage: "whatever",
                         chain: Chain.THORChain)
}
