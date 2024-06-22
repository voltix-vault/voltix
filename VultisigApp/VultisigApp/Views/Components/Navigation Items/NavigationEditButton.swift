//
//  NavigationEditButton.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-04-17.
//

import SwiftUI

struct NavigationEditButton: View {
    var tint: Color = Color.neutral0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Image(systemName: "square.and.pencil")
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
        NavigationEditButton()
    }
}
