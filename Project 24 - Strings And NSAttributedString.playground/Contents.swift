//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension String {
    func withPrefix(_ prefix: String) -> String {
        var finalString = self
        if !self.hasPrefix(prefix) {
            finalString = prefix + self
        }
        
        return finalString
    }
    
    func isNumeric() -> Bool {
        guard let number = Double(self) else { return false }
        
        return true
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let carPet = "pet".withPrefix("car")
        print(carPet)
        
        print("x3x".isNumeric() ? "yes" : "no")
        print("30".isNumeric() ? "yes" : "no")
        print("30.4".isNumeric() ? "yes" : "no")
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
