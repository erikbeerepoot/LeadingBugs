# @name: generateSlackEventCode.py
# @brief: Use Jinja2 to generate swift code for events in Slack API
# @author: Erik E. Beerepoot

from jinja2 import Template
from jinja2 import Environment, PackageLoader,FileSystemLoader
import json
import os

class Variable:
	varName = ''
	varType = ''
	varOptional = True

#Get pwd
kThisDir = os.path.dirname(os.path.abspath(__file__))

#Other magic values
kTypesFilepath = "./Types"
kOutputPath = "../Nexus/Generated/"
j2_env = Environment(loader=FileSystemLoader(kThisDir), trim_blocks=True);

def load_template():
    #Load class configuration file (TEMP: manual input)
    typeListFile = open(kTypesFilepath)
    jsonData = json.load(typeListFile)



    #Iterate over dict of types in Slack API
    for className,classDict in jsonData.iteritems():
        print "Generating swift class for type: " + className

        #Recursively create model classes
        classString = "";
        classString = parse_dict(classDict,className,classString)

        #Added header and imports
        classString = j2_env.get_template('classTemplate.swift').render(
            className=className, variables=[],classDescription="None provided."
        ) + classString

        #Save to file
        outputFilePath  = kOutputPath + className + ".swift"
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
            classString = parse_dict(value,key,classString)             
            newVar.varType = key;
            newVar.varName = key + "Instance" 
        elif type(value) is list:
            newVar.varType = "Array"
        else:
            print("Error: Unknown type encountered. Skipping field!")
            print(key)
            print(type(value))
            continue
        varList.append(newVar)


    classString += j2_env.get_template('modelTemplate.swift').render(
            className=forKey, variables=varList,classDescription="None provided."
    )
    return classString

                
if __name__ == '__main__':
	load_template();