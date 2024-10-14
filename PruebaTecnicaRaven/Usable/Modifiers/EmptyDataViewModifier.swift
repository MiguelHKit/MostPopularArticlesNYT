//
//  EmptyDataViewModifier.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 13/10/24.
//

import SwiftUI

extension View {
    public func emptyDataViewModifier(onCondition: () -> Bool) -> some View {
        self.overlay {
            if onCondition() {
                ContentUnavailableView(
                    String(localized: "noData"),
                    systemImage: "doc.plaintext.fill",
                    description: Text(String(localized: "noDataDescription"))
                )
            }
        }
    }
}
