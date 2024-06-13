//
//  BackupPasswordSetupView.swift
//  VultisigApp
//
//  Created by Amol Kumar on 2024-06-13.
//

import SwiftUI

struct BackupPasswordSetupView: View {
    let vault: Vault
    
    var body: some View {
        ZStack {
            Background()
            view
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(NSLocalizedString("backup", comment: "Backup"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationBackButton()
            }
        }
    }
    
    var view: some View {
        VStack {
            content
            Spacer()
            buttons
        }
        .fileExporter(
            isPresented: $showVaultExporter,
            document: EncryptedDataFile(url: encryptedFileURL),
            contentType: .data,
            defaultFilename: "\(vault.getExportName())"
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error saving file: \(error.localizedDescription)")
            }
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("passwordProtectBackup", comment: ""))
                .font(.body14MontserratMedium)
                .foregroundColor(.neutral0)
            
            textfield
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
    }
    
    var textfield: some View {
        TextField(NSLocalizedString("enterPassword", comment: "").capitalized, text: $name)
            .font(.body16Menlo)
            .foregroundColor(.neutral0)
            .submitLabel(.done)
            .padding(12)
            .background(Color.blue600)
            .cornerRadius(12)
            .colorScheme(.dark)
    }
    
    var buttons: some View {
        VStack(spacing: 20) {
            startButton
            joinButton
        }
        .padding(40)
    }
    
    var startButton: some View {
        Button {
            
        } label: {
            FilledButton(title: "save")
        }
    }
    
    var joinButton: some View {
        Button {
            
        } label: {
            OutlineButton(title: "skip")
        }
    }
}

#Preview {
    BackupPasswordSetupView(vault: Vault.example)
}
