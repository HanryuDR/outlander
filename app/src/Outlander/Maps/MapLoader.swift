//
//  MapLoader.swift
//  Outlander
//
//  Created by Joe McBride on 1/29/21.
//  Copyright © 2021 Joe McBride. All rights reserved.
//

import Foundation
import Fuzi

enum MapError: Error {
    case fileDoesNotExist(URL)
    case error(Error)
    case xmlError(String)
}

enum MapLoadResult {
    case Success(MapZone)
    case Error(MapError)
}

enum MapMetaResult {
    case Success(MapInfo)
    case Error(MapError)
}

final class MapInfo {
    var id:String
    var name:String
    var file:URL
    var zone:MapZone?
    
    init(_ id: String, name: String, file: URL) {
        self.id = id
        self.name = name
        self.file = file
    }
}

final class MapLoader {
    var files:FileSystem
    
    init(_ files: FileSystem) {
        self.files = files
    }

    func loadMapMeta(atPath: URL) -> [MapMetaResult] {
        let files = self.files.contentsOf(atPath)
        return files.filter { !$0.hasDirectoryPath && $0.lastPathComponent.hasSuffix(".xml") }.map {
            self.loadMeta(fileUrl: $0)
        }
    }

    func loadMeta(fileUrl: URL) -> MapMetaResult {
        guard let data = files.load(fileUrl) else {
            return MapMetaResult.Error(MapError.fileDoesNotExist(fileUrl))
        }

        do {
            let doc = try XMLDocument(data: data)

            let id = doc.root?.attr("id") ?? ""
            let name = doc.root?.attr("name") ?? ""

            return MapMetaResult.Success(
                MapInfo(id, name: name, file: fileUrl)
            )
        } catch {
            return MapMetaResult.Error(MapError.error(error))
        }
    }

    func load(fileUrl: URL) -> MapLoadResult {
        guard let data = files.load(fileUrl) else {
            return MapLoadResult.Error(MapError.fileDoesNotExist(fileUrl))
        }

        do {
            let doc = try XMLDocument(data: data)
            
            guard let root = doc.root else {
                return MapLoadResult.Error(MapError.xmlError("\(fileUrl.absoluteString) has no root!?"))
            }

            let id = root.attr("id")!
            let name = root.attr("name")!

            let mapZone = MapZone(id, name)

            for node in doc.xpath("/zone/node") {
                let desc:[String] = self.descriptions(node)
                let position:MapPosition = self.position(node)
                let arcs:[MapArc] = self.arcs(node)
                let room = MapNode(
                    id: node["id"]!,
                    name: node["name"]!,
                    descriptions: desc,
                    notes: node["note"],
                    color: node["color"],
                    position: position,
                    arcs: arcs
                )
                mapZone.addRoom(room)
            }

            mapZone.labels = doc.xpath("/zone/label").map {
                let text = $0["text"] ?? ""
                let position:MapPosition = self.position($0)
                return MapLabel(text: text, position: position)
            }

            return MapLoadResult.Success(mapZone)
        }
        catch {
            return MapLoadResult.Error(MapError.error(error))
        }
    }

    func descriptions(_ node:Fuzi.XMLElement) -> [String] {
        return node.xpath("description").map {
            return $0.stringValue.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ";", with: "")
        }
    }

    func position(_ node:Fuzi.XMLElement) -> MapPosition {
        if let element = node.firstChild(tag: "position") {
            return MapPosition(x: Int(element["x"]!)!, y: Int(element["y"]!)!, z: Int(element["z"]!)!)
        }
        return MapPosition(x: 0, y: 0, z: 0)
    }
    
    func arcs(_ node:Fuzi.XMLElement) -> [MapArc] {
        return node.xpath("arc").map {
            return MapArc(
                exit: $0["exit"] ?? "",
                move: $0["move"] ?? "",
                destination: $0["destination"] ?? "",
                hidden: $0["hidden"] == "True")
        }
    }
}
