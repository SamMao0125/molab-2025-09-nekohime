import SwiftUI

struct ContentView: View {
    let colors = [Color.red, Color.blue, Color.green, Color.orange, Color.purple]
    
    var body: some View {
        Canvas { context, size in
            let gridSize = 8
            let cellWidth = size.width / Double(gridSize)
            let cellHeight = size.height / Double(gridSize)
            
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    let x = Double(col) * cellWidth
                    let y = Double(row) * cellHeight
                    let randomColor = colors.randomElement()!
                    let circleSize = min(cellWidth, cellHeight) * 0.8
                    
                    let circle = Path { path in
                        path.addEllipse(in: CGRect(
                            x: x + (cellWidth - circleSize) / 2,
                            y: y + (cellHeight - circleSize) / 2,
                            width: circleSize,
                            height: circleSize
                        ))
                    }
                    
                    context.fill(circle, with: .color(randomColor))
                }
            }
        }
        .background(Color.white)
    }
}

#Preview {
    ContentView()
}
