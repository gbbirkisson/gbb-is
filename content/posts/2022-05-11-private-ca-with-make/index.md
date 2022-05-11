---
author: "Guðmundur Björn Birkisson"
title: "Private Certificate Authority with Make"
date: "2022-05-11"
description: "How to use make to create a private certificate authority with makefiles"
tags:
  - encryption
  - make
  - openssl
  - shell
  - template
---

There are times when you need to create your own certificate authority. This could be for your own private servers or maybe if you want to setup mTLS, and you need to issue client certificates. This note will be split into these sections:

- [Intro](#intro)
- [Setup](#setup)
	- [Makefile](#makefile)
	- [Makefile-ca.mk](#makefile-camk)
	- [Makefile-cert1.mk](#makefile-cert1mk)
- [Usage](#usage)
- [Adding certs](#adding-certs)


## Intro

I have found that using makefiles is a really nice approach to manage your CA. We of course use the [Makefile Help](../2022-05-04-makefile-help/) template to create our CA and then we end up with this nice interface:

```console
$ make
Makefile targets:
  help                    Show this help
  ca.key                  Create CA private key for 'My Certificate Authority'
  ca.crt                  Create CA certificate for 'My Certificate Authority'
  ca.crt-info             Print cert for 'My Certificate Authority'
  myserver.com.key        Create key for '*.myserver.com'
  myserver.com.csr        Create CSR for '*.myserver.com'
  myserver.com.cert       Sign CSR for '*.myserver.com'
  myserver.com.cert-info  Print cert for '*.myserver.com'
```

## Setup

How do accomplish this? Well we are going to create 3 Makefiles:

```
<DIR>
├── Makefile
├── Makefile-ca.mk
└── Makefile-cert1.mk
```

Those definitions are explained below!

### Makefile

Lets start with `Makefile`. This is the file that glues everything together:

> **NOTE:** The `help` target is slightly modified version of [Makefile Help](../2022-05-04-makefile-help/) to work with the `include` statements!

```makefile
.PHONY: help ${CA_CERT}-print ${CERT_1_CERT}-print
.DEFAULT_GOAL:=help

CA_DIR=ca
CERTS_DIR=certs

include Makefile-ca.mk
include Makefile-cert1.mk

help: ## Show this help
	$(eval HELP_COL_WIDTH:=30)
	@echo "Makefile targets:"
	@grep -E '[^\s]+:.*?## .*$$' ${MAKEFILE_LIST} | sed 's/Makefile://g' | sed 's/.*\.mk://g' | grep -v grep | envsubst | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-${HELP_COL_WIDTH}s\033[0m %s\n", $$1, $$2}'
```

### Makefile-ca.mk

Next we can setup `Makefile-ca.mk`. This file handles the definition of our certificate authority:

```makefile
# The password can (and probably should) be read from the environment
CA_PASS=mysecretpassword

# Files
export CA_CERT=${CA_DIR}/ca.crt
export CA_KEY=${CA_DIR}/ca.key

# Certificate properties
export CA_CN=My Certificate Authority
CA_SUBJ="/C=NO/ST=OSLO/L=OSLO/O=Gummi/OU=Gummi/CN=${CA_CN}"
CA_EXPIRES_IN=3560

${CA_KEY}: ## Create CA private key for '${CA_CN}'
	# Create CA key ...
	@test ${CA_PASS} || (echo "Set env variable CA_PASS"; exit 1;)
	@mkdir -p ${CA_DIR}
	openssl genrsa \
		-des3 \
		-passout pass:${CA_PASS} \
		-out ${CA_KEY} \
		4096

${CA_CERT}: ${CA_KEY} ## Create CA certificate for '${CA_CN}'
	# Create CA certificate ...
	@test ${CA_PASS} || (echo "Set env variable CA_PASS"; exit 1;)
	@mkdir -p ${CA_DIR}
	openssl req \
		-x509 -new -nodes \
		-key ${CA_KEY} \
		-sha256 -days ${CA_EXPIRES_IN} \
		-passin pass:${CA_PASS} \
		-out ${CA_CERT} \
		-subj ${CA_SUBJ}

${CA_CERT}-print: ${CA_CERT} ## Print cert for '${CA_CN}'
	@openssl x509 -in ${CA_CERT} -noout -text
```

### Makefile-cert1.mk

Finally lets create `Makefile-cert1.mk`, that issues a certificate for us:

```makefile
# Files
export CERT_1_KEY=${CERTS_DIR}/myserver.com.key
export CERT_1_CSR=${CERTS_DIR}/myserver.com.csr
export CERT_1_CERT=${CERTS_DIR}/myserver.com.cert

# Certificate properties
export CERT_1_CN=*.myserver.com
CERT_1_SUBJ="/C=NO/ST=OSLO/L=OSLO/O=Gummi/OU=Gummi/CN=${CERT_1_CN}"
CERT_1_CA_EXPIRES_IN=3650

${CERT_1_KEY}: ## Create key for '${CERT_1_CN}'
	# Create key ...
	@mkdir -p ${CERTS_DIR}
	openssl genrsa \
		-out ${CERT_1_KEY} \
		4096

${CERT_1_CSR}: ${CERT_1_KEY} ## Create CSR for '${CERT_1_CN}'
	# Create certificate request ...
	@mkdir -p ${CERTS_DIR}
	openssl req -new \
		-key ${CERT_1_KEY} \
		-out ${CERT_1_CSR} \
		-subj ${CERT_1_SUBJ}

${CERT_1_CERT}: ${CA_CERT} ${CERT_1_CSR} ## Sign CSR for '${CERT_1_CN}'
	# Create certificate ...
	@test ${CA_PASS} || (echo "Set env variable CA_PASS"; exit 1;)
	@mkdir -p ${CERTS_DIR}
	openssl x509 \
		-req -CAcreateserial \
		-in ${CERT_1_CSR} \
		-CA ${CA_CERT} \
		-CAkey ${CA_KEY} \
		-passin pass:${CA_PASS} \
		-out ${CERT_1_CERT} \
		-days ${CERT_1_CA_EXPIRES_IN} -sha256

${CERT_1_CERT}-print: ${CERT_1_CERT} ## Print cert for '${CERT_1_CN}'
	@openssl x509 -in ${CERT_1_CERT} -noout -text
```

## Usage

Now that we have set everything up, we can create everything in a single command:

```console
$ make certs/myserver.com.cert
# Create CA key ...
openssl genrsa \
        -des3 \
        -passout pass:mysecretpassword \
        -out ca/ca.key \
        4096
Generating RSA private key, 4096 bit long modulus (2 primes)
..................................................................++++
.................................................++++
e is 65537 (0x010001)
# Create CA certificate ...
openssl req \
        -x509 -new -nodes \
        -key ca/ca.key \
        -sha256 -days 3560 \
        -passin pass:mysecretpassword \
        -out ca/ca.crt \
        -subj "/C=NO/ST=OSLO/L=OSLO/O=Gummi/OU=Gummi/CN=My Certificate Authority"
# Create key ...
openssl genrsa \
        -out certs/myserver.com.key \
        4096
Generating RSA private key, 4096 bit long modulus (2 primes)
........................................................................++++
.........................++++
e is 65537 (0x010001)
# Create certificate request ...
openssl req -new \
        -key certs/myserver.com.key \
        -out certs/myserver.com.csr \
        -subj "/C=NO/ST=OSLO/L=OSLO/O=Gummi/OU=Gummi/CN=*.myserver.com"
# Create certificate ...
openssl x509 \
        -req -CAcreateserial \
        -in certs/myserver.com.csr \
        -CA ca/ca.crt \
        -CAkey ca/ca.key \
        -passin pass:mysecretpassword \
        -out certs/myserver.com.cert \
        -days 3650 -sha256
Signature ok
subject=C = NO, ST = OSLO, L = OSLO, O = Gummi, OU = Gummi, CN = *.myserver.com
Getting CA Private Key
```

... and this will make our directory look like this:

```console
$ tree
.
├── ca
│   ├── ca.crt
│   ├── ca.key
│   └── ca.srl
├── certs
│   ├── myserver.com.cert
│   ├── myserver.com.csr
│   └── myserver.com.key
├── Makefile
├── Makefile-ca.mk
└── Makefile-cert1.mk

2 directories, 9 files
```

## Adding certs

Now if you want to add more certs, just copy the `Makefile-cert1.mk` file and search replace `CERT_1` with something else, i.e:

```console
cat Makefile-cert1.mk | sed s/CERT_1/CERT_2/g > Makefile-cert2.mk
```

Then change the files and properties at the top of the new makefile:

```makefile
...
# Files
export CERT_2_KEY=${CERTS_DIR}/myserver2.com.key
export CERT_2_CSR=${CERTS_DIR}/myserver2.com.csr
export CERT_2_CERT=${CERTS_DIR}/myserver2.com.cert

# Certificate properties
export CERT_2_CN=*.myserver2.com
CERT_2_SUBJ="/C=NO/ST=OSLO/L=OSLO/O=Gummi/OU=Gummi/CN=${CERT_2_CN}"
CERT_2_CA_EXPIRES_IN=3650
...
```

And include the new makefile in `Makefile` like so:

```makefile
...
include Makefile-ca.mk
include Makefile-cert1.mk
include Makefile-cert2.mk
...
```

And voilà, your new targets show up:

```console
$ make
Makefile targets:
  help                           Show this help
  ca/ca.key                      Create CA private key for 'My Certificate Authority'
  ca/ca.crt                      Create CA certificate for 'My Certificate Authority'
  ca/ca.crt-print                Print cert for 'My Certificate Authority'
  certs/myserver.com.key         Create key for '*.myserver.com'
  certs/myserver.com.csr         Create CSR for '*.myserver.com'
  certs/myserver.com.cert        Sign CSR for '*.myserver.com'
  certs/myserver.com.cert-print  Print cert for '*.myserver.com'
  certs/myserver2.com.key        Create key for '*.myserver2.com'
  certs/myserver2.com.csr        Create CSR for '*.myserver2.com'
  certs/myserver2.com.cert       Sign CSR for '*.myserver2.com'
  certs/myserver2.com.cert-print Print cert for '*.myserver2.com'
```