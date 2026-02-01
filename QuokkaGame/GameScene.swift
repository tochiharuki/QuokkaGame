import UIKit
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let wallaby = SKSpriteNode(imageNamed: "wallaby_run")
    let worldNode = SKNode()
    let initialScroll: CGFloat = 500
    // 柱を配列で管理
    var pillars: [SKSpriteNode] = []

    var isJumping = false
    var scrollSpeed: CGFloat = 2.0
    let scrollAcceleration: CGFloat = 0.002
    let pillarSpacing: CGFloat = 180
    var jumpPowerMultiplier: CGFloat = 1.0
    let jumpPowerIncreaseRate: CGFloat = 0.0008
    let maxJumpPowerMultiplier: CGFloat = 1.4

    // ジャンプチャージ関連
    private var isChargingJump = false
    private var touchStartTime: TimeInterval?
    private let minChargeDuration: TimeInterval = 0.05   // 最短チャージ時間
    private let maxChargeDuration: TimeInterval = 0.8    // 最長チャージ時間（これ以上は強くならない）
    private let minImpulse = CGVector(dx: 30, dy: 300)   // 最小インパルス
    private let maxImpulse = CGVector(dx: 50, dy: 500)   // 最大インパルス

    override func didMove(to view: SKView) {
        backgroundColor = .cyan
        addChild(worldNode)
        worldNode.position.x = -initialScroll
        backgroundColor = .cyan
        // 柱を2本作成
        for i in 0..<5 {
            let pillar = SKSpriteNode(color: .brown,
                                      size: CGSize(width: 80, height: 300))
            pillar.position = CGPoint(
                x: size.width + CGFloat(i) * pillarSpacing,
                y: 150
            )
            pillar.physicsBody = SKPhysicsBody(rectangleOf: pillar.size)
            pillar.physicsBody?.isDynamic = false
            worldNode.addChild(pillar)
            pillars.append(pillar)
        }

        // ワラビー
        wallaby.position = CGPoint(
            x: initialScroll + 280,
            y: pillars[0].position.y + pillars[0].size.height / 2 + 40
        )
        wallaby.setScale(0.1)
        wallaby.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: wallaby.size.width * 0.6,
                height: wallaby.size.height * 0.6
            )
        )
        wallaby.physicsBody?.allowsRotation = false
        worldNode.addChild(wallaby)

        physicsWorld.gravity = CGVector(dx: 0, dy: -30)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 地上にいるときのみチャージ開始
        if !isJumping {
            isChargingJump = true
            touchStartTime = touches.first?.timestamp
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isChargingJump, !isJumping else {
            // チャージしていない、または既にジャンプ中なら何もしない
            isChargingJump = false
            touchStartTime = nil
            return
        }

        let endTime = touches.first?.timestamp ?? CACurrentMediaTime()
        let startTime = touchStartTime ?? endTime
        var duration = endTime - startTime

        // チャージ時間をクランプ
        duration = max(minChargeDuration, min(duration, maxChargeDuration))

        // 0.0〜1.0 に正規化
        let t = (duration - minChargeDuration) / (maxChargeDuration - minChargeDuration)

        // 線形補間でインパルスを決定
        let dx = minImpulse.dx + CGFloat(t) * (maxImpulse.dx - minImpulse.dx)
        let dy = minImpulse.dy + CGFloat(t) * (maxImpulse.dy - minImpulse.dy)
        let impulse = CGVector(dx: dx, dy: dy)

        wallaby.physicsBody?.applyImpulse(impulse)
        isJumping = true
        isChargingJump = false
        touchStartTime = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    override func update(_ currentTime: TimeInterval) {
        scrollSpeed += scrollAcceleration   // ← 毎フレーム少しずつ加速
        jumpPowerMultiplier = min(
        jumpPowerMultiplier + jumpPowerIncreaseRate,
            maxJumpPowerMultiplier
        )


        worldNode.position.x -= scrollSpeed

        for pillar in pillars {
            // 柱の画面上のX座標
            let pillarScreenX = pillar.position.x + worldNode.position.x

            // 完全に画面左に出たら再配置
            if pillarScreenX < -pillar.size.width {

                // 画面右端の world 座標
                let screenRightWorldX = -worldNode.position.x + size.width

                // 画面外から出現させる
                pillar.position.x = screenRightWorldX + pillarSpacing
            }
        }
        // 接地判定（仮）
        if let basePillar = pillars.first,
           wallaby.position.y <= basePillar.position.y + basePillar.size.height / 2 + 40 {
            isJumping = false
            // 地上に戻ったらチャージ状態は解除
            if !isChargingJump {
                touchStartTime = nil
            }
        }
    }
}

