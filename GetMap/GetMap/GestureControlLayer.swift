//
//  GestureControlLayer.swift
//  GetMap
//
//  Created by wanruuu on 25/10/2020.
//

import Foundation
import SwiftUI

struct PanInfo {
    var offset: CGPoint
    var moving: Bool
}

struct GestureControlLayer: UIViewRepresentable {
    //var tappedCallback: ((CGPoint) -> Void)
    var pannedCallback: ((PanInfo) -> Void)
    //var pinchedCallback: ((CGFloat) -> Void)
    /* render */
    func makeUIView(context: UIViewRepresentableContext<GestureControlLayer>) -> UIView {
        let view = UIView(frame: .zero)
        /* tap gesture */
        //let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        //view.addGestureRecognizer(tap)
        /* pan gesture */
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panned))
        view.addGestureRecognizer(pan)
        /* pinch gesture */
        //let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pinched))
        //view.addGestureRecognizer(pinch)
        return view
    }
    class Coordinator: NSObject {
        //var tappedCallback: ((CGPoint) -> Void)
        var pannedCallback: ((PanInfo) -> Void)
        //var pinchedCallback: ((CGFloat) -> Void)
        init(/*tappedCallback: @escaping ((CGPoint) -> Void), */pannedCallback: @escaping ((PanInfo) -> Void)/*, pinchedCallback: @escaping ((CGFloat) -> Void)*/) {
            //self.tappedCallback = tappedCallback
            self.pannedCallback = pannedCallback
            // self.pinchedCallback = pinchedCallback
        }
        /* @objc func tapped(gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            self.tappedCallback(point)
        }*/
        @objc func panned(gesture: UIPanGestureRecognizer) {
            let offset = gesture.translation(in: gesture.view)
            let status = !(gesture.state == UIGestureRecognizer.State.ended)
            self.pannedCallback(PanInfo(offset: offset, moving: status))
        }
        /*@objc func pinched(gesture: UIPinchGestureRecognizer) {
            let scale = gesture.scale
            self.pinchedCallback(scale)
            print(scale)
        }*/
    }
    func makeCoordinator() -> GestureControlLayer.Coordinator {
        return Coordinator(/*tappedCallback: self.tappedCallback, */pannedCallback: self.pannedCallback/*, pinchedCallback: self.pinchedCallback*/)
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GestureControlLayer>) {}
}
