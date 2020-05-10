//
//  Created by Benjohn on 10/05/2020.
//

public protocol SequenceMatching {
    func matches<S: Sequence>(_ s: S) -> Bool where S.Element == Symbol
    associatedtype Symbol
}
