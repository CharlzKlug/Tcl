if [info object isa object Account] {
    Account destroy
}

oo::class create Account

oo::define Account {
    variable Balance AccountNumber
    
    method UpdateBalance {change} {
	set Balance [::tcl::mathop::+ $Balance $change]
	return $Balance
    }
    method balance {} {return $Balance}
    method withdraw {amount} {
	return [my UpdateBalance -$amount]
    }
    method deposit {amount} {
	return [my UpdateBalance $amount]
    }
    constructor {account_no} {
	puts "Reading account data for $account_no from database"
	set AccountNumber $account_no
	set Balance 1000000
    }
    destructor {
	puts "[self] saving account data to database"
    }
}

oo::class create SavingsAccount {
    superclass Account
    variable MaxPerMonthWithdrawals WithdrawalsThisMonth
    constructor {account_no {max_withdrawals_per_month 3}} {
	next $account_no
	set MaxPerMonthWithdrawals $max_withdrawals_per_month
    }
    method monthly_update {} {
	my variable Balance
	my deposit [my MonthlyInterest]
	set WithdrawalsThisMonth 0
    }
    method withdraw {amount} {
	if {[incr WithdrawalsThisMonth] > $MaxPerMonthWithdrawals} {
	    error "You are only allowed $MaxPerMonthWithdrawals withdrawals a month"
	}
	next $amount
    }
    method MonthlyInterest {} {
	my variable Balance
	return [format %.2f [::tcl::mathop::* $Balance 0.005]]
    }
}

oo::class create CheckingAccount {
    superclass Account
    method cash_check {payee amount} {
	my withdraw $amount
	puts "Writing a check to $payee for $amount"
    }
}

proc freeze {account_obj} {
    oo::objdefine $account_obj {
	method UpdateBalance {args} {
	    error "Account is frozen. Don't mess with the IRS, dude!"
	}
	method unfreeze {} {
	    oo::objdefine [self] {deletemethod UpdateBalance unfreeze}
	}
    }
}

if [info object isa object EFT] {
    EFT destroy
}

oo::class create EFT {
    method transfer_in {from_account amount} {
	puts "Pretending $amount received from $from_account"
	my deposit $amount
    }
    method transfer_out {to_account amount} {
	my withdraw $amount
	puts "Pretending $amount sent to $to_account"
    }
}

if [info object isa object BrokerageAccount] {
    BrokerageAccount destroy
}

oo::class create BrokerageAccount {
    superclass Account
    method buy {ticker number_of_shares} {
	puts "Buying $number_of_shares shares of $ticker"
    }
    method sell {ticker number_of_shares} {
	puts "Selling $number_of_shares shares of $ticker"
    }
}

if [info object isa object ConsolidatedAccount] {
    ConsolidatedAccount destroy
}

oo::class create ConsolidatedAccount {
    constructor {acct_no} {
	CheckingAccount create checking_account $acct_no
	BrokerageAccount create brokerage_account $acct_no
    }
    forward buy brokerage_account buy
    forward sell brokerage_account sell
    forward cash_check checking_account cash_check
    forward withdraw checking_account withdraw
}

if [info object isa object Logger] {
    Logger destroy
}

oo::class create Logger {
    method Log args {
	my variable AccountNumber
	puts "Log([info level]): $AccountNumber [self target]: $args"
	return [next {*}$args]
    }
}

Account create smith_account SA-777888

oo::objdefine smith_account {
    mixin Logger
    filter Log
}

Account create savings SA-1112223
