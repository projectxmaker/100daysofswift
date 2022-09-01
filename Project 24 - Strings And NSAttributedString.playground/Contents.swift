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
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let carPet = "pet".withPrefix("car")
        print(carPet)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
