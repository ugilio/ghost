---
title: GHOST Language Grammar
hide_sidebar: true
toc: false
permalink: ghostebnf
---
This is the definition of the <span class="sc">ghost</span> language in EBNF form.

```ebnf
(* WS, ML_COMMENT, SL_COMMENT, SL_ANNOTATION,
BR_ANNOTATION, and DIRECTIVE may occur anywhere *)

Ghost =
    [(DomainDecl | ProblemDecl) SEP]
    {ImportDecl SEP}
    [TopLevelDeclaration {SEP TopLevelDeclaration} {SEP}];

DomainDecl = 'domain' ID;
ProblemDecl = 'problem' ID;
ImportDecl = 'import' ID;

TopLevelDeclaration = TypeDecl | CompDecl | ConstDecl | InitSection;
TypeDecl = SimpleType | ComponentType;

SimpleType = IntDecl | EnumDecl;
ComponentType = SvDecl | ResourceDecl;
IntDecl =  [Externality] 'type'ID '=' 'int' Interval;
EnumDecl = [Externality] 'type'ID '='
    'enum' '(' [EnumLiteral {SEP EnumLiteral}] ')';
SvDecl =  [Externality] 'type'ID '=' 'sv' [ID] SvBody;
ResourceDecl =  [Externality] 'type'ID '=' 'resource' [ID] ResourceBody;

SvBody = ['('
    UnnamedTransitionSection
    {TransitionSection |
    SynchronizeSection |
    VariableSection}
')'];

TransitionSection = 'transition:' [TransConstraint {SEP TransConstraint} {SEP}];
SynchronizeSection = 'synchronize:'
    [Synchronization {SEP Synchronization} {SEP}];
VariableSection = 'variable:' [ObjVarDecl {SEP ObjVarDecl} {SEP}];
UnnamedTransitionSection = [TransConstraint {SEP TransConstraint} {SEP}];

TransConstraint = [Controllability] ValueDecl
    [IntvOrDflt] ['->' TransConstrBody];

ValueDecl = ID [FormalParList];
SimpleInstVal = ID [ArgList];
QualifInstVal = QUALID [ArgList];
InstVal = 'this' | QualifInstVal | ResConstr;

TransConstrBody = (SingleTransConstr) | ('('
    [SingleTransConstr {SEP SingleTransConstr} {SEP}] ')');
SingleTransConstr = 'inherited' | LocVarDecl | GenericExpression;

Synchronization = TriggerType '->' SyncBody {'or' SyncBody};
SyncBody = (SingleSyncConstr) | ('('
    [SingleSyncConstr {SEP SingleSyncConstr} {SEP}] ')');
SingleSyncConstr =  (TemporalExp) | LocVarDecl | GenericExpression;

TriggerType = ResSimpleInstVal | SimpleInstVal;

ResConstr = ResourceAction QualifInstVal;

ObjVarDecl = ID ':' ID;

ResourceBody = ['('[ConstExpr [SEP ConstExpr] {SEP}]
    {SynchronizeSection | VariableSection}
')'];

ResSimpleInstVal = ResourceAction '(' ID_ ')';

FormalParList = '(' [ID [ID_] {SEP ID [ID_] } {SEP} ] ')';
ArgList = '(' [GenericExpression {SEP GenericExpression} {SEP} ] ')';
BindList = '['[ID '='] ID {SEP [ID '='] ID } {SEP} ']';

LocVarDecl = 'var' ID '=' RValue;
RValue = (TemporalExp) | GenericExpression;

BasicExp = '(' EqExp ')' | '_' | TimePointOp | InstVal | NumAndUnit;
Term = BasicExp  {('*' | '/' | '%') BasicExp};
SumExp = Term  {( '+' | '-' ) Term};
CompExp = SumExp  [('<' | '<=' | '>' | '>=' ) SumExp];
EqExp = CompExp  [('=' | '!=') CompExp];

TemporalExp = [SumExp] TemporalRelation SumExp;

TemporalRelation =
    '=' | '!=' | 'equals' | '|=' | 'meets' | '<' | '>' | 'starts' | 'finishes' |
    (('before' | 'after') ['(' [IntvOrDflt] ')'] ) |
    ( ('contains'|'during') ['(' [IntvOrDflt [SEP IntvOrDflt]] ')'] );

GenericExpression = EqExp;

CBasicExp = '(' CSumExp ')' | '_' | ID | ((NumAndUnit) | (Interval));
CTerm = CBasicExp  {('*' | '/' | '%') CBasicExp};
CSumExp = CTerm  {('+' | '-' ) CTerm};

ConstExpr = CSumExp;

Externality = 'planned' | 'external';
Controllability = 'contr' | 'uncontr';
ResourceAction = 'require' | 'produce' | 'consume';

CompDecl = NamedCompDecl | AnonSVDecl | AnonResDecl;
NamedCompDecl = [Externality] 'comp' ID ':' ID CompBody;
AnonSVDecl = [Externality] 'comp' ID ':' 'sv' CompSVBody;
AnonResDecl = [Externality] 'comp' ID ':' 'resource' CompResBody;

CompBody = ( CompResBody) | CompSVBody;

CompSVBody = [BindList]['('
    UnnamedTransitionSection
    {TransitionSection | SynchronizeSection }
')'];

CompResBody = [BindList]['(' [ConstExpr [SEP ConstExpr] {SEP}]
    {SynchronizeSection}
')'];


InitSection = 'init' (InitConstr | ('('
    [InitConstr {SEP InitConstr} {SEP}] ')'));
InitConstr = LocVarDecl | FactGoal;
FactGoal = ('fact'|'goal') InstVal ['at' AtParams];

ConstDecl = 'const' ID '=' ConstExpr;

AtParams = AtParamsNamed | ( AtParamsPos);
AtParamsNamed = 3 * [ ('start' | 'duration' | 'end') '=' IntvOrDflt];
AtParamsPos = [IntvOrDflt [IntvOrDflt [IntvOrDflt]]];

TimePointOp = ( ('start'|'end') '(' GenericExpression ')');

EnumLiteral = ID;
IntvOrDflt = ('_' | Interval);
Interval = ( '[' NumAndUnit SEP NumAndUnit']') | NumAndUnit;

NumAndUnit = (Number [ID]);
Number = PosNumber | NegNumber;
PosNumber = ['+'] (INT |'INF');
NegNumber = '-' (INT |'INF');

QUALID = ID{'.'ID};
ID_ = '_' | ID;

(* Terminals *)

SL_ANNOTATION = '@' { ANYCHAR - ('\n'|'\r') } [['\r'] '\n'];
BR_ANNOTATION = ? '@(' -> ')'; ?
DIRECTIVE = '$' { ANYCHAR - ('\n'|'\r') } [['\r'] '\n'];

SEP = (',' | ';');
ID = ('a'..'z'|'A'..'Z') {'a'..'z'|'A'..'Z'|'0'..'9'|'_'};
INT = ('0'..'9') {'0'..'9'|'_'};
ML_COMMENT = ? '/*' -> '*/'; ?
SL_COMMENT = '//' { ANYCHAR - ('\n'|'\r') } [['\r'] '\n'];

WS = (' '|'\t'|'\r'|'\n') {' '|'\t'|'\r'|'\n'};

ANYCHAR = ? any ASCII character ?
```
