import JavaScriptCore

class MuJSContext: JSContext {
    override init!() {
        super.init()
        
        //
        self.exceptionHandler = {context, exception in
            if let exception = exception {
                print(exception.toString() ?? "")
            }
        }
        
        // attach js print console log
        self.evaluateScript("var console = { log: function(message) { _consoleLog(message) } }")
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("[JS console.log]\n" + message + "\n")
        }
        
        self.setObject(unsafeBitCast(consoleLog, to: AnyObject.self),
                       forKeyedSubscript: "_consoleLog" as NSCopying & NSObjectProtocol)
    }
    
    override init!(virtualMachine: JSVirtualMachine!) {
        super.init(virtualMachine: virtualMachine)
    }
    
    func loadScript(_ script: String) {
        self.evaluateScript(script)
    }
}
