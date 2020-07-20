

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var empRoleLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var cellBodyLablBtn: UIButton!
    @IBOutlet weak var taggedImgBtn: UIButton!
    @IBOutlet weak var inviteButn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
