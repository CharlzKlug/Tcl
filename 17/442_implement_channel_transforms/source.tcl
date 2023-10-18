package require rc4
oo::class create RC4Transform {
    variable RC4Read
    variable RC4Write
    constructor {key} {
	set RC4Read [rc4::RC4Init $key]
	set RC4Write [rc4::RC4Init $key]
    }
    method initialize {transform_handle mode} {
	return {initialize read write finalize}
    }
method finalize {transform_handle} {
    rc4::RC4Final $RC4Read
    rc4::RC4Final $RC4Write
    [self] destroy
}
method read {transform_handle bytes} {
    return [rc4::RC4 $RC4Read $bytes]
}
method write {transform_handle bytes} {
    return [rc4::RC4 $RC4Write $bytes]
}
}
