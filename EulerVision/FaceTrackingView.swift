//
//  FaceTrackingView.swift
//  EulerVision
//
//  Created by Alexander on 29.04.2025.
//

import SwiftUI
import ARKit
import SceneKit

struct FaceTrackingView: UIViewRepresentable {
    @Binding var pitch: Double
    @Binding var yaw: Double
    @Binding var roll: Double

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator

        let config = ARFaceTrackingConfiguration()
        arView.session.run(config, options: [])

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // do nothing
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(pitch: $pitch, yaw: $yaw, roll: $roll)
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        @Binding var pitch: Double
        @Binding var yaw: Double
        @Binding var roll: Double
        private var axisNode: SCNNode?
        private var faceNode: SCNNode?

        init(pitch: Binding<Double>, yaw: Binding<Double>, roll: Binding<Double>) {
            _pitch = pitch
            _yaw = yaw
            _roll = roll
        }

        // Добавляем ось при создании ARFaceAnchor
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor else { return }

            self.faceNode = node

            // Создаем ось только один раз
            if axisNode == nil {
                axisNode = createAxisNode()
                node.addChildNode(axisNode!) // Добавляем ось к узлу лица
            }
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }

            // Извлекаем углы Эйлера из transform матрицы
            let rotation = SCNMatrix4(faceAnchor.transform)
            let eulerAngles = rotation.eulerAngles

            // Конвертируем в градусы и обновляем @Binding
            DispatchQueue.main.async {
                self.pitch = Double(eulerAngles.x * 180 / .pi)
                self.yaw = Double(eulerAngles.y * 180 / .pi)
                self.roll = Double(eulerAngles.z * 180 / .pi)
            }

            // Поворачиваем ось
            axisNode?.eulerAngles = SCNVector3(eulerAngles.x, eulerAngles.y, eulerAngles.z)

            if axisNode?.parent == nil, let faceNode = self.faceNode {
                faceNode.addChildNode(axisNode!)
            }
        }

        // Создаем 3D-ось
        private func createAxisNode() -> SCNNode {
            let axisNode = SCNNode()

            // Ось X (Красная)
            let xAxis = SCNNode(geometry: SCNCylinder(radius: 0.005, height: 0.3))
            xAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            xAxis.position = SCNVector3(0.15, 0, 0)
            xAxis.eulerAngles.z = .pi / 2
            axisNode.addChildNode(xAxis)

            // Ось Y (Зеленая)
            let yAxis = SCNNode(geometry: SCNCylinder(radius: 0.005, height: 0.3))
            yAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            yAxis.position = SCNVector3(0, 0.15, 0)
            axisNode.addChildNode(yAxis)

            // Ось Z (Синяя)
            let zAxis = SCNNode(geometry: SCNCylinder(radius: 0.005, height: 0.3))
            zAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            zAxis.position = SCNVector3(0, 0, 0.15)
            zAxis.eulerAngles.x = .pi / 2
            axisNode.addChildNode(zAxis)

            // Сфера (центр)
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.03))
            sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            axisNode.addChildNode(sphere)

            return axisNode
        }
    }
}

// Расширение для извлечения углов Эйлера из SCNMatrix4
extension SCNMatrix4 {
    var eulerAngles: SCNVector3 {
        // Извлекаем углы из матрицы вращения
        let sy = sqrt(m11*m11 + m12*m12)
        let singular = sy < 1e-6

        var x: CGFloat, y: CGFloat, z: CGFloat
        if !singular {
            x = CGFloat(atan2(m23, m33))
            y = CGFloat(atan2(-m13, sy))
            z = CGFloat(atan2(m12, m11))
        } else {
            x = CGFloat(atan2(-m32, m22))
            y = CGFloat(atan2(-m13, sy))
            z = 0
        }

        return SCNVector3(x, y, z)
    }
}
