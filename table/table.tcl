proc print_temperature {input_temperature} {
    puts "Temperature is: $input_temperature"
}

proc print_time {input_time} {
    puts "Time is $input_time"
}

proc print_coord {input_coord} {
    puts "Coordinates is $input_coord"
}

proc print_number {input_number} {
    puts "Buoy number is $input_number"
}

set message_types [dict create temperature print_temperature \
		       time print_time \
		       coordinates print_coord \
		       number print_number]

set buoy_types [dict create 0 {number temperature} \
		1 {number time coordinates}]

proc proceed_buoy_data {input_buoy_data buoy_types message_types} {
    set buoy_type [lindex $input_buoy_data 0]
    set datas [lrange $input_buoy_data 1 end]
    set buoy_data_types [dict get $buoy_types $buoy_type]
    foreach data $datas data_type $buoy_data_types {
	[dict get $message_types $data_type] $data
    }
}

proc proceed_buoys_datas {input_buoys_datas input_buoy_types input_message_types} {
    foreach buoy_data $input_buoys_datas {
	proceed_buoy_data $buoy_data $input_buoy_types $input_message_types
    }
}
