import UIKit

class RecentSearchService: NSObject {
    
    var data: [String] {
        get {
            return (UserDefaults.standard.array(forKey: self.key) as? [String]) ?? []
        }
    }
    
    // MARK: - properties
    private let key = "recent-search-key"
    
    // MARK: - initial
    static let shared = RecentSearchService()
    
    override init() { }
    
    // MARK: - private
    // MARK: - public
    func saveHistory(_ term: String) {
        if term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
        
        // insert term at index 0
        var tmp = self.data
        tmp.removeAll(where: { $0 == term })
        tmp.insert(term, at: 0)
        
        // save max 10 terms latest
        var termsSave: [String] = []
        for i in 0..<min(tmp.count, 10) {
            termsSave.append(tmp[i])
        }
        
        // save data
        UserDefaults.standard.set(termsSave, forKey: self.key)
        UserDefaults.standard.synchronize()
    }
    
    func truncate() {
        UserDefaults.standard.set([], forKey: self.key)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - event
}
