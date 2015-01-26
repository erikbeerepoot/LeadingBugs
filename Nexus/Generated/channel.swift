/**
 * @name: channel
 * @author: Erik E. Beerepoot
 * @brief: None provided.
 * @notes: Autogenerated! Edit at your own risk!
 */

 struct channel {
 	var is_general : Bool? = nil;
 	var name : String? = nil;
 	var is_channel : String? = nil;
 	var created : int? = nil;
 	var is_member : Bool? = nil;
 	var is_archived : Bool? = nil;
 	var creator : String? = nil;
 	var topic : Dictionary? = nil;
 	var unread_count : int? = nil;
 	var purpose : Dictionary? = nil;
 	var members : Array? = nil;
 	var last_read : String? = nil;
 	var id : String? = nil;
 	
 	func packObject(jsonData : NSData) {
 		jsonObject = JSON.parse(jsonData);

 		//get our variables out of the object
 	 	jsonObject[is_general] = jsonObject?["is_general"].Bool;
	 	jsonObject[name] = jsonObject?["name"].String;
	 	jsonObject[is_channel] = jsonObject?["is_channel"].String;
	 	jsonObject[created] = jsonObject?["created"].int;
	 	jsonObject[is_member] = jsonObject?["is_member"].Bool;
	 	jsonObject[is_archived] = jsonObject?["is_archived"].Bool;
	 	jsonObject[creator] = jsonObject?["creator"].String;
	 	jsonObject[topic] = jsonObject?["topic"].Dictionary;
	 	jsonObject[unread_count] = jsonObject?["unread_count"].int;
	 	jsonObject[purpose] = jsonObject?["purpose"].Dictionary;
	 	jsonObject[members] = jsonObject?["members"].Array;
	 	jsonObject[last_read] = jsonObject?["last_read"].String;
	 	jsonObject[id] = jsonObject?["id"].String;
	 		
 	}

 	func unpackObject() -> (NSData) {
 		var jsonDict : Dictionary = Dictionary();
	 	jsonDict["is_general""] = is_general;
	 	jsonDict["name""] = name;
	 	jsonDict["is_channel""] = is_channel;
	 	jsonDict["created""] = created;
	 	jsonDict["is_member""] = is_member;
	 	jsonDict["is_archived""] = is_archived;
	 	jsonDict["creator""] = creator;
	 	jsonDict["topic""] = topic;
	 	jsonDict["unread_count""] = unread_count;
	 	jsonDict["purpose""] = purpose;
	 	jsonDict["members""] = members;
	 	jsonDict["last_read""] = last_read;
	 	jsonDict["id""] = id;
	 		
		return NSJSONSerialization.dataWithJSONObject(jsonDict,0,nil);
 	}
 }