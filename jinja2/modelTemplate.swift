class {{className}} {
 	{% for var in variables %}
var {{var.varName}} : {{var.varType}}{% if var.varOptional %}?{% endif %} = nil;
 	{% endfor %}

 	func pack{{classname}}Object(jsonData : NSData) {
 		let jsonObject : JSON? = JSON(jsonData);
 		 		
 	{% for var in variables %}
 	{{var.varName}} = jsonObject?["{{var.varName}}"].{{var.varType.lower()}};
	{% endfor %} 		
 	}

 	func unpack{{classname}}Object() -> (NSData?) {
    var json : JSON? = nil;
	{% for var in variables %}
 	json?["{{var.varName}}"].{{var.varType.lower()}} = {{var.varName}};
	{% endfor %} 		

		//Now create data object
		var error : NSError? = nil;
		let object : AnyObject? = json?.object;
		if let data = NSJSONSerialization.dataWithJSONObject(object!, options: NSJSONWritingOptions.PrettyPrinted, error: nil) {
	        //post your data to server
	        return data;
	    } else {
	        //error
	        return nil;
	    }
 	}
}


