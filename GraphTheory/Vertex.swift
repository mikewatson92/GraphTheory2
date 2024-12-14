//
//  Vertex.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI

struct Vertex: Identifiable, Codable {
    let id: UUID
    var position: CGPoint = .zero
    var offset: CGSize = .zero
    var color: Color = Color.primary
    var strokeColor: Color = Color.secondary
    var label: String = ""
    var labelColor: LabelColor = .white
    
    init() {
        self.id = UUID()
    }
    
    init(position: CGPoint) {
        self.id = UUID()
        self.position = position
    }
    
    enum LabelColor: String, CaseIterable, Identifiable {
        case white = "white"
        case blue = "blue"
        case red = "red"
        case green = "green"
        case black = "black"
        
        var id: String { self.rawValue }
    }
    
    // Custom Codable implementation for `Color`
    enum CodingKeys: String, CodingKey {
        case id, position, color
    }
    
    mutating func setOffset(_ size: CGSize) {
        offset = size
    }
    
    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position, forKey: .position)
        // Convert Color to a string representation (e.g., hex)
        try container.encode(color.toHex(), forKey: .color)
    }
    
    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        position = try container.decode(CGPoint.self, forKey: .position)
        // Convert the stored string back into a Color
        let colorHex = try container.decode(String.self, forKey: .color)
        color = Color(hex: colorHex)
    }
}

class VertexViewModel: ObservableObject {
    @Published private var vertex: Vertex
    @Published var graphViewModel: GraphViewModel
    var mode: [Mode]
    
    init(vertex: Vertex, graphViewModel: GraphViewModel, mode: [Mode] = [.editLabels, .showLabels])
    {
        self.vertex = vertex
        self.graphViewModel = graphViewModel
        self.mode = mode
    }
    
    var color: Color {
        get { vertex.color }
        set {
            vertex.color = newValue
            graphViewModel.setColor(vertex: vertex, color: newValue)
        }
    }
    
    var strokeColor: Color {
        vertex.strokeColor
    }
    
    enum Mode {
        case editLabels, noEditLabels, showLabels, hideLabels
    }
    
    func getVertexID() -> UUID {
        return vertex.id
    }
    
    func getLabelColor() -> Vertex.LabelColor {
        vertex.labelColor
    }
    
    func getPosition() -> CGPoint? {
        graphViewModel.getVertexByID(vertex.id)?.position
    }
    
    func setPosition(_ position: CGPoint) {
        graphViewModel.setVertexPosition(vertex: vertex, position: position)
    }
    
    func getOffset() -> CGSize? {
        graphViewModel.getGraph().getOffsetByID(vertex.id)
    }
    
    func setOffset(size: CGSize) {
        graphViewModel.setVertexOffset(vertex: vertex, size: size)
    }
    
    func setColor(vertexID: UUID, color: Color) {
        self.color = color
        graphViewModel.setColor(vertex: graphViewModel.getVertexByID(vertexID)!, color: color)
    }
    
    func getLabel() -> String {
        vertex.label
    }
    
    func setLabel(_ newLabel: String) {
        vertex.label = newLabel
    }
}

struct VertexView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vertexViewModel: VertexViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var latexSize = CGSize(width: 1, height: 1)
    @State private var edittingLabel: Bool = false
    @State private var tempLabel: String {
        willSet {
            vertexViewModel.setLabel(newValue)
        }
    }
    var colorLatexString: String { "\\textcolor{\(vertexViewModel.getLabelColor().rawValue)}{\(tempLabel)}"
    }
    var labelColor : Color {
        get {
            switch vertexViewModel.getLabelColor() {
            case .white:
                Color.white
            case .blue:
                Color.blue
            case .red:
                Color.red
            case .green:
                Color.green
            case .black:
                Color.black
            }
        }
    }
    let size: CGSize
    var mode: [VertexViewModel.Mode] {
        get {
            vertexViewModel.mode
        } set {
            vertexViewModel.mode = newValue
        }
    }
    
    init(vertexViewModel: VertexViewModel, size: CGSize) {
        _vertexViewModel = .init(wrappedValue: vertexViewModel)
        self.size = size
        self.tempLabel = vertexViewModel.getLabel()
    }
    
    enum Mode {
        case editLabels, noEditLabels
    }
    
    var body: some View {
        Group {
            if let position = vertexViewModel.getPosition(), let offset = vertexViewModel.getOffset() {
                Group {
                    Circle()
                        .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
#if os(macOS)
                        .frame(width: 20, height: 20)
#elseif os(iOS)
                        .frame(width: 40, height: 40)
#endif
                        .foregroundStyle(vertexViewModel.color)
                    
                    Circle()
                        .stroke(vertexViewModel.strokeColor)
                        .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
#if os(macOS)
                        .frame(width: 20, height: 20)
#elseif os(iOS)
                        .frame(width: 40, height: 40)
#endif
                }
                .onLongPressGesture {
                    isTextFieldFocused = true
                    edittingLabel = true
                }
                
                if !edittingLabel && mode.contains(.showLabels) {
                    #if os(macOS)
                    StrokeText(text: tempLabel, color: labelColor)
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .position(x: vertexViewModel.getPosition()!.x * size.width + vertexViewModel.getOffset()!.width, y: vertexViewModel.getPosition()!.y * size.height + vertexViewModel.getOffset()!.height)
                        .onLongPressGesture {
                            isTextFieldFocused = true
                            edittingLabel = true
                        }
                    #elseif os(iOS)
                    LaTeXView(latex: colorLatexString, size: $latexSize)
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .offset(x: position.x * size.width + offset.width - latexSize.width / 5, y: position.y * size.height + offset.height - latexSize.height / 5)
                        .onLongPressGesture {
                            isTextFieldFocused = true
                            edittingLabel = true
                        }
                    #endif
                } else if mode.contains(.editLabels) {
                    TextField("", text: $tempLabel)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
                        .frame(width: 200, height: 20)
                        .focused($isTextFieldFocused)
#if os(iOS)
                        .keyboardType(UIKeyboardType.default)
#endif
                        .onSubmit {
                            isTextFieldFocused = false
                            edittingLabel = false
                        }
                }
            }
        }
    }
}

#Preview {
    let vertex = Vertex(position: CGPoint(x: 0.5, y: 0.5))
    var graph = Graph(vertices: [vertex], edges: [])
    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: GraphViewModel(graph: graph))
    GeometryReader { geometry in
        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
    }
}
