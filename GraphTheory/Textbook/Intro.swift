//
//  Intro.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct Intro: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("Graph Theory")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Text("Introduction")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Text("Seven Bridges of Königsberg")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    Text("Graph theory began in 1736 with Leonhard Euler's proof of The Seven Bridges of Konigsberg. The goal is to design a walk through the city of Konigsberg that crosses every bridge (edge) exactly once. Euler proved that this problem is impossible. However, it becomes possible if you either delete a certain edge, or add a certain edge between two vertices. Try it for yourself!")
                        .padding()
                    let minimumDimension = min(geometry.size.width, geometry.size.height)
                    KonigsbergView()
                        .frame(width: minimumDimension, height: minimumDimension)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    Intro()
}
