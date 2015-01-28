class {{className}} {
{% for var in variables %}
	var {{var.varName}} : {{var.varType}}{% if var.varOptional %}?{% endif %} = nil;
{% endfor %}

	func pack{{classname}}Object(jsonData : NSData) {
		let jsonObject : JSON? = JSON(jsonData);

{% for var in variables %}
{% if var.customClass %}

		//Custom class, must call its packing code
		{{var.varName}} = {{var.varType}}();
		let {{var.varType}}Object : AnyObject? = jsonObject?["{{var.varName}}"].object;
		let {{var.varType}}Data : NSData = NSKeyedArchiver.archivedDataWithRootObject({{var.varType}}Object!);
		{{var.varName}}?.packObject({{var.varType}}Data);
{% else %}
		{{var.varName}} = jsonObject?["{{var.varName}}"].{{var.varType.lower()}}; 
{% endif %}
{% endfor %}

	}

	func unpack{{classname}}Object() -> (NSData?) {
		var json : JSON? = nil;

{% for var in variables %}
{% if var.customClass %}
		//Custom class, must call its unpacking code (placeholder)
{% else %}
		json?["{{var.varName}}"].{{var.varType.lower()}} = {{var.varName}};		
{% endif %}
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