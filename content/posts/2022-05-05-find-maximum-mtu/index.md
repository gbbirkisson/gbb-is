---
author: "Guðmundur Björn Birkisson"
title: "Find Maximum MTU"
date: "2022-05-05"
description: "Find maximum MTU between servers"
tags:
  - bash
  - debug
  - networking
  - shell
  - wireguard
---

I had a strange problem the other day that https requests would hang randomly. It took me some time to figure out what the problem was. In the end it was related to MTU settings on my wireguard interface.

We were running a wireguard server, acting as a VPN, in our datacenter. That server had a network interface with MTU less than the standard `1500`. On top of that wireguard, adds additional headers to packets, reducing the maximum MTU that you can set for your local wireguard interface even more.

Instead of being smart and calculating the theoretical MTU for the wireguard interface, I found a neat way to "brute force" it. Here is the script I used:

> **NOTE:** You might need to lower the initial packet size if you are dealing with low MTU numbers.

```bash
#!/usr/bin/env bash

size=1272 # Must be divisible by 4
while ping -s $size -M do -c1 $1 >/dev/null 2>&1; do
    ((size += 4))
done

echo "Max MTU size: $((size - 4 + 28))"
```

The flags we are using here are:
* `ping`
  * `-s $size` : Set packet size, and we gradually increase that number.
  * `-m do` : Disallow outgoing packet fragmentation.
  * `-c1` : Only send 1 packet.

It's also worth mentioning that we subtract `4` from the final number, because that's the packet size that did not fail. We also add `28` because those bytes were used for the IP header and ICMP Echo Request header of the ping request.

So to figure out my required MTU size, I started by leaving my MTU too high. Then I ran the script on a server through the VPN (not the wireguard server itself), and the script printed out the maximum MTU I that could use. Then I set the MTU of my wireguard interface to that number. Worked like a charm:

```console
$ ./mtu.sh 1.2.3.4
Max MTU size: 1376
```