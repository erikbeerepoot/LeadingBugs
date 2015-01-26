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

def load_template():
    j2_env = Environment(loader=FileSystemLoader(kThisDir), trim_blocks=True)

    #Load class configuration file (TEMP: manual input)
    typeListFile = open(kTypesFilepath)
    jsonData = json.load(typeListFile)

    #Iterate over dict of types in Slack API
    for className,classFields in jsonData.iteritems():
        print "Generating swift class for type: " + className

        #iterate over key/value pairs in type dict
        varList = []
        for key,value in classFields.iteritems():
            
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
                newVar.varType = "NSMutableDictionary"
            elif type(value) is list:
                newVar.varType = "NSMutableArray"
            else:
                print("Error: Unknown type encountered. Skipping field!")
                continue
            varList.append(newVar)
 
        #Now generate code for this class       
        classString = j2_env.get_template('modelTemplate.swift').render(
            className=className, variables=varList,classDescription="None provided."
        )

        #Save to file
        outputFilePath  = kOutputPath + className + ".swift"
        outputFile = open(outputFilePath,'w+')
        outputFile.write(classString)
        outputFile.close()
        print outputFilePath 
    #Done!

if __name__ == '__main__':
	load_template();