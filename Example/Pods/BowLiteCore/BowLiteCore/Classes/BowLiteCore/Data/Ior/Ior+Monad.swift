public extension Ior where Left: Semigroup {
    /// Sequentially compose two computations, passing any value produced by the first as an argument to the second.
    ///
    /// - Parameters:
    ///   - f: A function describing the second computation, which depends on the value of the first.
    /// - Returns: Result of composing the two computations.
    func flatMap<A>(_ f: @escaping (Right) -> Ior<Left, A>) -> Ior<Left, A> {
        fold(
            Ior<Left, A>.left,
            f,
            { l, r in
                f(r).fold(
                    { l2 in Ior<Left, A>.left(l.combine(l2)) },
                    Ior<Left, A>.right,
                    { l2, r2 in Ior<Left, A>.both(l.combine(l2), r2) })
            }
        )
    }
    
    /// Flattens this nested structure into a single layer.
    ///
    /// - Returns: Value with a single context structure.
    func flatten<A>() -> Ior<Left, A> where Right == Ior<Left, A> {
        self.flatMap(id)
    }
    
    /// Sequentially compose two computations, discarding the value produced by the first.
    ///
    /// - Parameters:
    ///   - fa: 2nd computation.
    /// - Returns: Result of running the second computation after the first one.
    func followedBy<A>(_ fa: Ior<Left, A>) -> Ior<Left, A> {
        self.flatMap(constant(fa))
    }
    
    /// Sequentially compose two computations, discarding the value produced by the second.
    ///
    /// - Parameters:
    ///   - fa: 2nd computation.
    /// - Returns: Result produced from the first computation after both are computed.
    func forEffect<A>(_ fa: Ior<Left, A>) -> Ior<Left, Right> {
        self.flatMap { wrapped in fa.as(wrapped) }
    }
    
    /// Pair the result of a computation with the result of applying a function to such result.
    ///
    /// - Parameters:
    ///   - f: A function to be applied to the result of the computation.
    /// - Returns: A tuple of the result of the computation paired with the result of the function, in this context.
    func mproduct<A>(_ f: @escaping (Right) -> Ior<Left, A>) -> Ior<Left, (Right, A)> {
        self.flatMap { wrapped in
            f(wrapped).tupleLeft(wrapped)
        }
    }
    
    /// Conditionally apply a closure based on the boolean result of this computation.
    ///
    /// - Parameters:
    ///   - then: Closure to be applied if the computation evaluates to `true`.
    ///   - else: Closure to be applied if the computation evaluates to `false`.
    /// - Returns: Result of applying the corresponding closure based on the result of the computation.
    func `if`<A>(
        then f: @escaping () -> Ior<Left, A>,
        else g: @escaping () -> Ior<Left, A>
    ) -> Ior<Left, A> where Right == Bool {
        self.flatMap { boolean in
            boolean ? f() : g()
        }
    }
    
    /// Applies a monadic function and discard the result while keeping the effect.
    ///
    /// - Parameters:
    ///   - f: A monadic function which result will be discarded.
    /// - Returns: A computation with the result of the initial computation and the effect caused by the function application.
    func flatTap<A>(_ f: @escaping (Right) -> Ior<Left, A>) -> Ior<Left, Right> {
        self.flatMap { wrapped in f(wrapped).as(wrapped) }
    }
}
