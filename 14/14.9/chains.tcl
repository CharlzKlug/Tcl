oo::class create ClassMixin {method m {} {}}
oo::class create ObjectMixin {method m {} {}}
oo::class create Base {
    mixin ClassMixin
    method m {} {}
    method classfilter {} {}
    filter classfilter
    method unknown args {}
}
oo::class create SecondBase {method m {} {}}
oo::class create Derived {
    superclass Base SecondBase
    method m {} {}
}
Derived create o
oo::objdefine o {
    mixin ObjectMixin
    method m {} {}
    method objectfilter {} {}
    filter objectfilter
}
