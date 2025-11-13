# ba.sh

ba.sh is an object-oriented framework for bash. But it's not like any other OOP framework for bash you've ever seen.

ba.sh is the only bash-native OOP framework with zero dependencies and zero runtime overhead.

Technically it may be considered a framework and a design pattern at the same time.

Disclaimer: Some examples may not work on bash 3, because I just don't have Mac and running bash 3 in Docker container is tedious. So, if something doesn't work, just raise an issue in Github.

Before I start explaining, let's see an example of a script that uses ba.sh

example.sh
```bash
#!/bin/bash

. obj.h

obj myobject

myobject.sayHello
myobject.fileName = "file1"

myobject.filename # prints "file1"
```

Here you can see:
1. An object named "myobject"
2. Method call ("myobject.sayHello")
3. Setting an object property
4. Printing the object property we just set

What's behind the scenes? Two small files

obj.h
```bash
obj(){
    local class_code=$(<obj.class)
    . <(printf '%s' "${class_code//__OBJECT__/$1}")
}
```

obj.class
```bash
__OBJECT___properties=()

__OBJECT__.sayHello(){
    echo Hello
}

__OBJECT__.property(){
    local fileName=0
    local fileSize=1

    if [ "$2" == "=" ]
    then
	  __OBJECT___properties[${!1}]="$3"
    else
	  echo ${__OBJECT___properties[${!1}]}
    fi
}

__OBJECT__.fileName(){
    if [ "$1" == "=" ]
    then
	  __OBJECT__.property fileName = "$2"
    else
	  __OBJECT__.property fileName
    fi
}
```

And this is it. This is a basic form of ba.sh code.

Although there is so much more happening there. Let me explain.

Here is what ba.sh implements:
1. Object constructor
2. Property getters and setters
3. Storage abstraction layer (helps with bash 3 and 4+ compatibility)
4. Weak incapsulation
5. Opportunities to include validations for data integrity into property setter
6. ... Some other things

# History

