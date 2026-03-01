import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var position = CGPoint(x: 150, y: 300)
    @State private var isGameOver = false
    @State private var message = ""
    @State private var timeLeft = 3
    
    let moveTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            
            ZStack {
                Color.white.ignoresSafeArea()
                
                if !isGameOver {
                    
                    Text("残り \(timeLeft) 秒")
                        .font(.headline)
                        .position(x: geo.size.width / 2, y: 80)
                    
                    Text("💩")
                        .font(.system(size: 80))
                        .position(position)
                        .onTapGesture {
                            message = "捕まえた！！"
                            isGameOver = true
                        }
                        .onReceive(moveTimer) { _ in
                            movePoop(screenSize: geo.size)
                        }
                    
                } else {
                    Text(message)
                        .font(.largeTitle)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .onReceive(gameTimer) { _ in
                if !isGameOver {
                    timeLeft -= 1
                    if timeLeft <= 0 {
                        message = "逃げられた..."
                        isGameOver = true
                    }
                }
            }
        }
    }
    
    func movePoop(screenSize: CGSize) {
        position = CGPoint(
            x: CGFloat.random(in: 50...(screenSize.width - 50)),
            y: CGFloat.random(in: 150...(screenSize.height - 100))
        )
    }
}

#Preview {
    ContentView()
}
