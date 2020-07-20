
import UIKit
import Contacts

struct ContactJson
{
    var userId: String?
    var userType: String?
    var onItag: Bool?
    var taggedStat: Bool?
    
    var userName: String?
    var phnum: String?
    
    var fName: String?
    var lName: String?
    var isTaggedReq: Bool?
    var status: String?

    init(userId: String, userType: String, oniTaag: Bool, tagged: Bool, userName: String, phone: String, firstName: String, lastName: String, isTaggedWithRequestor: Bool, status: String)
    {
        self.userId = userId
        self.userType = userType
        self.onItag = oniTaag
        self.taggedStat = tagged
        self.userName = userName
        self.phnum = phone
        
        self.fName = firstName
        self.lName = lastName
        self.isTaggedReq = isTaggedWithRequestor
        self.status = status
    }
}

class ContactsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var joinersTableView: UITableView!
    var phoneNum: String?
    var contacts = [CNContact]()
    var phNumArray  = ["5555555544", "0000043251", "6305319872", "0000029674", "1212121212", "0000000000"]
    //var phNumArray  = [String]()
    
    var taggedStatus: Bool?
    var onitag: Bool?
    var userNAme: String?
    
    var userId: String?
    var jsonArrayFilter = [ContactJson]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        joinersTableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactsTableViewCell")
        
        ContactsModel.shared.getLocalContacts {(contact) in
            self.contacts.append(contact!)
            print("all contects \(contact)")
            //self.phNumArray = self.contacts.flatMap { $0.phoneNumbers }.map { $0.value.stringValue }
        }
        
        self.callPostApi()
        gettaggedUser()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return jsonArrayFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: ContactsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        let aContact = jsonArrayFilter[indexPath.row]
        
        if onitag == true
        {
            cell.nameLbl.text = aContact.userName
            cell.empRoleLbl.text = aContact.phnum
            cell.taggedImgBtn.isSelected = true
        }
        else
        {
            cell.nameLbl.text = "\(aContact.fName )\(" ")\( aContact.lName)"
            cell.taggedImgBtn.isSelected = false
        }
        return cell
    }
    
    @objc func connectedTagged(sender: UIButton)
    {
        print("in tagged button action")
        //cell.inviteButn.setTitle("Tagged", for: .normal)
    }
    
    func callPostApi()
    {
        let url            = URL(string: "http://itaag-env-1.ap-south-1.elasticbeanstalk.com/filter/taggedusers/")!
        var request        = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let deviceId: String = (UIDevice.current.identifierForVendor?.uuidString)!
        
        let personalId: String = UserDefaults.standard.string(forKey: "regUserID") ?? ""
        
        
        request.setValue("BF201D9D-4DDE-4BFA-BCEE-17A3C1F3F0C1", forHTTPHeaderField: "deviceid")
        request.setValue("991972c1bc5744faa19381b7846e398e", forHTTPHeaderField: "key")
        request.setValue("personal", forHTTPHeaderField: "userType")
        
        try? request.setMultipartFormData(["contactsList": "\(phNumArray)"], encoding: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                print("contacts JSON \(jsonObj)")
                let phnDict: [String : Any] = (jsonObj as? [String : Any])!
                
                for (key, val) in phnDict
                {
                    let phnum: String = key as? String ?? ""
                    let phKey = val as! [String : Any]
                    let userId = phKey["userId"] as? String
                    let userNam = phKey["userName"]
                    self.taggedStatus = phKey["tagged"] as? Bool
                    self.onitag = phKey["oniTaag"] as? Bool
                    self.userNAme = phKey["userName"] as? String
                    UserDefaults.standard.set(self.taggedStatus, forKey: "TagNumStat")
                    
                    self.jsonArrayFilter.append(ContactJson(userId: userId ?? "", userType: "", oniTaag: self.onitag ?? true, tagged: self.taggedStatus ?? true, userName: self.userNAme ?? "", phone: phnum, firstName: "", lastName: "", isTaggedWithRequestor: false, status: ""))
                    print("only all userName \(userNam)")
                }
                DispatchQueue.main.async
                {
                    self.joinersTableView.reloadData()
                }
                
            }
        }.resume()
    }
    
    func gettaggedUser()
    {
        print("in contacts service")
        
        
        let URL_HEROES = "http://itaag-env-1.ap-south-1.elasticbeanstalk.com/filter/taggedusers/"
        let url = NSURL(string: URL_HEROES)
        // let deviceId: String = "HardcodeDEVICEIDiTaagBuildTest012"
        
        let headers = ["deviceid": "E3A6058D-CE26-49FE-8639-F967A59D3954", "userType": "personal", "key": "991972c1bc5744faa19381b7846e398e"]
        let request = NSMutableURLRequest(url:url! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as? [String : String]
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            if error == nil {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse!.statusCode == 200 {
                    do {
                        let jsonObjects  = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String : AnyObject]]
                        print("the json of gettaggeduser\(jsonObjects)")
                        
                        for jsonObj in jsonObjects{
                            
                            let fName = jsonObj["firstName"] as? String
                            print("tagged user fname \(fName)")
                            let lName = jsonObj["lastName"] as? String
                            let userId = jsonObj["userId"] as? String
                            let taggedwithRequester = jsonObj["taggedWithRequestor"] as? String
                            let userType = jsonObj["userType"] as? String
                            let phNum = jsonObj["phone"] as? String
                            let status = jsonObj["status"] as? String
                            let isTaggedwithRequester = jsonObj["isTaggedWithRequestor"] as? Bool
                            
                            self.jsonArrayFilter.append(ContactJson(userId: userId ?? "", userType: userType ?? "", oniTaag: false, tagged: false, userName: "", phone: phNum ?? "", firstName: fName ?? "", lastName: lName ?? "", isTaggedWithRequestor: isTaggedwithRequester ?? true, status: status ?? ""))
                        }
                        
                        DispatchQueue.main.async {
                            self.joinersTableView.reloadData()
                        }
                    }
                    catch  {
                        print(error.localizedDescription)
                    }
                }
                else {
                }
            }
        })
        dataTask.resume()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
            return 100
        }
        else{
            
            return 90.0
        }
    }
}


extension URLRequest {
    
    public mutating func setMultipartFormData(_ parameters: [String: String], encoding: String.Encoding) throws {
        
        let makeRandom = { UInt32.random(in: (.min)...(.max)) }
        let boundary = String(format: "------------------------%08X%08X", makeRandom(), makeRandom())
        
        let contentType: String = try {
            guard let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)) else {
                throw MultipartFormDataEncodingError.characterSetName
            }
            return "multipart/form-data; charset=\(charset); boundary=\(boundary)"
            }()
        addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        httpBody = try {
            var body = Data()
            
            for (rawName, rawValue) in parameters {
                if !body.isEmpty {
                    body.append("\r\n".data(using: .utf8)!)
                }
                
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                
                guard
                    rawName.canBeConverted(to: encoding),
                    let disposition = "Content-Disposition: form-data; name=\"\(rawName)\"\r\n".data(using: encoding) else {
                        throw MultipartFormDataEncodingError.name(rawName)
                }
                body.append(disposition)
                
                body.append("\r\n".data(using: .utf8)!)
                
                guard let value = rawValue.data(using: encoding) else {
                    throw MultipartFormDataEncodingError.value(rawValue, name: rawName)
                }
                
                body.append(value)
            }
            
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            return body
            }()
    }
}

public enum MultipartFormDataEncodingError: Error {
    case characterSetName
    case name(String)
    case value(String, name: String)
}












