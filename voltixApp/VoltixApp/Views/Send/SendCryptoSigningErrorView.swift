//
//  SendCryptoErrorView.swift
//  VoltixApp
//
//  Created by Amol Kumar on 2024-03-20.
//

import SwiftUI

struct SendCryptoSigningErrorView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            errorMessage
            Spacer()
            bottomBar
        }
    }
    
    var errorMessage: some View {
        ErrorMessage(text: "signInErrorTryAgain")
    }
    
    var bottomBar: some View {
        VStack {
            sameWifiInstruction
            tryAgainButton
        }
    }
    
    var sameWifiInstruction: some View {
        Text(NSLocalizedString("sameWifiEntendedInstruction", comment: "Keep devices on the same WiFi Network, correct vault and pair devices. Make sure no other devices are running Voltix."))
            .font(.body12Menlo)
            .foregroundColor(.neutral0)
            .padding(.horizontal, 50)
            .multilineTextAlignment(.center)
    }
    
    var tryAgainButton: some View {
        Button {
            dismiss()
        } label: {
            FilledButton(title: "tryAgain")
        }
        .padding(40)
    }
}

#Preview {
    ZStack {
        Background()
        SendCryptoSigningErrorView()
    }
}