| Date | Event |
| --- | --- |
| __2 November 2013__ | Maxim Norin (me) implemented PoC just for fun and [the article](https://mnorin.com/ob-ektno-orientirovannoe-programmirovanie-na-bash.html) was written explaining what it does and how it works. |
| __19 September 2015__ | One of the readers (kstn) writes articles [one](https://kstn-debian.livejournal.com/16601.html) and [two](https://kstn-debian.livejournal.com/16727.html), where he explores PoC and makes quoting fixes to improve work with properties that represent strings and creates a destructor (which might be useful when you have a lot of objects to work with) |
| __5 December 2016__ | Maxim Norin publishes examples as an answer to [this question](https://kstn-debian.livejournal.com/16727.html) about creating classes and objects on Stackoverflow |
| __5 October 2019__ | Stackoverflow user TacB0sS adds an answer to the same question, telling that he implemented a terminal animation infrastructure using Maxim's pseudo-OOP concept (which looks pretty cool, by the way) |
| __12 November 2025__ | Maxim implemented a zero-dependency constructor, which made ba.sh probably the only in the world fully bash-native pseudo-OOP framework with zero dependencies |

Since the very first implementation of PoC ba.sh didn't change much.

The Philosophy behind ba.sh:
1. __Provide mechanism, not policy__ - Give tools, let developers decide constraints
2. __Minimal but sufficient__ - No feature at all is better than rarely used feature
3. __Leverage what exists__ - Use bash's natural behaviour as features
4. __Clarity over cleverness__ - Unless cleverness aids clarity
5. __Pragmatic trade-offs__ - Accept limitations, don't fight the language

This is like Unix philosophy applied to OOP: simple parts, clear purposes, compose well.

# Concepts

Obviously, there are no real objects or classes possible in bash.

There are other bash pseudo-OOP frameworks that add ability to use object representations. But many of them try to mock object-oriented programming languages.

ba.sh goes down to OOP concept itself and implements visually nice pseudo-OOP without mocking other OOP-languages, everything work inside the frame of bash limitations, and using native functionality. It works with bash instead of fighting it.

It gives ba.sh these advantages:
- Compatible with bash 3 and 4+ (via storage abstraction layer and compatibility layer, see below)
- Incredibly small code footprint
- Bash native performance (zero runtime overhead)

## 1. Encapsulation

ba.sh implements a weak incapsulation based on namespacing. When object is created, it generates an array to store properties values and a set of functions with the same namespace that look like methods (thanks to dot notation).

## 2. Instance isolation

Each object has its own state, independent of other objects.

Example:
```bash
obj object1
obj object2

object1.fileName = "1.txt"
object2.fileName = "2.txt"

object1.fileName # prints "1.txt"
object2.fileName # prints "2.txt"
```

This is achieved with having a unique state array for each object that uses object's namespace.

## 3. Property validation

You can control access to data and enforce invariants.

Example:
```bash
__OBJECT__.priority(){
    if [ "$1" = "=" ]; then
        # Validation: priority 1-5
        if [[ ! "$2" =~ ^[1-5]$ ]]; then
            echo "Error: Priority must be 1-5" >&2
            return 1
        fi
        __OBJECT___properties[$priority]="$2"
    else
        echo "${__OBJECT___properties[$priority]:-3}"
    fi
}
```
Each property accessor is a gateway to the data. This provides:
- Type validation
- Range checking
- Format enforcement
- Business rule validation
- Default values

Technically you can bypass validation simply writing to the object property array, but this is due global nature of bash environment. No complex limitation implemented, and it's a consious decision. It's a convention, and you can choose to follow it or not (it's better to follow if you want your code to do exactly what you want it to do).

## 4. Method dispatch

Technically it's just calling behaviour on specific instances.

This is what it looks like:
```bash
task1.display
task2.display
```

This works, because function with object-related unique name is executed and it accesses property storage specific to object's namespace.

## 5. Composition

Ability to combine methods from different classes in one object.

Example:
```bash
obj myobject   # Add methods from obj.class
obj2 myobject  # Add methods from obj2.class

# myobject has methods from both classes
myobject.methodFromObj1
myobject.methodFromObj2
```

How it works:
1. "obj myobject" creates "myobject.methodFromObj1()"
2. "obj2 myobject" creates "myobject.methodFromObj2()"
3. If both define the same method, the second overrides the first

And this is it, the last definition wins, so order is important. This simplicity is intentional, it leverages natural bash behaviour.

If you want to make it look more like inheritance, you can simply modify a constructor like this:

```bash
obj(){
    . <(sed "s/__OBJECT__/$1/g" parent.class)
    . <(sed "s/__OBJECT__/$1/g" obj.class)
}
```

This way your object first inherit all parent's methods, and then object's own methods will be added.

## 6. Method overriding

Method implementation can be performed either via composition or at runtime.

Example:
```bash
obj myobject
myobject.display  # Original implementation

# Override at runtime
myobject.display(){
    echo "Custom display!"
}
myobject.display  # New implementation
```

In bash when you define a function with the same name as an existing one, it replaces the previous definition. This is not a bug, it's a feature, it enables polymorphism and runtime customisation.

# Design decisions & Philosophy

## No explicit constructors with parameters

Reasoning:
- More explicit and readable
- Self-documenting (you see what's being set)
- More flexible (set only what you need)
- Clearer intent

## No destructors

Reasoning:
- Scripts are typically short-lived
- OS cleans up process environment automatically when script execution finished
- Avoids complexity for rarely-needed feature
- Easy to implement if needed (kstn demonstrated an example), so users can add their own destructor when needed

## Composition over inheritance

Reasoning:
- Simpler mental model
- Sufficient for bash's use cases (remember, it's not a general purpose language)
- This avoids complexity of true inheritance
- More appropriate for bash's capabilities

## Weak incapsulation

What you can do:
```bash
myobject.title = "value"              # Through accessor
myobject_properties[$title]="value"   # Direct access (breaks convention)
```
Why allow this:
- Adding enforcement adds significant complexity
- Naming convention is sufficient, also it's executed automatically
- Bash's global namespace makes true privacy impractical, no reason to fight the language, embrace it
- Respect developer's judgement, trust over enforcement

# The Storage Abstraction Layer

This code is the data storage abstraction:

```bash
obj.property(){
    if [ "$2" == "=" ]; then
        obj_properties[$1]="$3"  # Storage mechanism hidden here
    else
        echo ${obj_properties[$1]}
    fi
}

# Property setters use the abstraction
obj.fileName(){
    if [ "$1" == "=" ]; then
        obj.property fileName = "$2"  # Storage-agnostic!
    else
        obj.property fileName
    fi
}
```

Property methods (e.g. `obj.fileName()`) call the generic `obj.property()` instead of accessing storage directly. This means:
1. Property methods don't know about storage - they just call the abstraction
2. Storage changes in one place - only `obj.property()` needs updating

Bash 3 implementation:

```bash
obj_properties=()  # Indexed array

obj.property(){
    # Property IDs for indexed arrays
    title=0
    description=1

    if [ "$2" == "=" ]; then
        obj_properties[$1]="$3"  # $1 is property ID (0, 1, etc)
    else
        echo ${obj_properties[${!1}]}
    fi
}

# Usage in property setter
obj.title(){
    if [ "$1" == "=" ]; then
        obj.property title = "$2"  # 'title' resolves to 0
    else
        obj.property title
    fi
}
```
Note: In bash array subscripts, variables are evaluated automatically. Both [$title] and [title] work (title=0), though [$title] is more explicit.

Bash 4 implementation:

```bash
# No property IDs needed!
declare -A obj_properties  # Associative array

obj.property(){
    if [ "$2" == "=" ]; then
        obj_properties["$1"]="$3"  # $1 is property name directly
    else
        echo "${obj_properties["$1"]}"
    fi
}

# Property setter - UNCHANGED!
obj.title(){
    if [ "$1" == "=" ]; then
        obj.property title = "$2"  # Same call!
    else
        obj.property title
    fi
}
```

Even better option is to store property name variables inside the data abstraction layer like this:
```bash
obj_properties=()  # Indexed array

obj.property(){
    # Property IDs for indexed arrays
    local title=0
    local description=1

    if [ "$2" == "=" ]; then
        obj_properties[$1]="$3"  # $1 is property ID (0, 1, etc)
    else
        echo ${obj_properties[${!1}]}
    fi
}
```

For migration from bash 3 to bash 4 you need to do to exactly three things:
1. Array declaration `obj_properties=()` -> `declare -A obj_properties`
2. Storage access in `obj.property()`: add quotes for associative array keys
3. Remove variables named as properties that keep indexes of the said properties

All property methods unchanged. All application code stays unchanged.

And, of course, if you want, you can switch to file-based storage, for example. Or even database if you prefer.

# Zero dependency constructor

The PoC version has the legacy constructor
```bash
obj(){
    . <(sed "s/__OBJECT__/$1/g" obj.class)
}
```

The obvious dependency on sed makes code really small. And in terms of performance it still looks good.

But it's possible to modify constructor to use zero external dependencies (in this case getting rid of sed) and to keep it exclusively bash code.

Here is how:

```bash
obj(){
    local class_code=$(<obj.class)
    . <(printf '%s' "${class_code//__OBJECT__/$1}")
}
```
It's a bit more code, but now it's as native as possible. In terms of performance, you can do some tests if you use a lot of objects, but on small number of objects difference is negligible, so it's more like a trade-off. You can pick either smaller code or full independence.

## Zero dependency constructor in bash 3

The main problem here is that that code above won't work for bash 3. In case of bash 3 zero dependency constructor wil look like this:
```bash
obj () 
{
    local class_code=$(<obj.class);
    local generated_code="${class_code//obj/$1}";
    eval "$generated_code"
}
```

I don't like eval and try to avoid it as much as possible, but for bash 3 it seems to be the only solution. Considering we know what's inside class files, security concerns should be low in this specific case. Also, it's an internal command, so still helps to exclude external dependencies.

If you want to run you scripts on both bash 3 and 4+, you will need to implement a compatibility layer for constructors that will look like this:
```bash
# File compatibility.h
# 1. Determine the environment
BASH_MAJOR_VERSION=${BASH_VERSION%%.*}

# 2. Define the core code execution function only once
if [[ "$BASH_MAJOR_VERSION" -ge 4 ]]; then
    _source_code() {
        # Bash 4.0+ method
        . <(printf '%s' "$1")
    }
else
    _source_code() {
        # The necessary, reliable Bash 3.x 'eval' workaround
        eval "$1"
    }
fi
```

And then in a constructor you can just call `_source_code()`
```bash
. compatibility.h
matrix() {
    local class_code=$(<matrix.class);
    local generated_code="${class_code//matrix/$1}";
    
    # Use the function defined in compatibility.h
    _source_code "$generated_code" 
}
```

And, of course, there is always an option when you use compatibility layer on the application level. This might be more convenient, because you only need to source it once.
Example:
```bash
#!/bin/bash
# Source the compatibility file first.
. compatibility.h

. matrix.h
matrix m1
# ...
```

Compatibility layer can be used for other things as well. In this case application level is prefered, as it requires sourcing just once. The whole idea is to keep the same interface, providing functions that do the same with functionality adjusted to specific bash version. The same, but different, but the same.

Zero dependency constructor is considered the primary option, sed constructor is secondary. Make your decision during implementation. Zero-dependency constructor might be faster in most cases, but when it requires hundreds of objects, you may want to run some benchmarks.

It would be also good to consider destructors if that's the case.

# Destructors

Even though destructors are not required in most cases, because scripts are short-living, you may need one if you are actively creating objects in the script.

The first person who implemented destructor was kstn.

What descructor looks like:
```bash
__OBJECT__.destroy(){
    unset __OBJECT___properties
    unset -f __OBJECT__.filename __OBJECT__.property
}
```
And this is it.

# Static classes (utility classes)

You dont always want to create an object instance for everything. The best part about classes is that they have data and methods that work with this data. But when you don't really have data to work with, then you don't really need an instance.

Here is how you create a static class:

File system.h
```bash
. system.class
```

File system.class
```bash
system.stdout.printValue(){
    echo $($@)
}

system.stdout.printString(){
    echo $@
}
```

As you can see, header file only has sourcing, so code gets added as-is, without creating an isolated namespace.

# Bundling

When you develop multi-file application, you may want to eventually create a single application file that will contain all the code, including class definitions. This can be easily done with another script, let's call it a bundler.

What you essentially need to do is add every class you use, then add all constructors, and the the application code, which can be automated with bash obviously.

... To be continued

# Best practices and recommendations

## 1. Use longer and/or more unique placeholders in class files

Instead of "obj" use something like `__OBJECT__` or `__CLASS_NAME__` to avoid substring collisions. Short names look nicer, but they might be a part of something else rather than what you want it to be.

If you decide to use short placeholders, then at least include "." in the end in both parts or string substitution.

## 2. Organise constructors into library files

Instead of creating one constructor per class, add them all in one file, call it something like "mylib.h", and then source it in the application script like this:
```bash
. mylib.h
```
It will make all you classes available all at once, but it obviously won't add any class code into current shell environment, it will only happen when object is instantiated.

## 3. If you don't need data validation in setters and defaults in getters, use simplified property generation

```bash
for property_name in "name" "weight" "color"
do
  __OBJECT__.${property_name}(){
    __OBJECT__.property "${property_name}" "$1" "$2"
  }
done
```
or something similar. It will reduce manual boilerplate when put after `__OBJECT__.property()`. This code will be executed once, when object is instantiated. Then you can redefine whatever getters/setters you actually need to be more complicated. This will effectively override existing property methods.

... To be continued...

# Q&A

## TBD