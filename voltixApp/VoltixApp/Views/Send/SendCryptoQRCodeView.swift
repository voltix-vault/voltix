//
//  SendCryptoQRCodeView.swift
//  VoltixApp
//
//  Created by Amol Kumar on 2024-03-15.
//

import SwiftUI

struct SendCryptoQRCodeView: View {
    @ObservedObject var viewModel: SendCryptoViewModel
    @State var address = "123456789"
    
    let padding: CGFloat = 40
    
    var body: some View {
        ZStack {
            background
            view
        }
        .gesture(DragGesture())
    }
    
    var background: some View {
        Color.backgroundBlue
            .ignoresSafeArea()
    }
    
    var view: some View {
        VStack(spacing: 50) {
            pairDeviceText
            qrCode
            wifiInstruction
        }
    }
    
    var pairDeviceText: some View {
        Text(NSLocalizedString("scanWithPairedDevice", comment: ""))
            .font(.body14MontserratMedium)
            .foregroundColor(.neutral0)
            .padding(.top, 30)
    }
    
    var qrCode: some View {
        GeometryReader { geometry in
            Utils.getQrImage(
                data: address.data(using: .utf8), size: 100)
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(24)
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.width-(2*padding))
            .background(Color.turquoise600.opacity(0.15))
            .cornerRadius(10)
            .overlay (
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.turquoise600, style: StrokeStyle(lineWidth: 2, dash: [56]))
            )
            .padding(.horizontal, padding)
        }
    }
    
    var wifiInstruction: some View {
        VStack(spacing: 8) {
            Image(systemName: "wifi")
                .font(.title30MenloUltraLight)
                .foregroundColor(.turquoise600)
            
            Text(NSLocalizedString("devicesOnSameWifi", comment: ""))
                .font(.body12Menlo)
                .foregroundColor(.neutral0)
                .frame(maxWidth: 250)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    SendCryptoQRCodeView(viewModel: SendCryptoViewModel())
}
