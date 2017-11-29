
import UIKit

class DemoCell: FoldingCell {
    
    //public var delegate: rescueButtonPressedProtocol!
    
    @IBOutlet weak var closeNumberLabel: UILabel!
    @IBOutlet weak var openNumberLabel: UILabel!
    
    @IBOutlet weak var closeDescription: UILabel!
    
    @IBOutlet weak var openDescription: UILabel!
    
    @IBOutlet weak var closeQuestPic: UIImageView!
    
    @IBOutlet weak var openQuestPic: UIImageView!
    
    var subject: String = "n/a" {
        didSet {
            closeNumberLabel.text = subject
            openNumberLabel.text = subject
        }
    }
    
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        self.openQuestPic.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapEdit(sender:)))
        self.openQuestPic.addGestureRecognizer(tapGesture)
    }
    
    func tapEdit(sender: UITapGestureRecognizer) {
        tableDelegate?.expandimage(cellimageview: openQuestPic)
    }
    
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}

protocol expandimageProtocol {
    func expandimage(cellimageview: UIImageView)
}

extension DemoCell {
    @IBAction func buttonHandler(_ sender: AnyObject) {
        let myButton = sender as? UIButton
        myButton?.isEnabled = true
        if openQuestPic.image == nil{
            print("openQuestPic.image is nil")
        } else{
            print("openQuestPic.image is not nil")
        }
        if openDescription.text == nil{
            print("openDescription.text is nil")
        } else {
            print("openDescription.text is not nil")
        }
        super.delegate.rescueButtonPressed(requestorSid: super.requestorSid, category: super.category, qid: super.qid, image: openQuestPic.image, description: openDescription.text, sender:myButton!)
    }
}
