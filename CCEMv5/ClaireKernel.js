//+-------------------------------------------------------------+
//| CLAIRE                                                      |
//| ClaireKernel.js                                             |
//| Copyright (C) 2023-2024 Yves Caseau. All Rights Reserved    |
//+-------------------------------------------------------------+

// ---------------------------------------------------------------------
// This is the very simplified version (diet) of the Kernel module,
// described as a Javascript file
// ---------------------------------------------------------------------

// *********************************************************************
// *  Contents                                                         *
// *  Part 1: Classes                                                  *
// *  Part 2: Primitive methods (int, float, etc) + List & Set         *
// *  Part 3: Object methods                                           *
// *  Part 4: Claire Environment & Errors                              *
// *  Part 5: Miscellaneous                                            *
// *********************************************************************


// *********************************************************************
// *  Part 1: Classes                                                  *
// *********************************************************************

// ClaireObject is the root
class ClaireObject {
    constructor() {
        // no default value
    }

    // key : sets isa and its conditional inverse (instances)
    Is (x)  {
        this.isa = x 
        if (x.instanced == true) {x.instances.push(this)}
        return this}

    // selfPrint
    selfPrint() {
        PRINC("<a ")
        PRINC(this.isa.name)
        PRINC(">")}
}

class ClaireThing  extends ClaireObject {
    constructor (name) {
        super()
        this.name = name
    }
    selfPrint() {PRINC(this.name)}
}

 // our meta class
 class ClaireClass {
    constructor(myname,superc,b) {
        // console.log("-- create class",myname)
        this.isa = C_class
        this.name = myname
        this.superclass = superc
        this.instances = []
        this.subclass = new Set()
        this.descendants = new Set([this])
        this.instanced = b
        if (myname != "class") {
            C_class.instances.push(this)
            if (myname != "any") {
                superc.subclass.add(this)
                var c2 = superc
                while (c2 != C_any) {
                    c2.descendants.add(this)
                    c2 = c2.superclass
                }
            }
        }
    }

    // selfPrint
    selfPrint() {PRINC(this.name)}

    // class hiererarchy
    IsIn (c) {return c.descendants.has(this)}

    // for debug
    show() {
        PRINC("class ")
        PRINC(this.name)
        PRINC(" <: ")
        PRINC(this.superclass.name)
        PRINC(",descendants:")
        print_any(this.descendants),
        PRINC(" #:")
        console.log(size_class(this))
     }
 }



// class utilities 
function size_class (c) {
    var s = 0
    for (let c2 of c.descendants) { s += c2.instances.length}
    return s
}

// generic membership

// generic print
function print_any(x) {
    if (typeof(x) == 'string') {PRINC(x)}
    else if (typeof(x) == 'boolean' || typeof(x) == 'number') {PRINC(x.toString())}
    else if (Array.isArray(x) == true) {
        PRINC("[")
        princ_list(x)
        PRINC("]") }
    else if (x instanceof Set)
       {PRINC("{")
        for (let y of x) {print_any(y);
                          PRINC(",")}
        PRINC("}")}
    else {x.selfPrint()}
}

// generic princ
function princ_any(x) {
    if (typeof(x) == 'string') {PRINC(x)}
    else if (typeof(x) == 'boolean' || typeof(x) == 'number') {PRINC(x.toString())}
}

// print a list sequence without brackets
function princ_list(x) {
    var n = x.length
    for (let i = 0; i < n; i++) {
        if (i > 0) PRINC(",")
        print_any(x[i])}
}


// create the class hierarchy
 var C_class = new ClaireClass("class",0,true)
 var C_any = new ClaireClass("any",0,false)
 var C_object = new ClaireClass("object",C_any,false)
 var C_thing = new ClaireClass("thing",C_object,true)

 // these are the primitive Javascript types that we want to import
 var C_primitive = new ClaireClass("primitive",C_any,false)
 var C_string = new ClaireClass("string",C_primitive,false)
 var C_integer = new ClaireClass("integer",C_primitive,false)
 var C_float = new ClaireClass("float",C_primitive,false)
 var C_boolean = new ClaireClass("boolean",C_primitive,false)
 var C_list = new ClaireClass("list",C_primitive,false)
 var C_set = new ClaireClass("set",C_primitive,false)

