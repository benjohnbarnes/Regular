//
//  Created by Benjohn on 15/05/2020.
//

import Foundation

struct EpsilonEdges {
    let activeEdges: [Node: Set<Node>]
    let innactiveEdges: [Node: Set<Node>]

    init() {
        self.init(
            activeEdges: [:],
            innactiveEdges: [:]
        )
    }
    
    init<S: Sequence>(_ s: S) where S.Element == (Node, Node) {
        self.init(
            activeEdges: Dictionary(grouping: s, by: { $0.0 }).mapValues { Set($0.map { $0.1 }) },
            innactiveEdges: [:]
        )
    }

    private init(
        activeEdges: [Node: Set<Node>],
        innactiveEdges: [Node: Set<Node>]
    ) {
        let closeNodes = fix { nodes -> Set<Node> in nodes.union(nodes.flatMap { activeEdges[$0] ?? [] }) }        
        self.activeEdges = activeEdges.mapValues(closeNodes)
        self.innactiveEdges = innactiveEdges
    }
}

extension EpsilonEdges {
 
    static func +(_ l: EpsilonEdges, _ r: EpsilonEdges) -> EpsilonEdges {
        EpsilonEdges(
            activeEdges: l.activeEdges.merging(r.activeEdges, uniquingKeysWith: { $0.union($1) }),
            innactiveEdges: l.innactiveEdges.merging(r.innactiveEdges, uniquingKeysWith: { $0.union($1) })
        )
    }
    
    func merging(_ edges: EpsilonEdges) -> EpsilonEdges {
        self + edges
    }
    
    var inverted: EpsilonEdges {
        .init(activeEdges: innactiveEdges, innactiveEdges: activeEdges)
    }

    func propagate(state: Set<Node>) -> Set<Node> {
        propagatePositiveEdges(propagateNegativeEdges(propagatePositiveEdges(state)))
    }
    
    private func propagatePositiveEdges(_ nodes: Set<Node>) -> Set<Node> {
        var nodes = nodes
        for node in nodes {
            guard let moreNode = activeEdges[node] else { continue }
            nodes.formUnion(moreNode)
        }
        
        return nodes
    }

    private func propagateNegativeEdges(_ nodes: Set<Node>) -> Set<Node> {
        nodes.union(innactiveEdges.flatMap { innactiveRecord -> [Node] in
            guard nodes.contains(innactiveRecord.key) == false else { return [] }
            return Array(innactiveRecord.value)
        })
    }
}

// MARK:-

func fix<T: Equatable>(_ transform: @escaping (T) -> T) -> (T) -> T {
    
    return { (t: T) -> T in
        var current = t

        while true {
            let next = transform(current)
            guard next != current else { break }
            current = next
        }
        
        return current
    }
}
