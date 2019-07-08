import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    var passedImage: UIImage!
    @IBOutlet weak var popImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
    }
    
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
    


}
