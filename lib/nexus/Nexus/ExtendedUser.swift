/*
*      ___           ___           ___           ___                         ___           ___
*     /  /\         /  /\         /  /\         /  /\          ___          /  /\         /  /\          ___
*    /  /::\       /  /::\       /  /::\       /  /::\        /  /\        /  /::\       /  /::\        /__/\
*   /  /:/\:\     /  /:/\:\     /  /:/\:\     /  /:/\:\      /  /::\      /  /:/\:\     /  /:/\:\       \  \:\
*  /  /::\ \:\   /  /::\ \:\   /  /::\ \:\   /  /::\ \:\    /  /:/\:\    /  /:/  \:\   /  /:/  \:\       \__\:\
* /__/:/\:\_\:| /__/:/\:\_\:\ /__/:/\:\_\:\ /__/:/\:\ \:\  /  /::\ \:\  /__/:/ \__\:\ /__/:/ \__\:\      /  /::\
* \  \:\ \:\/:/ \__\/  \:\/:/ \__\/~|::\/:/ \  \:\ \:\_\/ /__/:/\:\ \:\ \  \:\ /  /:/ \  \:\ /  /:/     /  /:/\:\
*  \  \:\_\::/       \__\::/     |  |:|::/   \  \:\ \:\   \__\/  \:\_\/  \  \:\  /:/   \  \:\  /:/     /  /:/__\/
*   \  \:\/:/        /  /:/      |  |:|\/     \  \:\_\/        \  \:\     \  \:\/:/     \  \:\/:/     /__/:/
*    \__\::/        /__/:/       |__|:|~       \  \:\           \__\/      \  \::/       \  \::/      \__\/
*        ~~         \__\/         \__\|         \__\/                       \__\/         \__\/
* @name: ExtendedUser.swift
* @author: Erik E. Beerepoot
* @company: Barefoot Inc.
* @brief: Extends the user class. 
* @notes: Overrides the assignment operator, to allow assigning from subclass object.
*/
import Foundation

class ExtendedUser : user {
    var presence : String? = nil;

    init(aUser : user){
        
    }
}