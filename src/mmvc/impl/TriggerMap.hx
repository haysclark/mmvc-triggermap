/****
* Copyright (c) 2015 Massive Interactive
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of 
* this software and associated documentation files (the "Software"), to deal in 
* the Software without restriction, including without limitation the rights to 
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
* of the Software, and to permit persons to whom the Software is furnished to do 
* so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all 
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
* SOFTWARE.
* 
* RobotLegs License:
* 
* The MIT License
* 
* Copyright (c) 2009, 2010 the original author or authors
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
* 
****/

package mmvc.impl;

import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;
import minject.Injector;
import mmvc.api.ITriggerMap;
import haxe.ds.StringMap;
import mmvc.api.ICommand;

class TriggerMap implements ITriggerMap
{
    var injector:Injector;
    var classToCommand:StringMap<Class<ICommand>>;
    var stringToCommand:StringMap<Class<ICommand>>;
    var enumValueToCommand:EnumValueMap<EnumValue, Class<ICommand>>;
    var objectToCommand:ObjectMap<Dynamic, Class<ICommand>>;

    public function new(injector:Injector)
	{
		this.injector = injector;
		
        classToCommand = new StringMap<Class<ICommand>>();
        stringToCommand = new StringMap<Class<ICommand>>();
        enumValueToCommand = new EnumValueMap<EnumValue, Class<ICommand>>();
        objectToCommand = new ObjectMap<Dynamic, Class<ICommand>>();
    }

    public function map(trigger:Class<Dynamic>, command:Class<ICommand>)
    {
        var triggerClassName = Type.getClassName(trigger);
        if(classToCommand.exists(triggerClassName))
            throw "Command for class " + triggerClassName + " is already mapped.";

        classToCommand.set(triggerClassName, command);
    }

    public function unmap(trigger:Class<Dynamic>)
    {
        classToCommand.remove(Type.getClassName(trigger));
    }

    public function dispatch(trigger:{})
    {
        var triggerClass = Type.getClass(trigger);
        var commandClass = classToCommand.get(Type.getClassName(triggerClass));
        invokeCommand(trigger, triggerClass, commandClass);
    }

    public function mapString(trigger:String, command:Class<ICommand>)
    {
        if(stringToCommand.exists(trigger))
            throw "Command for string " + trigger + " is already mapped.";

        stringToCommand.set(trigger, command);
    }

    public function unmapString(trigger:String)
    {
        stringToCommand.remove(trigger);
    }

    public function dispatchString(trigger:String)
    {
        var commandClass = stringToCommand.get(trigger);
        invokeCommand(trigger, String, commandClass);
    }

    public function mapEnumValue(trigger:EnumValue, command:Class<ICommand>)
    {
        if(enumValueToCommand.exists(trigger))
            throw "Command for enum value " + Std.string(trigger) + " is already mapped.";

        enumValueToCommand.set(trigger, command);
    }

    public function unmapEnumValue(trigger:EnumValue)
    {
        enumValueToCommand.remove(trigger);
    }

    public function dispatchEnumValue(trigger:EnumValue)
    {
        var triggerClass = Type.getClass(trigger);
        var commandClass = enumValueToCommand.get(trigger);
        invokeCommand(trigger, triggerClass, commandClass);
    }

    public function mapObject(trigger:{}, command:Class<ICommand>)
    {
        if(objectToCommand.exists(trigger))
            throw "Command for object " + Std.string(trigger) + " is already defined.";

        objectToCommand.set(trigger, command);
    }

    public function unmapObject(trigger:{})
    {
        objectToCommand.remove(trigger);
    }

    public function dispatchObject(trigger:{})
    {
        var triggerClass = Type.getClass(trigger);
        var commandClass = objectToCommand.get(trigger);
        invokeCommand(trigger, triggerClass, commandClass);
    }

    function invokeCommand(trigger:Dynamic, triggerClass:Class<Dynamic>, commandClass:Class<ICommand>)
    {
        if(commandClass == null)
            throw "Command for trigger " + Std.string(trigger) + " is not defined.";

        injector.mapValue(triggerClass, trigger, "trigger");
        var command = injector.instantiate(commandClass);
        injector.unmap(triggerClass, "trigger");
        command.execute();
    }
}