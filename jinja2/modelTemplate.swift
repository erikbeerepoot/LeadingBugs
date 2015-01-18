/**
 * @name: {{classname}}
 * @author: Erik E. Beerepoot
 * @brief: {{class_description}}
 * @notes: Autogenerated! Edit at your own risk!
 */

 struct {{classname}} {
 	{% for var in variables %}
 	var {{var.varName}} : {{var.varType}}{% if var.varOptional %}?{% endif %} = nil;
 	{% endfor %}

 	func pack{{classname}}Object(jsonData : NSData) {
 		jsonObject = JSON.parse(jsonData);

 		//get our variables out of the object
 	{% for var in variables %}
 	jsonObject[{{var.varName}}] = jsonObject?["{{var.varName}}"].{{var.varType}};
	{% endfor %} 		
 	}

 	func unpack{{classname}}Object() -> (NSData) {
 		var jsonDict : Dictionary = Dictionary();
	{% for var in variables %}
 	jsonDict[{{var.varName}}] = {{var.varName}};
	{% endfor %} 		
		return NSJSONSerialization.dataWithJSONObject(jsonDict,0,nil);
 	}
 }