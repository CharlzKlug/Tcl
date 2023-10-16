package require rc4

oo::class create RC4Transform {
    variable RC4Read
    variable RC4Write
    constructor {key} {
	set RC4Read [rc4::RC4Init $key]
	set RC4Write [rc4::RC4Init $key]
    }
}

oo::define RC4Transform {
    method initialize {transform_handle mode} {
	return {initialize read write finalize}
    }
}
