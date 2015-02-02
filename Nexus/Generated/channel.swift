/**
 * @name: channel
 * @author: Erik E. Beerepoot
 * @brief: None provided.
 * @notes: Autogenerated! Edit at your own risk!
 */

import Foundation

class channel {
	var is_general : Bool? = nil;
	var name : String? = nil;
	var is_channel : String? = nil;
	var created : Int? = nil;
	var is_member : Bool? = nil;
	var is_archived : Bool? = nil;
	var creator : String? = nil;
	var topicInstance : topic? = nil;
	var unread_count : Int? = nil;
	var purposeInstance : purpose? = nil;
	var members : Array<String>? = nil;
	var last_read : String? = nil;
	var id : String? = nil;

	func packObject(jsonObject : JSON?) {
		is_general = jsonObject?["is_general"].bool; 
		name = jsonObject?["name"].string; 
		is_channel = jsonObject?["is_channel"].string; 
		created = jsonObject?["created"].int; 
		is_member = jsonObject?["is_member"].bool; 
		is_archived = jsonObject?["is_archived"].bool; 
		creator = jsonObject?["creator"].string; 
		//Custom class, must call its packing code
		topicInstance = topic();
		let topicObject : AnyObject? = jsonObject?["topicInstance"].object;
		let topicData : NSData = NSKeyedArchiver.archivedDataWithRootObject(topicObject!);
		topicInstance?.packObject(JSON(data:topicData));
		unread_count = jsonObject?["unread_count"].int; 
		//Custom class, must call its packing code
		purposeInstance = purpose();
		let purposeObject : AnyObject? = jsonObject?["purposeInstance"].object;
		let purposeData : NSData = NSKeyedArchiver.archivedDataWithRootObject(purposeObject!);
		purposeInstance?.packObject(JSON(data:purposeData));
		//Array
		last_read = jsonObject?["last_read"].string; 
		id = jsonObject?["id"].string; 

	}

	//NOTE: Mostly a placeholder / untested / nonfunctional
	func unpackObject() -> (NSData?) {
		var json : JSON? = nil;

		json?["is_general"].bool = is_general;		
		json?["name"].string = name;		
		json?["is_channel"].string = is_channel;		
		json?["created"].int = created;		
		json?["is_member"].bool = is_member;		
		json?["is_archived"].bool = is_archived;		
		json?["creator"].string = creator;		
		//Custom class, must call its unpacking code (placeholder)
		json?["unread_count"].int = unread_count;		
		//Custom class, must call its unpacking code (placeholder)
		//Array
		json?["last_read"].string = last_read;		
		json?["id"].string = id;		

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