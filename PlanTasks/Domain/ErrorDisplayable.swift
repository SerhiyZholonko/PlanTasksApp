import Foundation

protocol ErrorDisplayable: AnyObject {
    var error: Error? { get set }
}
