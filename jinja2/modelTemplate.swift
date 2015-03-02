class {{className}} {
{% for var in variables %}
{% if var.varSubType %}
	var {{var.varName}} : {{var.varType}}<{{var.varSubType}}>{% if var.varOptional %}?{% endif %} = nil;
{% else %}
	var {{var.varName}} : {{var.varType}}{% if var.varOptional %}?{% endif %} = nil;
{% endif %}
{% endfor %}

	func pack{{classname}}Object(jsonObject : JSON?) {
{% for var in variables %}
{% if var.customClass %}
		//Custom class, must call its packing code
		{{var.varName}} = {{var.varType}}();
		let {{var.varType}}Object : AnyObject? = jsonObject?["{{var.varName}}"].object;
		let {{var.varType}}Data : NSData = NSKeyedArchiver.archivedDataWithRootObject({{var.varType}}Object!);
		{{var.varName}}?.packObject(JSON(data:{{var.varType}}Data));
{% elif var.varSubType %}
		//Array
{% else %}
		{{var.varName}} = jsonObject?["{{var.varName}}"].{{var.varType.lower()}}; 
{% endif %}
{% endfor %}

	}

	//NOTE: Mostly a placeholder / untested / nonfunctional
	func unpack{{classname}}Object() -> (NSData?) {
		var json : JSON? = nil;

{% for var in variables %}
{% if var.customClass %}
		//Custom class, must call its unpacking code (placeholder)
{% elif var.varSubType %}
		//Array
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