// boot
function boot() {
    var start = new Date()
    C_any.superclass = C_any
    C_class.isa = C_class
    C_class.superclass = C_any
    C_class.instances.push(C_class)
    var end = new Date() - start
	console.log("--------- Claire boot complete in ", end, "ms ----------------")
}

// any methods
function owner_any (x) {
    var test = Array.isArray(x)
    if (typeof(x) == 'string') return C_string
    else if (typeof(x) == 'boolean') return C_boolean
    else if (typeof(x) == 'number') 
       {if (Number.isInteger(x) == true) {return C_integer}
        else {return C_float}}
    else if (Array.isArray(x) == true) return C_list
    else if (x instanceof Set) return C_set
    else {return x.isa}
}

// launch boot
boot()

// small boot test
function bootTest() {
    console.log("test 1 -> ",owner_any(1).name)
    console.log("test 1.234 -> ",owner_any(1.234).name)
    console.log("test 'abc' -> ",owner_any('abc').name)
    console.log("test true -> ",owner_any(true).name)
    console.log("test class -> ",owner_any(C_class).name)
    console.log("test [1,2,3] -> ",owner_any([1,2,3]).name)
    console.log("test {1,2,3} -> ",owner_any(new Set([1,2,3])).name)
    console.log("-------------- test boot completed ----------------")
} 

// bootTest()

// *********************************************************************
// *  Part 2: Primitive methods (int, float, etc) + List & Set         *
// *********************************************************************

function max_float(x,y) {if (x > y) return x; else return y}
function min_float(x,y) {if (x < y) return x; else return y}

function _exp_float(x,y) {return Math.pow(x,y)}
function abs_float(x) {return Math.abs(x)}

function princ_integer(x) {PRINC(x.toString())}
function princ_float5(x) {PRINC(x.toString())}
function printFDigit_float(x,nDigit) {PRINC(x.toFixed(nDigit))}

// strings

// princ segment of size n
function princ_string8(s,n) {
    var m = s.length
    if (n < m) PRINC(s.substring(0,n))
    else {PRINC(s)
          for (let i = 0; i < (n-m); i++) {PRINC(" ")}}}

// lists and sets

function add_list(l,x) {l.push(x); return l}
function add_set(l,x) {l.add(x); return l}

// *********************************************************************
// *  Part 3: Object methods                                           *
// *********************************************************************

// *********************************************************************
// *  Part 4: Claire Environment & Errors                              *
// *********************************************************************

class ClaireEnvironment {

    constructor() {
        this.verbose = 1
    }
}

var ClEnv = new ClaireEnvironment()

// errors
class ClaireError extends Error {
    constructor(message,args) {
        super(message)
        this.name = "ClaireError"
        this.args = args
    }

    Close() { throw this}
}

function MakeError(message,args) {
    return new ClaireError(message,args)
}


// *********************************************************************
// *  Part 5: Miscellaneous                                            *
// *********************************************************************

// digit char to int
function digit_char(c) {return c - '0'}

// tformat should be done more completely with extraction of the ~S/A patterns
function tformat(s,verbose,args) {
    var n = 0           // which arg to print
    var j = s.indexOf("~")
    while (j != -1) {
        PRINC(s.substring(0,j))
        var c = s.charAt(j + 1)
        if (c == "A") princ_any(args[n])
        else if (c == "S") print_any(args[n])
        else if (c == "F")  {
            var c2 = s.charAt(j + 2)
            if (c2 == "%") {printFDigit_float(args[n] * 100,2); PRINC("%")}
            else printFDigit_float(args[n],digit_char(c2))
            j++}
        n++
        s = s.substring(j + 2,s.length)
        j = s.indexOf("~")}
    PRINC(s)
        }

// the universal print (string, char, etc.)
function PRINC(x) {
    process.stdout.write(x)
}

var timer_start

function time_set() {
timer_start = new Date()
}

function time_show() {
    var end = new Date() - timer_start
	console.log("counter[] Elapsed time: ", end, "ms")
    }

module.exports = {ClaireObject, ClaireThing, ClaireClass,
                  C_object, C_thing, C_class, C_any, C_primitive, C_string, C_integer, C_float, C_boolean, C_list, C_set,
                  ClEnv, tformat, MakeError,PRINC, princ_string8,princ_list,
                  max_float, min_float, princ_integer, princ_float5,printFDigit_float, _exp_float, abs_float,
                  size_class, add_list, add_set, owner_any, time_set, time_show, print_any}

console.log("------ ClaireKernel.js loaded ----------------")


