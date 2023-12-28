proc check_word {word allowed} {
    if {$word ni $allowed} {
	error "Invalid word '$word'. Must be one of [join $allowed ,]"
    }
}

proc check_number {word} {
    if {![string is integer -strict $word]} {
	error "'word' is not an integer"
    }
}

proc word_to_var {word} {
    dict get {
	salary Salary
	federal FederalTax
	state StateTax
	insurance Insurance
    } $word
}

if {[info object isa object Paymaster]} {
    Paymaster destroy
}

oo::class create Paymaster {
    variable Script
}

oo::define Paymaster constructor {dslscript} {
    interp create dslengine -safe
    dslengine eval {namespace delete ::}
    foreach alias {deduct generate} {
	dslengine alias $alias [self] $alias
    }
    dslengine eval $dslscript
    interp create calculator -safe
    calculator alias puts puts
}

oo::define Paymaster destructor {
    catch {interp delete dslengine}
    catch {interp delete calculator}
}

oo::define Paymaster method deduct {what deduction args} {
    check_word $what {federal state insurance}
    set category [word_to_var $what]
    if {[regexp {^(\d+)(%)?$} $deduction -> amount percent] == 0} {
	error "Invalid deduction amount $deduction"
    }
    set template {
	if {%CONDITION%} {
	    if {%USE_PERCENT%} {
		set deduction [expr {int(($Salary * %AMOUNT%)/100)}]
	    } else {
		set deduction %AMOUNT%
	    }
	    incr %CATEGORY% $deduction
	    incr NetAmount -$deduction
	}
    }

    if {[llength $args] == 0} {
	set condition true
    } else {
	if {[llength $args] < 4} {
	    error "Incomplete line"
	}
	set args [lassign $args cond_keyword cond_var cond_cmp number]
	check_word $cond_keyword {when if}
	set cond_var [word_to_var $cond_var]
	check_number $number
	switch -exact -- $cond_cmp {
	    over - above {
		set condition "\[set $cond_var\] > $number"
	    }
	    under - below {
		set condition "\[set $cond_var\] < $number"
	    }
	    within - between {
		if {[llength $args] != 2 ||
		    [lindex $args 0] ne "and"} {
		    error "Invalid \"$cond_cmp\" arguments"
		}
		set upper [lindex $args 1]
		set condition "\[set $cond_var\] > $number && \[set $cond_var\] < $upper"
	    }
	}
    }

    append Script [string map [list \
				   %CATEGORY% $category \
				   %CONDITION% $condition \
				   %AMOUNT% $amount \
				   %USE_PERCENT% [expr {$percent ne ""}]] \
		       $template]
}

oo::define Paymaster method generate {what} {
    switch -exact -- $what {
	paycheck {
	    append Script {puts "Pay to $Name the amount of $NetAmount"} \n
	}
	paystub {
	    append Script {
		puts "Paystub: $Name Salary=$Salary Net=$NetAmount"
		puts "         Fed=$FederalTax State=$StateTax Insurance=$Insurance"
	    } \n
	}
	default { error "No means of generating \"$what\"" }
    }
}

oo::define Paymaster {
    method pay {emp} {
	set emp [dict merge {
	    FederalTax 0
	    StateTax 0
	    Insurance 0
	} $emp]
	dict set emp NetAmount [dict get $emp Salary]
	calculator eval [list set emp $emp]
	calculator eval [list dict with emp $Script]
    }
}

oo::define Paymaster method script { } {
return $Script
}

Paymaster create paymaster {
deduct insurance 100
deduct federal 10% when salary between 20000 and 30000
deduct federal 20% when salary above 30000
deduct state 5% when federal above 2500
generate paycheck
generate paystub
}
