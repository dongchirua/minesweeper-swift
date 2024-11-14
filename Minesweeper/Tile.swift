//
//  Tile.swift
//  Minesweeper
//
//  Created by Alain Gilbert on 3/10/18.
//  Copyright © 2018 None. All rights reserved.
//

import Foundation
import AppKit

class Tile {
    enum State {
        case Empty, Discovered, Flagged, BadFlag, ExplodedMine, Mine, FlaggedMine
    }
    
    enum TileColor {
        static let empty = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        static let flagged = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let mineStroke = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        static let mineNormal = CGColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        static let mineExploded = CGColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        static let discovered = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        static let stroke = CGColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1)
    }
    
    let size: Int
    var x: Int
    var y: Int
    var state = State.Empty
    var isMine = false
    var minesAround = 0
    
    init(x: Int, y: Int, size: Int) {
        self.x = x
        self.y = y
        self.size = size
    }
    
    func discover(_ nbMinesAround: Int) {
        minesAround = nbMinesAround
        state = .Discovered
    }
    
    func tileDrawWrapper(_ ctx: CGContext, _ clb: () -> Void) {
        ctx.saveGState()
        ctx.translateBy(x: CGFloat(x * size), y: CGFloat(y * size))
        clb()
        ctx.restoreGState()
    }
    
    func renderEmpty(_ ctx: CGContext) {
        tileDrawWrapper(ctx, {
            let sizef = CGFloat(size)
            ctx.setLineWidth(1)
            ctx.setFillColor(TileColor.empty)
            ctx.setStrokeColor(TileColor.stroke)
            ctx.move(to: CGPoint(x: 0, y: 0))
            ctx.addLine(to: CGPoint(x: sizef, y: 0))
            ctx.addLine(to: CGPoint(x: sizef, y: sizef))
            ctx.addLine(to: CGPoint(x: 0, y: sizef))
            ctx.addLine(to: CGPoint(x: 0, y: 0))
            ctx.drawPath(using: .fillStroke)
        })
    }
    
    func renderFlag(_ ctx: CGContext) {
        tileDrawWrapper(ctx, {
            let sizef = CGFloat(size)
            // Red flag
            ctx.setFillColor(TileColor.flagged)
            ctx.move(to: CGPoint(x: sizef/3.0, y: sizef/2.0))
            ctx.addLine(to: CGPoint(x: sizef/3.0*2, y: sizef/3.0))
            ctx.addLine(to: CGPoint(x: sizef/3.0*2, y: sizef/3.0*2))
            ctx.fillPath()
            // Black pole
            ctx.setLineWidth(2)
            ctx.setStrokeColor(CGColor.black)
            ctx.move(to: CGPoint(x: sizef/3.0*2, y: sizef-sizef/3.0))
            ctx.addLine(to: CGPoint(x: sizef/3.0*2, y: sizef/4.0))
            ctx.addLine(to: CGPoint(x: sizef/2.0, y: sizef/4.0))
            ctx.addLine(to: CGPoint(x: sizef-sizef/5.0, y: sizef/4.0))
            ctx.strokePath()
        })
    }
    
    func renderMine(_ ctx: CGContext, exploded: Bool) {
        tileDrawWrapper(ctx, {
            let normalColor = TileColor.mineNormal
            let explodedColor = TileColor.mineExploded
            let sizef = CGFloat(size)
            ctx.setStrokeColor(TileColor.mineStroke)
            ctx.setFillColor(exploded ? explodedColor : normalColor)
            ctx.addArc(center: CGPoint(x: sizef/2, y: sizef/2), radius: sizef/4, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            ctx.drawPath(using: .fillStroke)
        })
    }
    
    func renderCross(_ ctx: CGContext) {
        tileDrawWrapper(ctx, {
            let sizef = CGFloat(size)
            ctx.setStrokeColor(CGColor.black)
            ctx.setLineWidth(2)
            ctx.move(to: CGPoint(x: sizef/5, y: sizef/5))
            ctx.addLine(to: CGPoint(x: sizef-sizef/5, y: sizef-sizef/5))
            ctx.move(to: CGPoint(x: sizef/5, y: sizef-sizef/5))
            ctx.addLine(to: CGPoint(x: sizef-sizef/5, y: sizef/5))
            ctx.strokePath()
        })
    }
    
    func renderDiscovered(_ ctx: CGContext) {
        tileDrawWrapper(ctx, {
            let sizef = CGFloat(size)
            ctx.setLineWidth(1)
            ctx.setFillColor(TileColor.discovered)
            ctx.setStrokeColor(TileColor.stroke)
            ctx.move(to: CGPoint(x: 0, y: 0))
            ctx.addLine(to: CGPoint(x: sizef, y: 0))
            ctx.addLine(to: CGPoint(x: sizef, y: sizef))
            ctx.addLine(to: CGPoint(x: 0, y: sizef))
            ctx.addLine(to: CGPoint(x: 0, y: 0))
            ctx.drawPath(using: .fillStroke)
        })
        
        if minesAround == 0 {
            return
        }
        
        let colors = [
            NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 1),         // Blue
            NSColor(calibratedRed: 0, green: 0.502, blue: 0, alpha: 1),     // Green
            NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1),         // Red
            NSColor(calibratedRed: 0, green: 0, blue: 0.502, alpha: 1),     // Navy
            NSColor(calibratedRed: 0.502, green: 0, blue: 0, alpha: 1),     // Maroon
            NSColor(calibratedRed: 0, green: 1, blue: 1, alpha: 1),         // Aqua
            NSColor(calibratedRed: 0.502, green: 0, blue: 0.502, alpha: 1), // Purple
            NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1),         // Black
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Arial", size: 38)!,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: colors[minesAround-1],
        ]
        String(minesAround).draw(with: CGRect(x: x*size, y: y*size, width: size, height: size), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    func render(ctx: CGContext) {
        switch state {
        case .Empty:
            renderEmpty(ctx)
        case .Flagged:
            renderEmpty(ctx)
            renderFlag(ctx)
        case .Discovered:
            renderDiscovered(ctx)
        case .ExplodedMine:
            renderEmpty(ctx)
            renderMine(ctx, exploded: true)
        case .BadFlag:
            renderEmpty(ctx)
            renderFlag(ctx)
            renderCross(ctx)
        case .Mine:
            renderEmpty(ctx)
            renderMine(ctx, exploded: false)
        case .FlaggedMine:
            renderEmpty(ctx)
            renderMine(ctx, exploded: false)
            renderFlag(ctx)
        }
    }
}
