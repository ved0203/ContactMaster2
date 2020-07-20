

import UIKit
import Contacts
import ContactsUI

class ContactsModel: NSObject
{
    static let shared = ContactsModel()
    private override init(){}
    typealias contacts = (CNContact?) -> ()
    
    func getLocalContacts(completion:@escaping contacts)
    {
        let contacts     = CNContact()
        let contactStore = CNContactStore()
        let keys    = [CNContactGivenNameKey,CNContactFamilyNameKey, CNContactPhoneNumbersKey]//[CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do
        {
            try contactStore.enumerateContacts(with: request) {(contact, stop) in
                completion(contact)
            }
        }
        catch
        {
            print(error.localizedDescription)
            completion(contacts)
        }
    }
}
