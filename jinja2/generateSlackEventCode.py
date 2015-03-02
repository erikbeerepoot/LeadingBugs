# @name: generateSlackEventCode.py
# @brief: Use Jinja2 to generate swift code for events in Slack API
# @author: Erik E. Beerepoot

from jinja2 import Template
from jinja2 import Environment, PackageLoader,FileSystemLoader
import json
import os

from array import *
from types import *


class Variable:
    varName = ''
    varType = '' 
    varSubType = ''   
    customClass = False
    varOptional = True

#Get pwd
kThisDir = os.path.dirname(os.path.abspath(__file__))

#Other magic values
kTypesFilepath = "./Types"
kOutputPath = "../Nexus/Generated/"
j2_env = Environment(loader=FileSystemLoader(kThisDir), trim_blocks=True);
classOutDict = {};

def load_template():
    #Load class configuration file (TEMP: manual input)
    typeListFile = open(kTypesFilepath)
    jsonData = json.load(typeListFile)

    classString = "";

    #Iterate over dict of types in Slack API
    for className,classDict in jsonData.iteritems():        
        #Recursively create model classes
        classString = parse_dict(classDict,className,classString)

    for key,value in classOutDict.iteritems():
        
        #Add class header and imports
        classString = j2_env.get_template('classTemplate.swift').render(
            className=key, variables=[],classDescription="None provided."
        ) + value
            
        #Save to file
        print "Generating swift class for type: " + key
        outputFilePath  = kOutputPath + key + ".swift"
        outputFile = open(outputFilePath,'w+')
        outputFile.write(classString)
        outputFile.close()
        print outputFilePath 
    #Done!

#Parse a dict (recursively)
def parse_dict(inDict,forKey,classString):

    varList = [];
    for key,value in inDict.iteritems():
         #Most attributes are the same, just set type seperately 
        newVar = Variable()
        newVar.varName = key;
        newVar.varOptional = True

        if type(value) is bool:
            newVar.varType = "Bool"
        elif type(value) is unicode:
            newVar.varType = "String"
        elif type(value) is int:
            newVar.varType = "Int"
        elif type(value) is dict:
            #Update output file string            
            classString += parse_dict(value,key,classString) 

            newVar.varType = key;
            newVar.customClass = True;
            newVar.varName = key + "Instance" 

            if(key not in classOutDict):                
                classOutDict[key] = classString;

        elif type(value) is list:
            #Convert to array     
            newVar.varType = "Array"       
            newVar.varSubType = get_array_subtype(value)
        else:
            print("Error: Unknown type encountered. Skipping field! Key: " + key)            
            continue
        varList.append(newVar)


    classString = j2_env.get_template('modelTemplate.swift').render(
            className=forKey, variables=varList,classDescription="None provided."
    )  


    if(forKey not in classOutDict):        
        classOutDict[forKey] = classString;
  
    return classString

def get_array_subtype(value):
    if(type(value) is not list):
        return "Not List!"

    dataType = type(value[0])

    if(dataType==UnicodeType):
        return "String"
    elif(dataType==IntType | dataType==LongType):
        return "Int"
    elif(dataType==FloatType):
        return "Float"
    elif(dataType==DoubleType):
        return "Double"
    else:
        return "Unknown"


                
if __name__ == '__main__':
	load_template();