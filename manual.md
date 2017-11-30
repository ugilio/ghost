---
title: The GHOST Language Manual
sidebar: manual_sidebar
toc: false
permalink: manual
---
This guide introduces <span class="sc">ghost</span>, a new language for [timeline-based planning](https://ugilio.github.io/keen/intro) that aims to replace [<span class="sc">ddl</span>](https://ugilio.github.io/keen/intro#the-ddl-language).
The target reader is the developer who needs to learn to use the language effectively, hence this manual is meant to be a complete guide to <span class="sc">ghost</span> enriched by various code examples; a complete, formal specification of the language in EBNF form can instead be found [here](/ghostebnf).

While <span class="sc">ghost</span> is a completely new language, it has obviously been influenced by a number of popular languages: the reader might find sometimes constructs that recall the ones of Pascal, C++, Java, JavaScript, CoffeeScript, Python, and of course <span class="sc">ddl</span>.

## An Introduction to <span class="sc">ghost</span>
To introduce the language, it's easier to present a small example that can be used to give an idea of its syntax. The domain under consideration is that of a traffic light, whose color is allowed to go from green to yellow and then to red.

```ghost
domain TrafficLightDomain;

type TrafficLight = sv(Red, Green, Yellow);
```

This piece of code, although brief, already shows some of the syntax of <span class="sc">ghost</span>:

* the domain name is introduced by the `domain` keyword;
* type declarations start with the keyword `type` and use an equal (`=`) sign;
* state variables types use the `sv` keyword;
* state variable values are listed in parentheses;


This first version only declared a type for the traffic light and the allowed values, but it doesn't say anything about the valid transition constraints; let's change the code above this way:

```ghost
domain TrafficLightDomain;

type TrafficLight = sv
(
  Red -> Green;
  Green -> Yellow;
  Yellow -> Red;
);
```

Here, the type definition has been split over more lines, for readability purposes; instead of just listing simple values, each element between parentheses is now a transition from the left-side to the right-side value, separated by the `->` operator (arrow).

The careful reader might notice that semicolons, instead of commas, are now used to separate elements: this is because in <span class="sc">ghost</span> they can both be used as separating/termination symbols, and choosing when employing one or the other is a matter of personal style; the convention used in this thesis is that short elements, that can fit on a single line, are usually separated by comma, while more complex statements, each requiring on a line on their own, are instead separated by semicolons.

What if a value is allowed to transition to more than one value? In this case, the possible targets must be wrapped in parentheses (and separated by commas or semicolons according to preferences):

```ghost
type TrafficLight = sv
(
  Red -> Green;
  Green -> (Yellow, Red);
  Yellow -> Red;
);
```

These transitions however don't specify how long values are allowed to last; this is because in <span class="sc">ghost</span> most information can be left out, and defaults are used instead; for the case of duration, the default is `[0, +INF]`, so the above code, when reverted back to the simple `Green -> Yellow` transition, is equivalent to the following:

```ghost
type TrafficLight = sv
(
  Red [0,+INF] -> Green;
  Green [0,+INF] -> Yellow;
  Yellow [0,+INF] -> Red;
);
```

Let's use some fixed intervals for the durations of the Red, Green and Yellow states, for example 30, 20 and 10 respectively; in <span class="sc">ghost</span>, intervals having the same upper and lower bounds can be specified by just writing their value, instead of having to duplicate them. The example thus becomes:

```ghost
type TrafficLight = sv
(
  Red 30 -> Green;
  Green 20 -> Yellow;
  Yellow 10 -> Red;
);
```

Having seen how to define a type, let's now declare the two instances of this type (the components) to model the two traffic lights. After the code above just add:

```ghost
comp TL1 : TrafficLight;
comp TL2 : TrafficLight;
```

These two lines declare two components named `TL1` and `TL2`, both instances of the type `TrafficLight`.
Some things are worth to be noted:

* component declarations use the `comp` keyword;
* the name and the type are separated by the colon (`:`) sign instead of equals (`=`).


This concludes this introductory section; synchronizations are not introduced here because they deserve some additional explanation, but plenty of information can be found in the [appropriate section](#synchronizations).

The next sections will describe the <span class="sc">ghost</span> language in great detail.

## The basics
This section introduces the basic elements of the language, such as the syntax for valid identifiers, numbers, comments and so on, and describes the basic structure of a <span class="sc">ghost</span> file.

### Identifiers
Identifiers are sequences of alphanumeric characters, defined as uppercase and lowercase letters belonging to the Latin alphabet without any diacritic marks (`'A'..'Z','a'..'z'`), numbers (`'0'..'9'`) and the underscore character `_`; identifiers cannot start with a number, and language keywords cannot be used as identifiers: `Foo1` is a valid identifier, while `1Foo` or `domain` are not.

Identifiers are used to name user-defined entities such as types, components, state variable values, variables, constants.

### Numbers
Numbers are valid sequences of numeric characters (`'0'..'9'`) and can optionally be preceded by a plus (`+`) or minus (`-`) sign and represent integer numbers in base ten. No space is allowed between digits, but the underscore character (`_`) can be used to improve readability.

For example, valid numbers are `12`, `+100`, `- 26`, `45_000`; invalid examples are `45 000`, `7f`, `0x10`.

In addition, the keyword `INF` is interpreted as being a number having the special value of "infinity"; it is legal to specify positive and negative infinity as `+INF` and `-INF` respectively.

### Intervals
Intervals represent durations having a lower and upper bound, and are expressed as `[<lb>, <ub>]` where `<lb>` and `<ub>` are numbers and represent the lower and upper bound, respectively. If the upper and lower bound are the same, a single number can be used wherever an interval is expected.

Valid intervals are `[0,100]`, `[1, +INF]`, `[-7,-7]` and `-7`.

### Comments
Comments follow the same rules of Java or C++: single line comments are introduced by the `//` pair of characters, while multi-line comments are enclosed between {`/*`} and `*/` and can span multiple lines.

### Time Units
In <span class="sc">ghost</span> it is possible to specify time units by suffixing numbers with the unit name; they are treated as a compile-time multiplication by the time unit they represent.

Predefined time units in <span class="sc">ghost</span> are:

{::comment}

| name | value    | aliases |
| ---- | --------:|:-------:|
| ms   |    1     |         |
| sec  | 1000  ms | s       |
| min  |   60 sec | m       |
| hrs  |   60 min | h, hours|
| days |   24 hrs | d       |

{:/comment}

<table>
  <caption>Predefined time units in <span class="sc">ghost</span></caption>
  <thead>
    <tr>
      <th>name</th>
      <th style="text-align: right">value</th>
      <th style="text-align: center">aliases</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>ms</td>
      <td style="text-align: right">1</td>
      <td style="text-align: center"> </td>
    </tr>
    <tr>
      <td>sec</td>
      <td style="text-align: right">1000  ms</td>
      <td style="text-align: center">s</td>
    </tr>
    <tr>
      <td>min</td>
      <td style="text-align: right">60 sec</td>
      <td style="text-align: center">m</td>
    </tr>
    <tr>
      <td>hrs</td>
      <td style="text-align: right">60 min</td>
      <td style="text-align: center">h, hours</td>
    </tr>
    <tr>
      <td>days</td>
      <td style="text-align: right">24 hrs</td>
      <td style="text-align: center">d</td>
    </tr>
  </tbody>
</table>

For example, writing `10 s` is expanded to `10 * 1000 ms` and then to `10 * 1000 * 1`, which results in `10000`.

New time units can be defined, and existing units can be redefined or undefined. For example, if the default millisecond granularity is considered too fine, it is sufficient to redefine `sec` as being `1`: all other units will be accordingly changed (it is also advised to undefine `ms` to generate compile errors if that time unit is accidentally used).

Time unit definition is explained in section [Defining Time Units](http://127.0.0.1:4000/userguide#defining-time-units).

### Strings
The <span class="sc">ghost</span> language does not have strings.

### Separators
Elements in lists or line of code are separated by either the comma (`,`) or semicolon (`;`) characters. The use of either one is a matter of personal style; a common convention is to use commas when dealing with simple elements, which possibly can coexist in the same line, and to use semicolons when the involved elements are more complex or require to stand on one (or more) lines on their own. Moreover, the separator after the last item of a list is optional.

```ghost
type TrafficLight = sv
(
  Red -> Green;
  Green -> (Yellow, Red);
  Yellow -> Red;
);
```
{: .line-numbers}
In this example, transition constraints are separated by semicolons; in line 4 though, a comma is used to separate the simple values `Yellow, Red`.

### Implicit and Unused Values
In <span class="sc">ghost</span>, an important rule is "Name only what it's meaningful"; unused variables, parameters and default values can generally be omitted, or replaced by the placeholder character `_` (underscore).

For example, if a state variable value does not take parameters, parentheses can be omitted; or, if a state variable does take parameters, but in the context where it is being used they are left unbound, the whole parameter list can be omitted; as a variation, if only some parameters are unbound those can be replaced by the placeholder.

Examples of where it is appropriate to omit values are provided throughout this guide.

### Operators
<span class="sc">ghost</span> supports arithmetic, boolean and temporal operators. Arithmetic operators can generally be used wherever a numeric expression is expected, even if this is not always the case when variables are involved due to limitations in the <span class="sc">ddl</span> language that <span class="sc">ghost</span> is compiled to.
The discussion of operators though requires a dedicated space, and is thus demanded to section [Expressions](#expressions).

### File Structure
Each <span class="sc">ghost</span> file starts with an optional `domain <name>` or `problem <name>` statement, where `<name>` is an user-defined identifier.

Then, zero or more `import <name>` statements follow; the effect of the statement is to import the specified domain as if all its definitions (types, components, constants) were defined in the importing file; transitive imports are imported as well, but compiler directives remain confined to the file where they are declared in, so an imported file cannot change defaults or redefine time units out of its local scope.

It is only possible to import domains, problems can not be referenced from other files; if neither `domain` nor `problem` is specified, the file is assumed to contain an unnamed `problem`.

While the order of `domain`/`problem` and `import` statements is fixed, other statements in the file (type declarations, components and so on) can follow in any order. All these statements (except possibly the last one) must be separated by comma or semicolon characters (see section [Separators](#separators)).

<span class="sc">ghost</span> files use the file extension `.ghost`.

## Type Declarations
Type declarations are introduced by the keyword `type`, followed by the name of the type being declared, an equal sign `=`, and a keyword specifying which kind of type is being declared (`sv`, `resource`, `int` or `enum`).

More concisely:
> **type** *name* = **sv** \| **resource** \| **int** \| **enum** ...


The syntax of the remaining part of the declaration depends on the kind of entity that is being defined, and is detailed in the next sections.

### Simple Types
Simple types are interval and enumerated types. They can be used as parameters in state variable values, but components cannot be instantiated from them.

#### Interval Types
Interval types use the keyword `int`, and their declaration is simply the definition of the valid range they are allowed to assume, specified as an interval.
> **type** *name* = **int** *interval*

Example:
```ghost
type angle = int [-360, 360];
```

#### Enumerated Types
Enumerated types can be used to specify entities that consist of discrete, named values. The allowed identifiers are specified as a list, between parentheses, following the `enum` keyword, as follows:
> **type** *name* = **enum** (*value1*, *value2*, ... *valueN*)

Example:
```ghost
type speed = enum(Slow, Moderate, Fast);
```

### Component Types
Component types refer to complex types that can be used to instantiate components: they are state variables and resources. At runtime, components have timelines, where the planner allocates tokens.

The generic syntax of a component type declaration is
> *[controllability]* **type** *name* = **sv** \| **resource** ...

where *controllability* is either the keyword `external` or `planned`. External components are completely out of the planner control, while planned components can have planning decisions imposed to, possibly only partially. If not specified, by default the component type is considered `planned`.
The modifier is optional, and if not specified the default is used. Default values can be overridden (see section [Setting Default Values](#setting-default-values)).

#### Resources
Resources, unlike state variables, don't have named values, but are characterized by an amount. Resources can be either *renewable* or *consumable*:

Renewable resources
:    have their amount decreased when they are used, but they come back to their original capacity as soon as usage terminates; for example, they can be used to model space requirements: a bag of capacity *x* can be used for an amount up to *x*; when its usage terminates its capacity returns automatically back to *x*.

Consumable resources
:    are characterized by a minimum and maximum amount, and are initially considered to be at the maximum amount; unlike renewable resources though, their level decreases by the means of *consumption* actions, and can be increased by explicitly executing a *production*; for example, a fuel tank might be modeled as a consumable resource.


The syntax for declaring *renewable* resources is
> *[modifiers...]* **type** *name* = **resource**(*capacity*)

while *consumable* resources can be declared with
> *[modifiers...]* **type** *name* = **resource**(*min*,*max*)

where `capacity`, `min` and `max` are positive numbers.

Resources can be more complicated, and also contain synchronizations and variable binding, but the discussion of these advanced aspects is demanded to sections [Synchronizations](#synchronizations) and [Variable Binding](#variable-binding).
When using synchronizations, it is possible to omit the amount values and use instead the placeholder character (`_`): these types then may not be used as-is but their values will have to be specified at component declaration time (see section [Inheritance in Resource Types](#inheritance-in-resource-types)).

Examples:
```ghost
type bag = resource(10); //a renewable resource type
type tank = resource(0,100); //a consumable resource type
```

#### State Variables
State variables are the most important type in timeline-based planning. Their simplest definition, consisting in just listing the allowed values, can be written as
> *[modifiers...]* **type** *name* = **sv**(*value1*, *value2*, ... *valueN*)

but it can be greatly enriched according to the needed complexity. For this reason, state variables are discussed in detail in the next section.

## State Variables Types
The examples of state variables seen until now made use of a simplified syntax; when used to their full extent though, their structure resembles the following:

> *[modifiers...]* **type** *name* = **sv** \\
> (
> 
> transition:
> :    *transition constraints...*
>
> synchronize:
> :    *synchronization rules...*
>
> variable:
> :    *variable specifications...*
>
> );

The three keywords `transition`, `synchronize` and `variable` are used to introduce the sections devoted to specify transition constraints, synchronization rules and variable specifications, respectively. By default, an unnamed section is considered to be the `transition` one; sections can be specified multiple times in whatever order.

### Transition Constraints
Transition constraints are declared in the `transition` section, which is also the default one if no keyword was specified; in its simplest form, this section only consists of a list of state variable values, and in this case does not properly contain *transition constraints*.

#### Simple Constraints

The first form of a somewhat useful definition comes when proper constraints are specified: the syntax of a single constraint can be initially written as
> *Value* *[interval]* -> (*Value1*, *Value2* ... *ValueN*)

and it specifies which values the state variable is allowed to assume when changing its status from the value `Value`. The optional interval describes how long the state variable can remain in the `Value` state, and if unspecified is assumed to be `[0, +INF]`.
If a value can transition to only one value, parentheses are optional.

In the following example, a type is defined as having three possible values, `A`, `B` and `C`; of these, `C` is a sink since it does not have outgoing transitions; `A` can transition to only one possible state, while `B` has two possible options.

```ghost
type aType = sv(
  A -> B;
  B -> (A, C);
  C
);
```

#### Parameters
So far, all state variables had simple values, without any parameter. This is just the simplest case, but in general values are allowed to have parameters, and to express constraints on them in transitions and synchronization rules.
Parameters are declared when defining values, in the left part of a transition constraint, according to this syntax:
> *Value*(*type1 [name1]*, *type2 [name2]*, ... *typeN [nameN]*) -> ...

that is, formal parameters are specified as a list of *type* and *name* pairs in the left part of a transition constraints; only simple types (see section [Simple Types](#simple-types)) can be used, and the name is optional if the parameter is not to be used in the transition constraint.

```ghost
type aType = sv(
  A(angle, speed) -> B;
  B(speed theSpeed) -> (A(_,theSpeed), C);
  C
);
```
The example above contains quite an amount of new information:

* Value `A` has two parameters, `B` has one, and `C` has none.
* `A`'s parameters are of type angle and speed, respectively, and are unnamed.
* Even though `B` has one parameter, it is not used in the transition constraint originating from `A`, so there `B` is referred to without arguments.
* `B` has a parameter named `theSpeed` of type `speed`
* `B`'s parameter is constrained to be the same as `A`'s second parameter in the transition from `B` to `A`; since the first parameter of `A` is not constrained, the placeholder is used instead (here the placeholder is needed because there is no way otherwise to constrain the second parameter of `A`).


Some word about unused parameters and placeholders is needed: parameters are specified in the left part of a transition constraint, and there they cannot obviously be omitted; what can be omitted is their name, if they are not used in the transition constraint[^1].
In the body of a constraint (the right part), it is very uncommon to constrain all parameters: unconstrained parameters can be replaced by the placeholder (the "`_`" character) and, if none of them is needed, they can be completely omitted, in which case the parentheses after the name of the state variable can be omitted too: this is the case of `B` in line 2.

#### Local Variables
In the body of a transition constraint it is possible to make use of local variables. Local variables are introduced by the `var` keyword according to this syntax:
> **var** *name* = ...

and can hold different kind of values:

* the result of arithmetic or boolean operations;
* references to other variables or parameters;
* references to other state variable values;
* references to resource actions;
* numeric or enumerated literals;
* constants;


Variables can be useful to avoid code duplication, improve readability and explain choices, among other things. Variables cannot be modified once they are defined: they express an equality relationship between the right part (the expression) and the left part (the variable), and they are not memory locations that can be modified at a later time as in many imperative programming languages; in fact, statements in transition constraints (and synchronization rules) do not represent sequential programs, but a set of relations.

```ghost
type ComplexType = sv
(
  A(atype x) -> (
    var y = x+10;
    B(y,x)
  );
  B(atype x,atype y)
);
```
In the above example, the local variable `y` is assigned the value of parameter `x`, plus *10*; that variable is used later to impose a constraint on `B`; in this case the use of a variable seems unnecessary, since the constraint could have just been written as `B(x+10,x)`.

#### Boolean Constraints
Variables, parameters and operators can be used to express boolean constraints; boolean constraints are standalone expressions (that is, not involved in variable assignments) that evaluate to a boolean value, and are used to restrict the applicability of a transition constraint.

For example, in the following code fragment the transition from `A` to `B` is permitted only if `A`'s argument is greater than *10*.
```ghost
type SomeType = sv (
  A(atype x) -> (x > 10, B),
  B
);
```

#### Controllability
As mentioned in section [Component Types](#component-types), external components are not under the control of the planner, while planned variables are, at least partially; in fact, it is possible that the planner is able to impose certain values, while it might not be able to directly control some others; in other words, it cannot schedule the duration of a certain value and can only wait for it to complete: these values are called *uncontrollable*, and one might say that an external component is just a component made of only uncontrollable values.

To mark a value as controllable or uncontrollable, it should be prefixed by the keywords `contr` or `uncontr` respectively; if no value is specified the exact semantics is determined by the planner.

Obviously, it does not make sense to specify the controllability on sink values, because a value without outgoing transitions can never be changed to something else.

To summarize, the syntax for proper (i.e., not sink) transition constraints is
> **[contr\|uncontr]** *Value(type name...)* *[interval]* -> (*constraints...*)

### Synchronizations
Synchronizations are declared in the optional `synchronize` section of a state variable type. Their syntax resembles the one of transitions constraint, which is as follows:
> *Trigger(param1, param2, ... paramN)* -> (*synchronization rules...*)

where `Trigger` is the name of a value declared in a transition constraint section, followed by a list of parameters (without types) matching the formal parameter list.

Compared to transition constraints, synchronizations don't use the `contr` or `uncontr` keywords, and they don't have an interval; similarly to transition constraints, the parentheses in the synchronization body (the right part) can be omitted in the case of very simple rules.

#### Simple Synchronizations

A first example of a state variable type declaring a synchronization is the following:
```ghost
type aType = sv (
  A -> B, B -> A
synchronize:
  A -> meets aComponent.SomeValue
);
```
Observing this fragment of code, we can say that:

* The type `aType` has two values, `A` and `B`, with transitions between the two.
* There is a synchronization having `A` as trigger, which states that when any state variable belonging to this type leaves the `A` state, the component `aComponent` assumes the value `SomeValue` (the definition of `aComponent` is not shown here).


#### Temporal Constraints
Temporal operators are discussed in section [Temporal Expressions](#temporal-expressions). The syntax of temporal constraints is however worth noting:
> *[from] temporal-operator to*

Where `temporal-operator` is something like `meets`, `during` and so on, `to` is an instantiated value on some component, and `from` is an optional instantiated value that if omitted refers to the value named by the trigger of the synchronization rule.

Instantiated values have this name because they refer to a specific instance of a state variable value, often constrained to have particular values of its parameters (explained in the next section).

#### Parameters and Placeholders
In synchronizations, types must not be repeated in the trigger's parameter list, because parameter types are specified in the transition constraint section. Moreover, according to the <span class="sc">ghost</span>'s rule "Name only what it's meaningful" introduced in section [Implicit and Unused Values](#implicit-and-unused-values), specifying parameters might not be necessary at all, if none of them is used in the synchronization body; in fact, it is perfectly normal to name only the necessary parameters, using the placeholder character ("`_`") for the unused ones as described in section [Parameters](#parameters), and just skipping the parameter list where appropriate.

For example, the following code is perfectly legal:
```ghost
type RobotBaseType = sv (
  GoingTo(coord x, coord y) [10, 30] -> At(x, y);
  At(coord x, coord y) -> GoingTo;
synchronize:
  GoingTo -> during Platine.PointingAt(0,0);
);
```

In this example, the synchronization on `GoingTo` does not need to repeat the parameters in the trigger because they are not used in the synchronization body.

In the following example, the first parameter of `TakingPicture` is not used and is thus replaced by the placeholder; the other four parameters instead are used to express two constraints:
```ghost
type CameraType = sv (
  CamIdle -> TakingPicture;
  TakingPicture(file_id, coord, coord, angle, angle) 10 -> CamIdle;
synchronize:
  TakingPicture(_, x, y, pan, tilt) -> (
    during RobotBase.At(x, y);
    during Platine.PointingAt(pan, tilt);
  );
);
```

#### Local Variables
Local Variables can be used the same way they are used in transition constraints (see section [Local Variables](#local-variables)). It is important to highlight though that variables holding references to instantiated values can be used in temporal constraints; to understand why this might be desirable, consider the following example:
```ghost
type MissionTimelineType = sv (
  Idle -> (TakingPicture, Communicating, At);
  TakingPicture(file_id, coord, coord, angle, angle) 10 -> Idle;
  Communicating(file_id) [10, 20] -> Idle;
  At(coord, coord) -> Idle;
synchronize:
  TakingPicture(file_id, x, y, pan, tilt) -> (
    var val1 = Camera.TakingPicture(file_id, x, y, pan, tilt);
    var val2 = Communication.Communicating(file_id);
    meets MissionTimeline.Idle;
    contains val1;
    contains(_,0) val2;
    val1 before val2;
  );
  At(x, y) -> equals RobotBase.At(x, y);
);
```
{: .line-numbers}
Here, the synchronization on line 7 states that the two activities (lines 8, 9) must be contained in the lifespan of `TakingPicture` (lines 11, 12), and also that one activity must precede the other (line 13); the usage of variables helps a lot to express this "tripartite relation".

#### Alternative Branches
As the previous example has shown, constraints in a synchronization block are not alternatives, but must all hold for the synchronization to be enabled; this is different from the semantics of transition constraints, where the named values represented alternative "ends" for the transition.

In synchronizations, to express alternatives the `or` keyword must be employed; it is used to separate two synchronizations bodies that thus represent two possible alternatives to enable the synchronization rule.

> *Trigger(params...)* -> (*alt 1...*) **or** (*alt 2...*) **or** ... (*alt N...*)

#### Resource Constraints
Besides temporal constraints between state variable values, it is also possible to express constraints based on resources. Their syntax is the following:

> **require** \| **produce** \| **consume** *resource*(*value*);

where `require` is to be used on renewable resources, and `produce` and `consume` on consumable resources (see section [Resources](#resources)); `resource` is the name of the referenced resource, and `value` is the amount considered in the action.

Resource operations too, just like instantiated values of state variables, can be assigned to local variables; however, using that value in a temporal relation does not make much sense (with the exception of `equals`, possibly).

In the following example, the `Load` value requires the renewable resource `SpaceAvailable` to have at least *10* units of free space left.
```ghost
type aType = sv (
  Load -> Unload, Unload -> Load
synchronize:
  Load -> require SpaceAvailable(10);
);
```

#### Synchronizations in Resources
Resources were presented in section [Resources](#resources), and their definition seems quite simple. However, they are components too, and because of this it is possible to define synchronizations on resources too, using resource actions as triggers. To handle this situation, the synchronization syntax of state variables can be used on resources too, as demonstrated in the following example:

```ghost
type aResource = resource(10,
synchronize:
  require(x) -> x <= 5;
);
```

In this example, a renewable resource having capacity *10* permits to be used only in bursts smaller than *5* units; this means it is possible to have three concurrent usages of *3* units each, while a single request of *9* units would be rejected.

### Variable Binding
<span class="sc">ghost</span> supports variable binding, needed for generic synchronizations. The idea is that component types can declare variables to represent other components, and synchronizations can be written using them as if they were referring a real component; later, when the type is used to define a component, the variables it contains must be bound to real state variables or resources; those familiar with Object-Oriented Programming might spot an analogy with object fields.

Variables are declared in the `variable` section of a state variable or resource, with a syntax very similar to the one used to declare components:
> *name* : *type*


Compared to component declarations, here the keyword `comp` is missing.

The following example illustrates the complete traffic light domain, written in <span class="sc">ghost</span> making use of generic synchronizations and variable bindings:

```ghost
domain TrafficLightDomain;

type TrafficLight = sv (
	Red 30 -> Green;
	Green 20 -> Yellow;
	Yellow 10 -> Red;
synchronize:
	Green -> starts other.Red;
variable:
	other : TrafficLight;
);

comp TL1 : TrafficLight[TL2];
comp TL2 : TrafficLight[TL1];
```

Here, the traffic light type defines a generic synchronization stating that when this traffic light becomes `Green`, another traffic light, identified by the variable `other`, should become `Red`; the written rule is generic: it applies to couples of traffic lights, one being the component that becomes `Green`, and the other being the one identified by `other`.

Components are bound together when they are created: components needing variable binding need to be supplied with a component list after their type, in square brackets; binding happens following the order in which variables where declared, so the first component passed in will be bound to the first declared variable, and so on.
Alternatively, to prevent errors, it is possible to explicitly name the variable the component should be bound to; in this case the previous example becomes:

```ghost
comp TL1 : TrafficLight[other = TL2];
comp TL2 : TrafficLight[other = TL1];
```

### Type Inheritance
Inheritance is the ability of defining a type that, instead of being written from scratch, is based upon the definitions already contained in another type (the parent); the parent's definitions become available in the child as if they were written directly there, without limiting the possibility of adding new ones.

In <span class="sc">ghost</span>, the syntax for declaring children types is
> **type** *subType* = **sv** \| **resource** *parentType*(*definitions...*);

where `subType` is the new type being defined and `parentType` the type containing the definitions that must be available in `subType`; as the reader might see, the only difference with a regular type declaration is the use of the parent type name between the `sv` or `resource` keyword and the definitions.

Children types inherit all values, transitions constraints, synchronization rules and variables of the parent type; multiple levels of inheritance are possible, meaning that a children inherits from all its ancestors. Moreover, an important property of inheritance is that descendant types can be seen as instances of the parent type in contexts where the ancestor types are expected: descendant types, in fact, have all the values and parameters of their ancestors, plus possibly others.

#### Overriding Definitions

Children can override, but not undefine, ancestor-defined transition constraints and synchronizations rules; overriding means declaring again the same transition constraint or synchronization rule, with a different body and/or duration; for transition constraints, the formal parameter list of the parent and the child must match.
In the case that the overridden definition should enrich the original one instead of replacing it, it is possible to use the `inherited` keyword as a placeholder for the parent definition; regarding durations in the left part of a transition constraints instead, if they are not specified they are assumed to remain the same as declared in the parent.

Some examples to better illustrate these concepts:

```ghost
type parent = sv (A -> B, B -> A);
type child = sv parent (
  A -> (B,C);
  C -> A;
);
```
In the above example, the type `child` is defined having `parent` as ancestor; the former inherits all the parent's transition constraints while adding a new value, `C`, and redefines the constraint on `A`. The code for `child` is semantically equivalent to the following:
```ghost
type child = sv (
  A -> (B,C);
  B -> A;
  C -> A;
);
```
The same result could also have been achieved by using the `inherited` keyword:
```ghost
type parent = sv (A -> B, B -> A);
type child = sv parent (
  A -> (inherited,C);
  C -> A;
);
```

#### Overriding Controllability
Another aspect worth to note is that type inheritance permits to override the settings related to the controllability; in other words, it is possible to declare a child `external` where the parent was `planned`, or vice versa.

To override the controllability setting for a single value it is necessary to redefine the corresponding transition constraint; the `inherited` keyword, however, can be employed to reduce the amount of code to a minimum.

The following example instead defines a child type which is the same as the parent, but it represents a regular planned component instead of an external one:
```ghost
external type parent = sv (A -> B, B -> A);
planned type child = sv parent;
```

To override single controllability values instead:
```ghost
type parent = sv (
  uncontr A -> B,
  B -> A
);
type child = sv parent(
  contr A -> inherited
);
```
In this case, `child` has the exact same transitions of `parent`, but `A`'s value is controllable.

#### Inheritance in Resource Types
Inheritance can be employed in resource types too; a typical use case would be to define some general synchronization rules, and to declare child types that make use of these rules using different amounts:
```ghost
type bag = resource (10,
synchronize:
  require(x) -> x <= 5;
);
type bigBag = resource bag(20);
type smallBag = resource bag(6);
```

In this example, the rule is defined in the `bag` resource type, and is later reused by the two types `bigBag` and `smallBag`, that differ only in their capacity.

To extend this concept further, if a parent resource type is only used to provide synchronization rules for its descendants, it is possible to omit amounts at all and use the placeholder character ("`_`") instead; in this case the previous example becomes:
```ghost
type bag = resource (_,
synchronize:
  require(x) -> x <= 5;
);
type bigBag = resource bag(20);
type smallBag = resource bag(6);
```
Obviously, the `bag` type cannot be used in a component definition without specifying its values.

There is also another possibility though, namely extending a resource type without changing its capacity but adding a synchronization rule:
```ghost
type bag = resource (10);
type slowBag = resource bag(
synchronize:
  require(x) -> x <= 5;
);
```
Here, `slowBag` adds a synchronization rule to the existing type `bag`; the capacity is not specified, hence it is assumed to be the one of the parent.

Instead of omitting the capacity, it would have been possible to use the placeholder character; this can be particularly useful for consumable resources, where one might want to change only the minimum or maximum value while leaving the other unchanged:
```ghost
type tank = resource (0,10);
type bigTank = resource tank(_,15);
```
In the previous example, `bigTank` is a `tank` with a greater capacity.

## Components
After declaring component types, actual instances can be created by the means of component declarations; usually, type definitions are written in a domain file, while component declarations, which represent the real objects of a particular situation, are put in the problem file together with initial conditions and goal. While this is the recommended approach, <span class="sc">ghost</span> does not impose restrictions on what's to be inserted where, leaving the user free of deciding the appropriate conventions.

As seen before in section [An Introduction to <span class="sc">ghost</span>](#an-introduction-to-ghost), a component declaration, in its simplest form, follows this syntax:
> **comp** *name* : *type*;

that is, component definitions are introduced by the `comp` keyword, followed by the desired name of the component, a colon character ("`:`") and the name of the type whose the component is an instance; only state variable and resource types can be used.

### Expressing Variable Bindings

Component types can however have variables that require bindings; in this case, as already described in section [Variable Binding](#variable-binding), it is mandatory to list the components to be bound to the declared variables in square brackets after the type name, optionally specifying the name of the variable to bind to:
> **comp** *name* : *type* '['*[varName1 =] comp1, ..., [varNameN =] compN* ']';

If a variable name is not specified, the position of the component in the list is used instead to determine which variable it should be bound to.

### Anonymous Types
So far, components were always instances of previously-defined types. It is however possible to specify constraints, rules and so on directly in the component definition, instead of having to instantiate a named type; the component in this case is said to belong to an *anonymoys type*, since the type is not explicitly named anywhere.

The syntax to declare a component of this kind is very similar to the one used for types; the differences are that the `comp` keyword is used instead of `type`, and the colon character is used instead of equals:


> *[modifiers...]* **comp** *name* : **sv** \\
> (
> 
> transition:
> :    *transition constraints...*
> 
> synchronize:
> :    *synchronization rules...*
> 
> );

Obviously, it does not make sense to specify a `variable` section in anonymous types, since generic synchronizations cannot be used because the anonymous type is being used by exactly one component.

What follows is an example taken from the satellite domain [introduced in KeeN User Guide](https://ugilio.github.io/keen/userguide#a-quick-tour), where a component is defined using an anonymous type:
```ghost
comp PointingMode : sv (
	Earth [1, +INF] -> (Slewing, Comm, Maintenance);
	Slewing 30 -> (Earth, Science);
	Science [36, 58] -> Slewing;
	uncontr Comm [30, 50] -> (Earth, Maintenance);
synchronize:
	Science -> before PointingMode.Comm;
	Comm -> during GroundStationVisibility.Visible;
);
```

#### Anonymous Types in Resources
Resources use a similar syntax, except that the only allowed section is `synchronize`:

```ghost
comp aResource : resource(10,
synchronize:
  require(x) -> x <= 5;
);
```


### Inheritance and Anonymous Types
Since it is possible to use anonymous types, it is quite natural that inheritance is available to anonymous types too; this feature has some interesting use cases, like the ability of inheriting all the properties of a component type while allowing to change a single particular aspect for a selected instance; or, the ability of redefining the controllability of a value, or to declare a component as external while its type would be normally be planned.

Anonymous types obtained by inheritance have a slightly different syntax in that it is not necessary to use the `sv` or `resource` keyword, but the declaration resembles that of a regular component with an added type body:
> **comp** *name* : *parentType*(*declarations...*);

In the following example, two components are created having anonymous types both inheriting from the `parent` type:
```ghost
type parent = sv (A -> B, B -> A);

comp firstChild : parent(C, A -> (B,C) );
external comp secondChild : parent;
```
In the case of `firstChild`, its anonymous type adds a new value, `C`, and overrides a transition constraint for `A`; in the case of `secondChild` instead, its anonymous type is identical to `parent`, except that it defines an external variable instead of a planned one.

Being able to create anonymous types based on existing types means that it might be necessary to specify variable bindings, if any of the ancestor types made use of variables. If this is the case, variable bindings must be specified between square brackets before new main body of the anonymous type (i.e., the parentheses). The following example clarifies this:

```ghost
type TrafficLight = sv (
	Red 30 -> Green;
	Green 20 -> Yellow;
	Yellow 10 -> Red;
synchronize:
	Green -> starts other.Red;
variable:
	other : TrafficLight;
);

comp TL1 : TrafficLight[TL2];
comp SwissTL : TrafficLight[other = TL1](
  Red 20 -> YellowRed;
  YellowRed 10 -> Green;
);
```
Here, the component `SwissTL` is used to model a Swiss traffic light where the yellow light is lit up together with the red one before transitioning to green; in the `SwissTL` declaration the variable binding required by the parent type is made (by binding `TL1` to the `other` variable); then, the transition constraint for `Red` is overridden and a new value and transition constraint is added (`YellowRed`).

#### In Resources
As seen in section [Inheritance in Resource Types](#inheritance-in-resource-types), it is possible to define resource types having synchronization rules, and use inheritance to reuse them. Unsurprisingly, defining anonymous types based on a parent resource type can be easily done.

A previous example where three explicit types were involved can be changed as follows:
```ghost
type bag = resource (_,
synchronize:
  require(x) -> x <= 5;
);
comp bigBag : bag(20);
comp smallBag : bag(6);
```

A source of confusion might be the (quite unlikely) case of an anonymous type descending from a resource type that requires variable binding; in this case, the same rule about state variables applies: bindings first between square brackets, followed by the rest (which for resources means amounts and then new definitions).
```ghost
type aType = resource(_,_,
synchronize:
  consume(x) -> (x > 5; meets alarm.BigBurst(x)) or (x <= 5);
variable:
  alarm : AlarmType;
);

comp anAlarm : AlarmType;
comp normalResource : aType[anAlarm](0,15);

comp paranoidResource : aType[anAlarm](0,20,
synchronize:
  produce(x) -> (x > 5; meets alarm.BigBurst(x)) or (x <= 5);
);
```
This admittedly complicated example describes a situation where:

* the consumable resource type `aType` triggers an alarm if a large amount of resource is requested all at once; if, on the contrary, the request is under the threshold, no alarm is activated;
* the resource `normalResource`, which binds the alarm instance `anAlarm` to the required variable, is an instance of an anonymous type deriving from `aType` specifying values of 0 and 15 for the minimum and the maximum, respectively.
* the resource `paranoidResource` is similar to the previous one, but it also activates the alarm if it is filled too quickly.


## The Initialization Section
The initialization section is the place where known facts about the initial state of the system and desired goals are specified, together with other problem-specific parameters. It is introduced by the keyword `init`, followed by a couple of parentheses marking the body, where declarations are written; as usual, if there is only one declaration (very unlikely), the parentheses can be omitted.

The syntax is thus:
> **init** ( *declarations...* )

Usually this section should be written in the problem file, since it describes the situation of a specific scenario, but this is not enforced by the language in any way. It is legal to have multiple `init` sections in a file: from the compiler point of view, all definitions found in all `init` sections are merged together as if they were declared in an unique one.

Initialization sections may contain fact and goals, together with variable definitions if needed; the problem's temporal parameters are specified as variable definitions as well.

### Temporal Parameters
The initialization section makes use of three special variables, `start`, `horizon` and `resolution`. If the developer explicitly defines these variables, the developer-specified value is used; otherwise, the system uses the default values.
These variables have the following meaning:

start
:    It is the first available time instant: the planner's clock starts at this time. It defaults to 0.

horizon
:    The last available time instant; the planner can plan up to the horizon. It defaults to 1000.

resolution
:    The number of "time units" in which the horizon is subdivided; it defaults to `horizon`-`start`.

### Facts and Goals

Facts are instantiated values of components (see section [Temporal Constraints](#temporal-constraints)) with additional temporal constraints specifying their start time, end time and duration. Goals have the exact same structure, and the only difference with facts is semantic: while facts are inherently true and thus given for granted, goals are yet-to-decide facts that must be proven right by the planner.

The syntax of facts and goals is:
> **fact** \| **goal** *instantiated-value* [**at** [**start**=]*start* [**duration**=]*duration* [**end**=]*end*]

The three intervals signal the start time, the duration, and the end time of the specified instantiated value, and may optionally be preceded by the keywords `start`, `duration` and `end`, respectively, to improve readability; as usual, values are optional, and if unspecified the default value for intervals (usually `[0, +INF]`) will be employed.

A simple example:
```ghost
init fact ActivityLed.Off at 0;
```
Here, it is stated that at time instant *0* the component `ActivityLed` has the value `Off`; since the duration and the end are not specified they default to `[0, +INF]`, meaning that a specific duration is not fixed; in other words, we know that initially the led is switched off, but we don't know when it will be light up.

In the following slightly more complex example two facts are stated: the first one specifies which are the start and end intervals, implying that the duration is left to its default value, while the second one does the same without naming the intervals, thus requiring the usage of the placeholder character for the duration.
Finally, the goal states that we must be communicating somewhere in the future, but not before instant *10*.
```ghost
init (
	fact PointingMode.Earth at start=0 end=[1, +INF];
	fact GroundStationVisibility.Visible at 0 _ [1, +INF];
	
	goal PointingMode.Communicating at start=[10, +INF];
)
```

## Expressions
Expressions in <span class="sc">ghost</span> can be arithmetic, boolean or temporal; leaving aside temporal expressions, which are used in some specialized contexts, the other kinds of expression can generally be used wherever a value of their type is expected. While this is true for expressions whose value can be statically determined at compile time, it might not always be the case when variables and parameters are involved; the reason of this behavior is that <span class="sc">ghost</span> must be compiled to <span class="sc">ddl</span>, whose support for arithmetic operations is limited: most notably, <span class="sc">ddl</span> lacks division and modulus operators.

For example, the following can be compiled without problems:
```ghost
const MAX = 100;
type halfTank = resource(0,MAX/2);
```
because the compiler can determine at compile time that the second line is equivalent to
```ghost
type halfTank = resource(0,50);
```

The following code is however problematic:
```ghost
comp aComp : sv(
  Start(fuel) -> Stop, Stop -> Start;
synchronize:
  Start(amnt) -> (consume tank1(amnt/2), consume tank2(amnt/2))
)
```
because there is no way in <span class="sc">ddl</span> to express a constraint like *y = x / 2*. A possible workaround to this situation is reversing the constraint so that it uses a multiplication instead of a division:
```ghost
comp aComp : sv(
  Start(fuel) -> Stop, Stop -> Start;
synchronize:
  Start(amnt) -> (
    var y = _; //unbound variable
    amnt = 2*y; //constraint
    consume tank1(y);
    consume tank2(y);
  )
)
```
While this reversal *might* be performed by the compiler in principle, developers should not assume that such an optimization is available in <span class="sc">ghost</span> compiler implementations.

This workaround could be employed in this particular case, but there is nothing to do when divisions involve more complex expressions; for example, a non-linear constraint such as *y = 2 / x* cannot be accepted by <span class="sc">ddl</span>.

### Arithmetic and Boolean Expressions
The basic elements of expressions can be:

* numeric literals;
* variables;
* parameters;
* constants;


Basic elements can be combined by the means of operators, which are listed in table below in descending order of priority (highest priority first).

{::comment}

| priority |        operator           | description               |
|:--------:|:-------------------------:|---------------------------|
|    1     | + <br> -                  | unary plus<br> unary minus
|    2     | * <br> / <br> %           | multiplication<br> division<br> modulus
|    3     | + <br> -                  | addition<br> subtraction
|    4     | < <br> <= <br> > <br> >=  | less than<br> less than or equal<br> greater than<br> greater than or equal
|    5     | = <br> !=                 | equality<br> inequality

Arithmetic and Boolean operators in <span class="sc">ghost</span>
{:/comment}

<table>
  <caption>Arithmetic and Boolean operators in <span class="sc">ghost</span></caption>
  <thead>
    <tr>
      <th style="text-align: center">priority</th>
      <th style="text-align: center">operator</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center">1</td>
      <td style="text-align: center">+ <br /> -</td>
      <td>unary plus<br /> unary minus</td>
    </tr>
    <tr>
      <td style="text-align: center">2</td>
      <td style="text-align: center">* <br /> / <br /> %</td>
      <td>multiplication<br /> division<br /> modulus</td>
    </tr>
    <tr>
      <td style="text-align: center">3</td>
      <td style="text-align: center">+ <br /> -</td>
      <td>addition<br /> subtraction</td>
    </tr>
    <tr>
      <td style="text-align: center">4</td>
      <td style="text-align: center">&lt; <br /> &lt;= <br /> &gt; <br /> &gt;=</td>
      <td>less than<br /> less than or equal<br /> greater than<br /> greater than or equal</td>
    </tr>
    <tr>
      <td style="text-align: center">5</td>
      <td style="text-align: center">= <br /> !=</td>
      <td>equality<br /> inequality</td>
    </tr>
  </tbody>
</table>

These operators are quite common among a lot of popular programming languages. As one might expect, standard precedence rules can be changed by using parentheses.

### Temporal Expressions
Temporal constraints are used in synchronization bodies (see section [Synchronizations](#synchronizations)).
It must be noted that unlike other languages, <span class="sc">ddl</span> among these, <span class="sc">ghost</span> does not make use of [Allen's Relations](https://ugilio.github.io/keen/intro#allens-relations): while they can express all the possible relations two intervals can be in, they are sometimes counter-intuitive (e.g. `OVERLAPS` vs `OVERLAPPED BY`) and quite verbose to write.
As [[COU2016](https://dx.doi.org/10.1007/s00236-015-0252-z)] points out, all possible relations between two intervals can be expressed by four primitive relations on their ends, which are implemented in <span class="sc">ghost</span>; where it was feasible though, some other operators were added for the convenience of the user.

The general syntax of temporal expressions is
> *from temporal-operator to*

where `from` and `to` can be:

* time points;
* instantiated values of components (for example, a state variable value with some constraints on its parameters; or, a resource requirement/production/consumption action); the predefined variable `this` can be used to refer to the one determined by the trigger of the synchronization being considered;
* a point and an instantiated value of a component;

and variables can be used instead of literal values.
In temporal expressions, `from` is optional: in this case, the `from` value is considered to be the `this` variable.

The starting and ending time points of an instantiated value can be accessed by the means of the `start` and `end` pseudo-operators: this way, it is possible to write much cleaner expressions than the ones written using Allen's relations.
The syntax of pseudo-operators is
> **start**(*instantiated-value*) \| **end**(*instantiated-value*)

The `temporal-operator` itself consists of a symbol or a keyword; in the latter case it is possible to specify a certain number of temporal intervals, depending on the operator itself (for symbolic operators, intervals are assumed to be the default ones: see section [Setting Default Values](#setting-default-values)). Operators are summarized in the tables below, where *A* and *B* refer to instantiated values of components, thus provided with a beginning and and end, while *s* and *t* refer to single time points.
Please remember that these operators are not Allen's operators: this is particularly crucial with operators like `starts` and `finishes` that share the same name but have different semantics.

{::comment}

**s** *operator* **t**

| symbol |     keyword     |     meaning     |
| ------ |:---------------:| --------------- |
|=       | equals          | s = t
|!=      |                 | s ≠ t
|<       | before([lb,ub]) | lb ≤ t - s ≤ ub
|>       | after([lb,ub])  | lb ≤ s - t ≤ ub

Operators between Time Points

{:/comment}

<table>
  <caption>Operators between Time Points</caption>
  <thead>
    <tr><th style="text-align: center" colspan="3"><strong>s</strong> <em>operator</em> <strong>t</strong></th></tr>
    <tr>
      <th>symbol</th>
      <th style="text-align: center">keyword</th>
      <th>meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>=</td>
      <td style="text-align: center">equals</td>
      <td>s = t</td>
    </tr>
    <tr>
      <td>!=</td>
      <td style="text-align: center"> </td>
      <td>s ≠ t</td>
    </tr>
    <tr>
      <td>&lt;</td>
      <td style="text-align: center">before([lb,ub])</td>
      <td>lb ≤ t - s ≤ ub</td>
    </tr>
    <tr>
      <td>&gt;</td>
      <td style="text-align: center">after([lb,ub])</td>
      <td>lb ≤ s - t ≤ ub</td>
    </tr>
  </tbody>
</table>

{::comment}

**A** *operator* **B**

|  symbol  |        keyword                |     meaning      |
| -------- |:-----------------------------:| ---------------- |
|  =       | equals                        | A = B
|  \|=     | meets                         | end(A) = start(B)
|  <       | before([lb,ub])               | end(A) < [lb,ub] start(B)
|  >       | after([lb,ub])                | start(A) > [lb,ub] end(B)
|          | starts                        | start(A) = start(B)
|          | finishes                      | end(A) = end(B)
|          | contains([lb1,ub1],[lb2,ub2]) | start(A) < [lb1,ub1] start(B) <br> end(B) < [lb2,ub2] end(A)
|          | during([lb1,ub1],[lb2,ub2])   | start(B) < [lb1,ub1] start(A) <br> end(A) < [lb2,ub2] end(B)

Operators between Instantiated Values
{:/comment}


<table>
  <caption>Operators between Instantiated Values</caption>
  <thead>
    <tr><th style="text-align: center" colspan="3"><strong>A</strong> <em>operator</em> <strong>B</strong></th></tr>
    <tr>
      <th>symbol</th>
      <th style="text-align: center">keyword</th>
      <th>meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>=</td>
      <td style="text-align: center">equals</td>
      <td>A = B</td>
    </tr>
    <tr>
      <td>|=</td>
      <td style="text-align: center">meets</td>
      <td>end(A) = start(B)</td>
    </tr>
    <tr>
      <td>&lt;</td>
      <td style="text-align: center">before([lb,ub])</td>
      <td>end(A) &lt; [lb,ub] start(B)</td>
    </tr>
    <tr>
      <td>&gt;</td>
      <td style="text-align: center">after([lb,ub])</td>
      <td>start(A) &gt; [lb,ub] end(B)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">starts</td>
      <td>start(A) = start(B)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">finishes</td>
      <td>end(A) = end(B)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">contains([lb1,ub1],[lb2,ub2])</td>
      <td>start(A) &lt; [lb1,ub1] start(B) <br /> end(B) &lt; [lb2,ub2] end(A)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">during([lb1,ub1],[lb2,ub2])</td>
      <td>start(B) &lt; [lb1,ub1] start(A) <br /> end(A) &lt; [lb2,ub2] end(B)</td>
    </tr>
  </tbody>
</table>

{::comment}
**A** *operator* **t**

|  symbol  |            name               |       meaning                   |
| -------- |:-----------------------------:| ------------------------------- |
|     <    | before([lb,ub])               | end(A) < [lb,ub] t
|     >    | after([lb,ub])                | start(A) > [lb,ub] t
|          | starts                        | start(A) = t
|          | finishes                      | end(A) = t
|          | contains([lb1,ub1],[lb2,ub2]) | start(A) < [lb1,ub1] t<br> t < [lb2,ub2] end(A)

**s** *operator* **B**

|  symbol  |            name               |       meaning                   |
| -------- |:-----------------------------:| ------------------------------- |
|     <    | before([lb,ub])               | s < [lb,ub] start(B)
|     >    | after([lb,ub])                | s > [lb,ub] end(B)
|          | starts                        | s = start(B)
|          | finishes                      | s = end(B)
|          | during([lb1,ub1],[lb2,ub2])   | start(B) < [lb1,ub1] s<br> s < [lb2,ub2] end(B)

Operators between an Instantiated Value and a Time Point

{:/comment}



<table>
  <caption>Operators between an Instantiated Value and a Time Point</caption>
  <thead>
    <tr><th style="text-align: center" colspan="3"><strong>A</strong> <em>operator</em> <strong>t</strong></th></tr>
    <tr>
      <th>symbol</th>
      <th style="text-align: center">name</th>
      <th>meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>&lt;</td>
      <td style="text-align: center">before([lb,ub])</td>
      <td>end(A) &lt; [lb,ub] t</td>
    </tr>
    <tr>
      <td>&gt;</td>
      <td style="text-align: center">after([lb,ub])</td>
      <td>start(A) &gt; [lb,ub] t</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">starts</td>
      <td>start(A) = t</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">finishes</td>
      <td>end(A) = t</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">contains([lb1,ub1],[lb2,ub2])</td>
      <td>start(A) &lt; [lb1,ub1] t<br /> t &lt; [lb2,ub2] end(A)</td>
    </tr>
  </tbody>
</table>

<table>
  <caption>Operators between a Time Point and an Instantiated Value</caption>
  <thead>
    <tr><th style="text-align: center" colspan="3"><strong>s</strong> <em>operator</em> <strong>B</strong></th></tr>
    <tr>
      <th>symbol</th>
      <th style="text-align: center">name</th>
      <th>meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>&lt;</td>
      <td style="text-align: center">before([lb,ub])</td>
      <td>s &lt; [lb,ub] start(B)</td>
    </tr>
    <tr>
      <td>&gt;</td>
      <td style="text-align: center">after([lb,ub])</td>
      <td>s &gt; [lb,ub] end(B)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">starts</td>
      <td>s = start(B)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">finishes</td>
      <td>s = end(B)</td>
    </tr>
    <tr>
      <td> </td>
      <td style="text-align: center">during([lb1,ub1],[lb2,ub2])</td>
      <td>start(B) &lt; [lb1,ub1] s<br /> s &lt; [lb2,ub2] end(B)</td>
    </tr>
  </tbody>
</table>

The four fundamental relations on instantiated values of components are
```ghost
start(A) before([lb,ub]) start(B);
end(A) before([lb,ub]) end(B);
start(A) before([lb,ub]) end(B);
end(A) before([lb,ub]) start(B);
```
For example, to define the equivalent of <span class="sc">ddl</span>'s `OVERLAPS`, one might write:
```ghost
start(A) < start(B);
end(A) < end(B);
start(B) before([lb,ub]) end(A);
```

## Other Features
This section illustrates some more advanced features of the <span class="sc">ghost</span> language: constants, annotations and compiler directives.

### Constants
Constants are static values associated with an identifier, which can be used as a placeholder instead of the value it represents. Constants in <span class="sc">ghost</span> are not typed, and are introduced by the `const` keyword, according to the syntax
> **const** *name* = *value*

The constant name needs to be a valid identifier, and its value can be

* an arithmetic or boolean expression
* an enumeration literal
* an interval


Constants can only be defined in the outermost scope (that is, not inside any block of statements).

### Annotations
Annotations are provided as a facility to "annotate" particular constructs with some planner-specific knowledge; this choice has been made as an interim-measure to ease the porting of existing <span class="sc">ddl</span> domains that make an intensive use of these constructs to overcome limitations in the <span class="sc">ddl</span> language, with the hope that they will soon be replaced by <span class="sc">ghost</span>-native constructs.

Annotations allow to insert arbitrary symbols and attach them to some elements, which are:

* type and component declarations (to affect their timeline's properties)
* transition constraints' heads
* synchronization triggers
* instantiated values of components


Annotations start with the "at" character ("`@`") and are made of a list of symbols, until the end of the line is reached; alternatively, it is possible to combine annotations and other code on the same line by putting identifiers between parentheses.

Some examples might help to clarify their usage:
```ghost
@trex_internal_dispatch_asap
comp PointingMode : PointingModeType;
```
The example above tags the `PointingMode` component with the specified identifier, that will be used to affect its timeline specification. It is translated in <span class="sc">ddl</span> as follows:
```ddl
COMPONENT PointingMode {FLEXIBLE tml(trex_internal_dispatch_asap)} : PointingModeType;
```

The code below instead is used on transition constraint's heads:
```ghost
type aType = sv(
  @(c) A -> B,
  B
);
```
which translates to
```ddl
COMP_TYPE SingletonStateVariable aType (A(), B()) {
  VALUE <c> A() [0, +INF]
  MEETS {
    B();
  }
}
```
Please note that the same result could have been achieved in <span class="sc">ghost</span> by using the `contr` keyword.

To conclude, here is an example that uses annotations on instantiated values:
```ghost
@(!) before PointingMode.Comm;
```
which is translated to:
```ddl
tmp1 <!> PointingMode.tml.Comm();
BEFORE [0, +INF] tmp1;
```


### Compiler Directives
Compiler directives are meta-instructions that are not directly used to define properties of the domain or problem being modeled, but are instead meant to alter the compiler's interpretation of the source code.
In <span class="sc">ghost</span>, compiler directives can be used to change the default values that the compiler uses when some elements are left unspecified, and to define time units (see section [Time Units](#time-units)).

Compiler directives are in effect from the position where they are declared onward, and are specific to the source file being processed; if a domain is imported in another file using the `import` statement, the "external" environment will not be affected by changes performed to the "local" environment; this means, for example, that a domain is free to redefine defaults and time units without the risk that problems importing that domain will have their defaults changed.

Compiler directives must be specified in separate lines, and are introduced by the dollar sign ("`$`").

#### Setting Default Values
Default values in <span class="sc">ghost</span> are specified with the directive `$set`; default values are shown in the table below.

`$set duration <interval>`
:    The value to use as a default duration, for example in transition constraints and temporal relations.

`$set planned | external`
:    whether components and types are considered planned or external by default.

`$set contr (contr | uncontr | unknown)`
:    determines how values in planned components are considered by default, with respect to controllability; "unknown" defers the choice to the planner.

`$set start <number>`
:    The value to use as default start time if not specified in the `init` section.

`$set horizon <number>`
:    The value to use as planning horizon if not specified in the `init` section.

{::comment}

|            directive              |          default       |
| --------------------------------- | ---------------------- |
|$set duration <interval>           | $set duration [0, +INF]
|$set planned\|external             | $set planned
|$set contr contr\|uncontr\|unknown | $set contr unknown
|$set start <number>                | $set start 0
|$set horizon <number>              | $set horizon 1000

Predefined default values

{:/comment}


<table>
  <caption>Predefined default values</caption>
  <thead>
    <tr>
      <th>directive</th>
      <th>default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>$set duration <interval></interval></td>
      <td>$set duration [0, +INF]</td>
    </tr>
    <tr>
      <td>$set planned|external</td>
      <td>$set planned</td>
    </tr>
    <tr>
      <td>$set contr contr|uncontr|unknown</td>
      <td>$set contr unknown</td>
    </tr>
    <tr>
      <td>$set start <number></number></td>
      <td>$set start 0</td>
    </tr>
    <tr>
      <td>$set horizon <number></number></td>
      <td>$set horizon 1000</td>
    </tr>
  </tbody>
</table>

#### Defining Time Units
As explained in section [Time Units](#time-units), when specifying numbers it is possible to use time units, which are treated as a multiplicative factor. Time units can be defined with the directive `$unit`, using this syntax:
> **\$unit** *name* [*value*]

where the value can be omitted to undefine the unit.

The default time units in <span class="sc">ghost</span> are defined as follows:
```ghost
$unit ms     1
$unit sec 1000 ms
$unit min   60 sec
$unit hrs   60 min
$unit days  24 hrs

$unit s 1 sec
$unit m 1 min
$unit h 1 hrs
$unit hours 1 hrs
$unit d 1 days
```

This structure helps redefining units efficiently: for example, if after some time it is evident that the millisecond scale is too fine, it is possible to change the underlying representation by writing these directives before any time unit is used (for example, at the top of the file):

```ghost
$unit sec 1
$unit ms
```

This way, all other time units are scaled accordingly; the unit `ms` is undefined to spot accidental usages of that unit in the code, which will now raise a compilation error.

## Examples
This section contains some complete code examples written in the <span class="sc">ghost</span> language.

### The Traffic Lights Domain
The domain discussed here is the one consisting of two traffic lights on a crossroad, so that when one is green the other one is red, and vice versa. A complete encoding in the <span class="sc">ddl</span> language can be found in the [KeeN User Guide](https://ugilio.github.io/keen/userguide).

In the <span class="sc">ghost</span> language, the domain and problem can be written as follows.

```ghost
domain TrafficLightDomain;

//Component types
type TrafficLightType = sv (
	Red 30 -> Green;
	Green 20 -> Yellow;
	Yellow 10 -> Red;
synchronize:
	Green -> meets other.Red;
variable:
	other : TrafficLightType;
);

// Components
comp TL1 : TrafficLightType[TL2];
comp TL2 : TrafficLightType[TL1];

//Facts, goals and temporal parameters
init (
  var horizon = 200;
  var resolution = 300;
  
  fact TL1.Green at 0;
  fact TL2.Red at 0;
	
  goal TL2.Yellow;
)
```

### The Satellite Domain
This domain has been introduced in [KeeN User Guide](https://ugilio.github.io/keen/userguide#a-quick-tour): a space probe orbiting around a planet can collect scientific data when pointing towards the planet, or send the data back when pointing towards Earth; data transmission can only happen during visibility windows and changing pointing mode (slewing) requires time; the satellite has a special maintenance mode from which it cannot automatically recover.
An encoding in <span class="sc">ghost</span> of the satellite domain is shown below.

```ghost
domain SATELLITE;
	
type EnergyConsumptionTraceType = resource(10);
	
comp PointingMode : sv (
  Earth [1, +INF] -> (Slewing, Comm, Maintenance);
  Slewing 30 -> (Earth, Science);
  Science [36, 58] -> Slewing;
  uncontr Comm [30, 50] -> (Earth, Maintenance);
  Maintenance;
synchronize:
  Science -> (
    require EnergyTrace(3);
    before PointingMode.Comm;
  );
  Comm -> (
    require EnergyTrace(6);
    during GroundStationVisibility.Visible;
  );
  Slewing -> require EnergyTrace(1);
);
	
external comp GroundStationVisibility : sv (
	Visible [60, 100] -> NotVisible;
	NotVisible [1, 100] -> Visible;
);

comp EnergyTrace : EnergyConsumptionTraceType;
```

### The GOAC Domain
This domain is a more complicated version of the satellite domain, and has been originally defined in <span class="sc">ddl</span> for the GOAC project [[CBC2011](http://homepages.laas.fr/felix/publis-pdf/astra-goac11.pdf)]. The code shown here has been translated to the <span class="sc">ghost</span> language from the original <span class="sc">ddl</span> definition, preserving a lot of planner-specific information by the means of annotations.

```ghost
domain GOAC_Domain2;

type coordinate = int [-1000, +1000];
type angle = int [-360, 360];
type file_id = int [0, 100];

@trex_external
comp RobotBase : sv (
  GoingTo(coordinate x, coordinate y) [10, 30] -> At(x, y);
  At(coordinate x, coordinate y) [1, +INF] -> GoingTo;
  StuckAt(coordinate x, coordinate y) [1, +INF] -> GoingTo;
synchronize:
  GoingTo -> during Platine.PointingAt(0,0);
);

@trex_external
comp Platine : sv (
  MovingTo(angle pan, angle tilt) [1, +INF] -> PointingAt(pan, tilt);
  PointingAt(angle pan, angle tilt) [10, 20] -> MovingTo;
);

@trex_external
comp Camera : sv (
  CamIdle [1, +INF] -> TakingPicture;
  TakingPicture(file_id, coordinate, coordinate, angle pan, angle tilt) 10 -> CamIdle;
synchronize:
  TakingPicture(_, x, y, pan, tilt) -> (
    during RobotBase.At(x, y);
    during Platine.PointingAt(pan, tilt);
  );
);

@trex_external
comp Communication : sv (
  CommIdle [1, +INF] -> Communicating;
  Communicating(file_id) [10, 20] -> CommIdle;
synchronize:
  Communicating -> (
    during RobotBase.At;
    @(?) during CommunicationVW.Visible;
  );
);

external comp CommunicationVW : sv(None -> Visible, Visible -> None);

@trex_internal, dispatch_asap
comp MissionTimeline : sv (
  Idle [1, +INF] -> (TakingPicture, Communicating, At);
  TakingPicture(file_id, coordinate, coordinate, angle, angle) 10 -> Idle;
  Communicating(file_id) [10, 20] -> Idle;
  At(coordinate, coordinate) [1, +INF] -> Idle;
synchronize:	
  TakingPicture(file_id, x, y, pan, tilt) -> (
    @(!) var cd1 = Camera.TakingPicture(file_id, x, y, pan, tilt);
    @(!) var cd5 = Communication.Communicating(file_id);
    @(!) meets MissionTimeline.Idle;
    contains cd1;
    contains(_,0) cd5;
    cd1 < cd5;
  );
  At(x, y) -> equals RobotBase.At(x, y);
);
```

----
[^1]: The reader might wonder what's the point in declaring a parameter if it is not used: the answer is that it might be used in a synchronization rule.
