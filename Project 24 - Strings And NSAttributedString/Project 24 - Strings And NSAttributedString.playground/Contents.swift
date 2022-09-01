//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension String {
    // challenge #1: method withPrefix | "pet".prefix("car") -> "carpet"
    func withPrefix(_ prefix: String) -> String {
        var finalString = self
        if !self.hasPrefix(prefix) {
            finalString = prefix + self
        }
        
        return finalString
    }
    
    // challenge #2: isNumber property to return true if the string holds any sort of number
    var isNumeric: Bool {
        get {
            guard let _ = Double(self) else { return false }
            
            return true
        }
    }
    
    // challenge #3: lines property to return an array of all lines in a string
    var lines: [String] {
        get {
            self.components(separatedBy: "\n")
        }
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let carPet = "pet".withPrefix("car")
        print(carPet)
        
        print("x3x".isNumeric ? "yes" : "no")
        print("30".isNumeric ? "yes" : "no")
        print("30.4".isNumeric ? "yes" : "no")
        print("".isNumeric ? "yes" : "no")
        
        print("thisisatest".lines)
        print("this\nis\na\ntest".lines)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
