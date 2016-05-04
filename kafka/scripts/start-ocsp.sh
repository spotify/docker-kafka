#!/usr/bin/expect

if {[info exists ::env(SSL_OCSP)] && [info exists ::env(SSL_OCSP_DIR)]} {
	spawn openssl ocsp -port 8000 -index $::env(SSL_OCSP_DIR)/index.txt -CA $::env(SSL_OCSP_DIR)/ca-cert \
	-rsigner $::env(SSL_OCSP_DIR)/ca-cert -rkey $::env(SSL_OCSP_DIR)/ca-key -text

	expect "Enter pass phrase for"
	send "changeit\r"
	interact
} else {
	puts "Error. Not found SSL_OCSP_DIR var"
	exit 1
}
