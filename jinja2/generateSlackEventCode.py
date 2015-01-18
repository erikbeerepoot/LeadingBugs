# @name: generateSlackEventCode.py
# @brief: Use Jinja2 to generate swift code for events in Slack API
# @author: Erik E. Beerepoot

from jinja2 import Template
from jinja2 import Environment, PackageLoader,FileSystemLoader
import os

class Variable:
	varName = ''
	varType = ''
	varOptional = True

#Get pwd
THIS_DIR = os.path.dirname(os.path.abspath(__file__))

def load_template():
    j2_env = Environment(loader=FileSystemLoader(THIS_DIR), trim_blocks=True)

    #Load class configuration file (TEMP: manual input)
    v1 = Variable()
    v1.varName = "id";
    v1.varType = "String"
    v1.varOptional = True

    v2 = Variable()
    v2.varName = "var2";
    v2.varType = "String"
    v2.varOptional = False

    varList = []
    varList.append(v1);
    varList.append(v2);
    print(varList)

    print j2_env.get_template('modelTemplate.swift').render(
        classname='Channel', variables=varList,
    )


if __name__ == '__main__':
	load_template();