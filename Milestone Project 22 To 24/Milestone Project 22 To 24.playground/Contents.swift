//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UIView {
    func bounceOut(duration: CGFloat) {
        UIView.animate(withDuration: TimeInterval(duration)) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

extension Array where Element: Comparable {
    
    mutating func remove(item: Element) {
        guard let index = self.firstIndex(of: item) else {
            return
        }

        self.remove(at: index)
    }
}

extension Int {
    func times(_ closure: () -> Void) {
        for _ in 0..<self {
            closure()
        }
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view

        label.bounceOut(duration: 3)
        5.times { print("Hellox!") }
        
        var arrayInt = [1, 2, 3, 3, 2, 1]
        arrayInt.remove(item: 2)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
