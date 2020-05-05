//
//  Created by Benjohn on 30/04/2020.
//


struct NFA<Symbol> {
    let initialStates: Set<State>
    let activeAcceptance: Set<State>
    let inactiveAcceptance: Set<State>
    
    let activeEdges: [State: SubsequentStates]
    let inactiveEdges: [State: SubsequentStates]
    
    struct SubsequentStates {
        let predicated: [State: [(Symbol) -> Bool]]
        let always: Set<State>
        
        init(predicated: [State: [(Symbol) -> Bool]] = [:], always: Set<State> = Set()) {
            self.predicated = predicated
            self.always = always
        }
    }
    
    class State {}
    
    typealias PredicatedStates = [State: (Symbol) -> Bool]
    typealias MachineState = Set<State>
    
    init(
        initialStates: Set<State>,
        activeAcceptance: Set<State> = Set(),
        inactiveAcceptance: Set<State> = Set(),
        activeEdges: [State: SubsequentStates] = [:],
        inactiveEdges: [State: SubsequentStates] = [:]
    ) {
        self.initialStates = initialStates
        self.activeAcceptance = activeAcceptance
        self.inactiveAcceptance = inactiveAcceptance
        self.activeEdges = activeEdges
        self.inactiveEdges = inactiveEdges
    }
    
    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = initialStates
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
    
    func step(state activeStates: MachineState, with symbol: Symbol) -> MachineState {
        possibleSubsequentStates(followingActiveStates: activeStates).states(enabledFor: symbol)
    }
    
    func stateRepresentsAcceptance(_ activeStates: MachineState) -> Bool {
        activeStates.includesAnyOf(activeAcceptance) || activeStates.missesAnyOf(inactiveAcceptance)
    }
    
    private func possibleSubsequentStates(followingActiveStates activeStates: MachineState) -> SubsequentStates {
        let activated = activeStates.compactMap { activeEdges[$0] }
        let innactivated = inactiveEdges.compactMap { activeStates.contains($0.key) ? nil : $0.value }
        return (activated + innactivated).reduce(SubsequentStates()) { $0.merging($1) }
    }
}

// MARK:-

extension NFA {
    
    static var everything: NFA {
        let initial = NFA.State()
        return NFA(
            initialStates: Set([initial]),
            activeAcceptance: Set([initial]),
            activeEdges: [initial: SubsequentStates(predicated: [initial: [{ _ in true }]])]
        )
    }
    
    static var nothing: NFA {
        !everything
    }
    
    static func match(one predicate: @escaping (Symbol) -> Bool) -> NFA {
        let startState = NFA.State()
        let acceptState = NFA.State()
        
        return NFA(
            initialStates: Set([startState]),
            activeAcceptance: Set([acceptState]),
            activeEdges: [startState: SubsequentStates(predicated: [acceptState: [predicate]])]
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        .init(
            initialStates: l.initialStates.union(r.initialStates),
            activeAcceptance: l.activeAcceptance.union(r.activeAcceptance),
            inactiveAcceptance: l.inactiveAcceptance.union(r.inactiveAcceptance),
            activeEdges: l.activeEdges.merging(r.activeEdges, uniquingKeysWith: { $0.merging($1) }),
            inactiveEdges: l.inactiveEdges.merging(r.inactiveEdges, uniquingKeysWith: { $0.merging($1) })
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !(!l | !r)
    }


    static prefix func !(_ nfa: NFA) -> NFA {
        .init(
            initialStates: nfa.initialStates,
            activeAcceptance: nfa.inactiveAcceptance,
            inactiveAcceptance: nfa.activeAcceptance,
            activeEdges: nfa.activeEdges,
            inactiveEdges: nfa.inactiveEdges
        )
    }
    
    func then(_ next: NFA) -> NFA {
        return self
    }
}

// MARK:-

extension NFA.SubsequentStates {
    
    func states(enabledFor symbol: Symbol) -> Set<NFA.State> {
        Set(predicated.compactMap { stateAndPredicates in
            guard stateAndPredicates.value.first(where: { $0(symbol) }) != nil else { return nil }
            return stateAndPredicates.key
        })
    }
    
    func merging(_ other: NFA.SubsequentStates) -> NFA.SubsequentStates {
        NFA.SubsequentStates(
            predicated: predicated.merging(other.predicated, uniquingKeysWith: +)
        )
    }
}

// MARK:-

extension NFA.State: Hashable {
    
    static func == (lhs: NFA<Symbol>.State, rhs: NFA<Symbol>.State) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

extension Set {
    func includesAnyOf(_ other: Set) -> Bool {
        !intersection(other).isEmpty
    }
    
    func missesAnyOf(_ other: Set) -> Bool {
        intersection(other).count < other.count
    }
}
