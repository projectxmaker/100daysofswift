//
//  ViewController.swift
//  Project27
//
//  Created by Pham Anh Tuan on 9/7/22.
//

import UIKit

class SanboxViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    var currentDrawType = 0

    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        drawRectangle()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBActions
    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1

        if currentDrawType > 7 {
            currentDrawType = 0
        }

        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            drawStarEmoji()
        case 7:
            drawStringOfTWIN()
        default:
            break
        }
    }
    
    // MARK: - Extra Funcs
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            let retangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(retangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            var rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            rectangle = rectangle.insetBy(dx: 5, dy: 5)

            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)

            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }

        imageView.image = img
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)

            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }

        imageView.image = img
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)

            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }

            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }

        imageView.image = img
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)

            var first = true
            var length: CGFloat = 256

            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi / 2)
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }

                length *= 0.99
            }

            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }

        imageView.image = img
    }
    
    func drawImagesAndText() {
        // 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            // 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            // 3
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]

            // 4
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attrs)

            // 5
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)

            // 5
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }

        // 6
        imageView.image = img
    }
    
    func drawStarEmoji() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let image = renderer.image { ctx in
            ctx.cgContext.move(to: CGPoint(x: 0, y: 512))
            ctx.cgContext.addLine(to: CGPoint(x: 256, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 512, y: 512))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 200))
            ctx.cgContext.addLine(to: CGPoint(x: 512, y: 200))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 512))
            
            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    func drawStringOfTWIN() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 245))
        
        let image = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addLines(between: [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 124, y: 0),
                CGPoint(x: 62, y: 0),
                CGPoint(x: 62, y: 256)
            ])
            ctx.cgContext.strokePath()
            
            ctx.cgContext.move(to: CGPoint(x: 132, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 163, y: 225))
            ctx.cgContext.addLine(to: CGPoint(x: 194, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 225, y: 225))
            ctx.cgContext.addLine(to: CGPoint(x: 256, y: 0))
            ctx.cgContext.strokePath()
            
            ctx.cgContext.move(to: CGPoint(x: 295, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 295, y: 256))
            ctx.cgContext.strokePath()
            
            ctx.cgContext.move(to: CGPoint(x: 334, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 334, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 450, y: 238))
            ctx.cgContext.addLine(to: CGPoint(x: 450, y: 0))
            ctx.cgContext.strokePath()
        }
        
        imageView.image = image
    }
}
