import Foundation

@available(iOS 13, macOS 10.15, tvOS 10, *)
@propertyWrapper
public class Atomic<T> {
    public var wrappedValue: T {
        get { return _lock.locked { return _value } }
        set { _lock.locked { _value = newValue } }
    }

    private var _value: T
    private let _lock = Lock()

    public init(_ initialValue: T) {
        _value = initialValue
    }
}

@available(iOS 13, macOS 10.15, tvOS 10, *)
private final class Lock {
    private var _lock: UnsafeMutablePointer<os_unfair_lock>

    init() {
        _lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        _lock.initialize(to: os_unfair_lock())
    }

    deinit {
        _lock.deallocate()
    }

    func locked<T>(_ block: () -> T) -> T {
        os_unfair_lock_lock(_lock)
        defer { os_unfair_lock_unlock(_lock) }
        return block()
    }
}
