
import Foundation
class HomeModel: NSObject {
    var icon = ""
    var name = ""
    
    init(icon: String = "", name: String = "") {
        self.icon = icon
        self.name = name
    }
    override init() {
        
    }
}
