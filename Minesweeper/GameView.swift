//
//  GameView.swift
//  Minesweeper
//
//  Created by Alain Gilbert on 3/10/18.
//  Copyright © 2018 None. All rights reserved.
//

import Foundation
import AppKit

@IBDesignable
class GameView : NSView {
    
    enum State {
        case Waiting
        case GameOver
        case Win
        case Playing
    }
    
    var flagsLbL: NSTextField = NSTextField()
    var timerLbl: NSTextField = NSTextField()
    
    var timer = Timer()
    var seconds = 0
    var flags = 0
    let tileSize = 40
    let nbMines = 50
    let nbHorizontalTiles = 19
    let nbVerticalTiles = 13
    var state = State.Waiting
    var data: [Bool] = Array(repeating: false, count: 19*13)
    var tiles: [Tile] = []
    var safe: Int = 0
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        for i in 0..<nbTiles() {
            let (x, y) = coordFromIdx(i)
            let t = Tile(x: x, y: y, size: tileSize)
            tiles.append(t)
        }
    }
    
    func horizontalSize() -> Int {
        return nbHorizontalTiles * tileSize
    }
    
    func verticalSize() -> Int {
        return nbVerticalTiles * tileSize
    }
    
    func nbTiles() -> Int {
        return nbHorizontalTiles * nbVerticalTiles
    }
    
    func reset() {
        seconds = 0
        safe = 0
        flags = 0
        flagsLbL.stringValue = "Flags: 0/50"
        timerLbl.stringValue = "Time: 0"
        for i in 0..<nbTiles() {
            data[i] = false
            tiles[i].state = .Empty
        }
    }
    
    func idxFromCoordinate(_ x: Int, _ y: Int) -> Int {
        return y * nbHorizontalTiles + x
    }
    
    func coordFromIdx(_ idx: Int) -> (Int, Int) {
        let y = idx / nbHorizontalTiles
        let x = idx - y * nbHorizontalTiles
        return (x, y)
    }

    func coordFromPoint(_ point: NSPoint) -> (Int, Int) {
        let x = Int(floor(point.x / CGFloat(tileSize)))
        let y = Int(floor((point.y - 20) / CGFloat(tileSize)))
        return (x, y)
    }

    func neighborIdx(_ idx: Int) -> [Int] {
        let (x, y) = coordFromIdx(idx)
        let neighbors = neighborCoord(x: x, y: y)
        var res: [Int] = []
        for (nx, ny) in neighbors {
            res.append(idxFromCoordinate(nx, ny))
        }
        return res
    }
    
    func around(idx: Int, x: Int, y: Int) -> Bool {
        let initialClickPosition = idxFromCoordinate(x, y)
        let neighborsIndexes = neighborIdx(initialClickPosition)
        return neighborsIndexes.firstIndex(of: idx) != nil ||
               idx == initialClickPosition ||
               isMine(idx)
    }
    
    func initBoard(x: Int, y: Int) {
        var val = 0
        for _ in 0..<nbMines {
            while true {
                val = Int(arc4random_uniform(UInt32(nbTiles())))
                if !around(idx: val, x: x, y: y) {
                    break
                }
            }
            data[val] = true
        }
    }
    
    func isMine(_ idx: Int) -> Bool {
        return data[idx]
    }
    
    func isFlag(_ idx: Int) -> Bool {
        return tiles[idx].state == .Flagged
    }
    
    func showMines(deadIdx: Int) {
        for i in 0..<tiles.count {
            if i == deadIdx {
                tiles[i].state = .ExplodedMine
            } else if isMine(i) && isFlag(i) {
                tiles[i].state = .FlaggedMine
            } else if isFlag(i) {
                tiles[i].state = .BadFlag
            } else if isMine(i) {
                tiles[i].state = .Mine
            }
        }
    }
    
    func gameOver(idx: Int) {
        state = State.GameOver
        showMines(deadIdx: idx);
    }
    
    func win(ctx: CGContext) {
        showMines(deadIdx: -1)
        ctx.saveGState()
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addLine(to: CGPoint(x: horizontalSize(), y: 0))
        ctx.addLine(to: CGPoint(x: horizontalSize(), y: verticalSize()))
        ctx.addLine(to: CGPoint(x: 0, y: verticalSize()))
        ctx.addLine(to: CGPoint(x: 0, y: 0))
        ctx.fillPath()
        ctx.restoreGState()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let label = "Win"
        let font = NSFont(name: "Arial", size: 40)!
        let attrs = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: NSColor(calibratedRed: 0, green: 0.502, blue: 0, alpha: 1),
            ]
        label.draw(with: CGRect(x: 0, y: ((verticalSize()) + 40) / 2, width: horizontalSize(), height: 40), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    func isValidPosition(x: Int, y: Int) -> Bool {
        return x >= 0 && x < nbHorizontalTiles &&
               y >= 0 && y < nbVerticalTiles
    }
    
    func neighborCoord(x: Int, y: Int) -> [(Int, Int)] {
        var res: [(Int, Int)] = []
        for dx in -1...1 {
            for dy in -1...1 {
                if (dx != 0 || dy != 0) && isValidPosition(x: x + dx, y: y + dy) {
                    res.append((x + dx, y + dy))
                }
            }
        }
        return res
    }
    
    func countMinesAround(x: Int, y: Int) -> Int {
        var nbMines = 0
        for (nx, ny) in neighborCoord(x: x, y: y) {
            if isMine(idxFromCoordinate(nx, ny)) {
                nbMines += 1
            }
        }
        return nbMines
    }
    
    func countFlagsAround(x: Int, y: Int) -> Int {
        var nbFlags = 0
        for (nx, ny) in neighborCoord(x: x, y: y) {
            if isFlag(idxFromCoordinate(nx, ny)) {
                nbFlags += 1
            }
        }
        return nbFlags
    }
    
    func showTile(x: Int, y: Int) -> Int {
        let tileIdx = idxFromCoordinate(x, y)
        let tile = tiles[tileIdx]
        
        if tile.state == .Discovered || tile.state == .Flagged || tile.state == .BadFlag || tile.state == .FlaggedMine {
            return 0
        }
        if isMine(tileIdx) {
            gameOver(idx: tileIdx)
            return 0
        }
        
        let nbMinesAround = countMinesAround(x: x, y: y)
        var safe = 1
        tile.minesAround = nbMinesAround
        tile.state = .Discovered
        
        if nbMinesAround == 0 {
            for (nx, ny) in neighborCoord(x: x, y: y) {
                safe += showTile(x: nx, y: ny)
            }
        }
        return safe
    }
    
    func toggleFlag(x: Int, y: Int) {
        let tileIdx = idxFromCoordinate(x, y)
        let tile = tiles[tileIdx]
        if tile.state == .Empty {
            tile.state = .Flagged
            flags += 1
        } else if tile.state == .Flagged {
            tile.state = .Empty
            flags -= 1
        }
        flagsLbL.stringValue = String(format: "Flags: %d/50", flags)
    }
    
    @objc func updateTimer() {
        seconds += 1
        timerLbl.stringValue = String(format: "Time: %d", seconds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);
        NSColor.white.setFill()
        dirtyRect.fill()
        if let ctx = NSGraphicsContext.current?.cgContext {
            for i in 0...nbTiles()-1 {
                tiles[i].render(ctx: ctx)
            }
            if state == .Win {
                win(ctx: ctx)
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if (event.modifierFlags.contains(.command)) {
            rightMouseUp(with: event)
            return
        }
        
        super.mouseUp(with: event)
        
        let (tileX, tileY) = coordFromPoint(event.locationInWindow)
        let tileIdx = idxFromCoordinate(tileX, tileY)
        let tile = tiles[tileIdx]
        if state == State.Waiting {
            initBoard(x: tileX, y: tileY)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
            state = .Playing
        }
        
        if state == .Playing {
            var tilesToShow = [(tileX, tileY)]
            if tile.state == .Discovered && countFlagsAround(x: tileX, y: tileY) == countMinesAround(x: tileX, y: tileY) {
                tilesToShow.append(contentsOf: neighborCoord(x: tileX, y: tileY))
            }
            for el in tilesToShow {
                safe += showTile(x: el.0, y: el.1)
            }
            if safe == tiles.count - nbMines {
                state = .Win
            }
        } else if state == .GameOver || state == .Win {
            reset()
            state = .Waiting
        }
        
        if state == .GameOver || state == .Win {
            timer.invalidate()
        }
        
        self.setNeedsDisplay(NSRect(x: 0, y: 0, width: horizontalSize(), height: verticalSize()))
    }
    
    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        let (tileX, tileY) = coordFromPoint(event.locationInWindow)
        if state == .Playing {
            toggleFlag(x: tileX, y: tileY)
        }
        self.setNeedsDisplay(NSRect(x: 0, y: 0, width: horizontalSize(), height: verticalSize()))
    }
}
