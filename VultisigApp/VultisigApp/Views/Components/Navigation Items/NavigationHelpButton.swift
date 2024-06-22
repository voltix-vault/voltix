//
//  NavigationHelpButton.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-03-06.
//

import SwiftUI

struct NavigationHelpButton: View {
    var tint: Color = Color.neutral0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Link(destination: URL(string: Endpoint.supportDocumentLink)!) {
            image
        }
    }
    
    var image: some View {
        Image(systemName: "questionmark.circle")
            .font(.body18MenloBold)
#if os(iOS)
                .foregroundColor(tint)
#elseif os(macOS)
                .foregroundColor(colorScheme == .light ? .neutral700 : .neutral0)
#endif
    }
}

#Preview {
    ZStack {
        Background()
        NavigationHelpButton()
    }
}
