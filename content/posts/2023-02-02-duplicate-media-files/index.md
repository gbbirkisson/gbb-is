---
author: "Guðmundur Björn Birkisson"
title: "Find duplicate media files fast"
date: "2023-02-02"
description: "Figuring out how to find duplicate files really fast!"
tags:
  - bash
  - shell
  - benchmark
---

I have been sorting through thousands of photos these days. I found out that I had quite a bit of duplicates laying around. No need to waste storage space on that! This is a perfect challenge to solve using the standard tools available in any regular linux distro.

Oh, and also, by dumb luck I managed to find duplicate files that I would have never found without doing this exercise 🤷

- [TL;DR](#tldr)
- [First attempt](#first-attempt)
- [Second attempt](#second-attempt)
- [Third attempt](#third-attempt)
- [Fourth attempt](#fourth-attempt)
- [Fifth attempt (Update)](#fifth-attempt-update)

### TL;DR

Now I use these commands to find duplicate media files:

```bash
# This one takes 11 minutes on 250gb
$ find . ! -empty -type f -exec \
    sh -c "dd if='{}' bs=65536 count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" \; |\
    sort |\
    uniq -w32 -dD 

# This one take 2.5 minutes on 250gb
$ fdfind -tf -e cr2 -e jpg -e jpeg -e mov -e mp4 -e png -x \
    sh -c "dd if='{}' bs=65536 count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" |\
    sort |\
    uniq -w32 -dD
```

The latter command takes **2.5 minutes** to process **250gb** of data on a RaspberryPi 🚀

Also [hyperfine](https://github.com/sharkdp/hyperfine) and [fd](https://github.com/sharkdp/fd) are awesome 🔥

### First attempt

Starting out, we can do something like:

```bash
#!/usr/bin/env bash
# g_dup_1.sh

find . ! -empty -type f -exec \
    md5sum {} + |\
    sort |\
    uniq -w32 -dD
```

Easy! Find all files, calculate the `md5` hash for each one, sort and print out duplicates. Problem solved. Lets go do something else....or maybe not?

### Second attempt

Well, the first attempt is pretty good. Very simple, but it's so slow! Can we make it faster? Well we are reading every file from disk! The whole file! And we dont even care about the `md5` hash, we just care if the files are the same or not!

Can we maybe just read the first, lets say `1kb` of the file and calculate the hash of those bytes?

```bash
#!/usr/bin/env bash
# g_dup_2.sh

$ find . ! -empty -type f -exec \
    sh -c "dd if='{}' bs=1024 count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" \; |\
    sort |\
    uniq -w32 -dD
```

Here we use `dd` to read the first `1kb` of each file and pipe that into `md5sum`. Because `md5sum` is getting the bytes from `stdin`, we need to use `sed` to replace the `-` in the output with the actual filename to get identical output.

Now lets run some benchmarks using the awesome tool [hyperfine](https://github.com/sharkdp/hyperfine)! I will run it on a directory that I know has no duplicates:

```console
# How much data are we processing?
$ du -d 0 -h .
2.9G	.

# Run hyperfine
$ hyperfine --warmup 3 --runs 5 g_dup_1.sh g_dup_2.sh
Benchmark 1: g_dup_1.sh
  Time (mean ± σ):     14.242 s ±  0.030 s    [User: 12.840 s, System: 1.390 s]
  Range (min … max):   14.197 s … 14.273 s    5 runs

Benchmark 2: g_dup_2.sh
  Time (mean ± σ):      2.825 s ±  0.031 s    [User: 2.533 s, System: 2.619 s]
  Range (min … max):    2.792 s …  2.870 s    5 runs

Summary
  'g_dup_2.sh' ran
    5.04 ± 0.06 times faster than 'g_dup_1.sh'
```

Sweet! We made it **5 times faster**!

### Third attempt

So the second attempt is way faster than the first one. But it has a problem! It allows for false positives. It would be a bummer to delete files that are not actually duplicates!

To fix that we could just pipe the positives matches again into `md5sum`. Basically do a *second pass* on our duplicates:

```bash
#!/usr/bin/env bash

find . ! -empty -type f -exec \
    sh -c "dd if='{}' bs=1024 count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" \; |\
    sort |\
    uniq -w32 -dD |\
    cut -c 35- |\
    xargs -I {} md5sum "{}" |\
    uniq -w32 -dD
```

Nice, now we have this fast, reliable way of finding duplicates! But I think it could be faster! How many bytes should we read in while doing the *first pass* to make this as optimal as possible?

I guess that depends a lot on the type of files you are working with, and in this case we working with images and videos. Lets create a script that parameterizes the number of bytes we read:

```bash
#!/usr/bin/env bash
# g_dup_3.sh

find . ! -empty -type f -exec \
    sh -c "dd if='{}' bs=${1:-1024} count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" \; |\
    sort |\
    uniq -w32 -dD |\
    cut -c 35- |\
    xargs -I {} md5sum "{}" |\
    uniq -w32 -dD
```

And lets run a benchmark again:

```console
$ hyperfine --warmup 1 --runs 3 -L bytes 256,512,1024,2048,4096,8192 'g_dup_3.sh {bytes}'

...

Summary
  'g_dup_3.sh 1024' ran
    1.01 ± 0.01 times faster than 'g_dup_3.sh 4096'
    1.01 ± 0.02 times faster than 'g_dup_3.sh 8192'
    1.01 ± 0.02 times faster than 'g_dup_3.sh 2048'
    1.44 ± 0.02 times faster than 'g_dup_3.sh 256'
    1.45 ± 0.03 times faster than 'g_dup_3.sh 512'
```

What do these results tell us? Well it seem reading `256` or `512` bytes results in a lot of false positives. And in fact, I verified that this is the case. Not exactly suprising.

Also, reading more than `1024` bytes does not help in this case because there are no duplicates in this directory. But it does not seem to slow us down alot to read many bytes. What is the penalty for reading a lot of bytes?

```console
$ hyperfine --warmup 1 --runs 3 -L bytes 1024,8192,65536,131072,262144,524288 'g_dup_3.sh {bytes}'

...

Summary
  'g_dup_3.sh 65536' ran
    1.01 ± 0.01 times faster than 'g_dup_3.sh 1024'
    1.02 ± 0.01 times faster than 'g_dup_3.sh 8192'
    1.03 ± 0.01 times faster than 'g_dup_3.sh 131072'
    1.18 ± 0.02 times faster than 'g_dup_3.sh 262144'
    1.48 ± 0.02 times faster than 'g_dup_3.sh 524288'
```

Seems we found our sweet spot. Reading `2^16` or `65536` bytes does not result in any penalty. Lets make that our default!

### Fourth attempt

So we know that we should read `65536` bytes of each file to calculate hashes. But I wonder ... will we get any false positives with that number? Can we skip the *second pass*? Let's find out! First we create these two scripts:

```bash
#!/usr/bin/env bash
# g_dup_4.sh

find . ! -empty -type f -exec \
    sh -c "dd if='{}' bs=${1:-65536} count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" \; |\
    sort |\
    uniq -w32 -dD |\
    tee /tmp/dup_first_pass
```

```bash
#!/usr/bin/env bash
# g_dup_5.sh

cat /tmp/dup_first_pass |\
    cut -c 35- |\
    xargs -I {} md5sum "{}" |\
    uniq -w32 -dD > /tmp/dup_second_pass
```

Then lets run this test on a lot of files:

```console
# Working with a lot more data now!
$ du -h -d 0 .
249G	.

$ hyperfine --runs 1 'g_dup_4.sh'
Benchmark 1: g_dup_4.sh
  Time (abs ≡):        665.651 s               [User: 213.393 s, System: 269.509 s]

# ^ It took roughly 11 minutes to process those 250 gigabytes of data

$ hyperfine --runs 1 'g_dup_5.sh'
Benchmark 1: g_dup_5.sh
  Time (abs ≡):        215.159 s               [User: 77.082 s, System: 33.103 s]

# ^ 215 seconds is roughly 3 minutes 40 seconds

# Compare counts
$ wc -l /tmp/dup_first_pass /tmp/dup_second_pass
  3211 /tmp/dup_first_pass
  3145 /tmp/dup_second_pass
  6356 total
```

Well this was sad! I was hoping to see no false positives. But wait ... looking at those false positives I see a pattern:

```console
$ diff <(cat /tmp/dup_first_pass | cut -c 35-) <(cat /tmp/dup_second_pass | cut -c 35-)
7,8d6
< ./gummi_myndir/2015/XX Gummi Sími/2015-10-25 19.02.38-1.jpg
< ./gummi_myndir/2015/XX Gummi Sími/2015-10-25 19.02.38.jpg
59,60d56
< ./gummi_myndir/2015/XX Gummi Sími/2015-08-29 13.06.35-1.jpg
< ./gummi_myndir/2015/XX Gummi Sími/2015-08-29 13.06.35.jpg
287,288d278
< ./gummi_myndir/2015/06 Sumarið 2015/2015-07-03 18.08.46.jpg
< ./gummi_myndir/2015/XX Gummi Sími/2015-07-03 18.08.46.jpg
...
```

**THESE ARE DUPLICATES** 🤨 Don't know how that happened, but they have the same `exif` data and look exactly the same. But still have different `md5` hash. I just managed to create a way to find these strange duplicates. This was pure dumb luck 🙃 Nice!

I manually went over all those false-false positives, cleaned up and ran the scripts again.

```console
$ hyperfine --runs 1 'g_dup_4.sh'
Benchmark 1: g_dup_4.sh
  Time (abs ≡):        615.955 s               [User: 213.727 s, System: 269.289 s]

$ hyperfine --runs 1 'g_dup_5.sh'
Benchmark 1: g_dup_5.sh
  Time (abs ≡):        208.712 s               [User: 69.335 s, System: 32.776 s]

# ^ Looking at these numbers, we see by skipping the
#   second pass, time taken is reduced by about 25%

$ diff <(cat /tmp/dup_first_pass | cut -c 35-) <(cat /tmp/dup_second_pass | cut -c 35-)
# ^ No output

$ wc -l /tmp/dup_first_pass /tmp/dup_second_pass
  3143 /tmp/dup_first_pass
  3143 /tmp/dup_second_pass
  6286 total
```

Ahhh, nice! Everything is good in the world again. Except, I have some cleanup to do on my server!

### Fifth attempt (Update)

I shared this with my collegues and there was a suggestion to use [fd](https://github.com/sharkdp/fd) instead of `find`. So lets give it a go!

```bash
#!/usr/bin/env bash
# g_dup_6.sh

fdfind -HI -tf -x \
    sh -c "dd if='{}' bs=${1:-65536} count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" |\
    sort |\
    uniq -w32 -dD
```

We are including the `-HI` flags to look in hidden folders like `find` does by default. But we are also using the `-x` flag to run the hashing in parallel!

```console
# Working with the same data as before!
$ du -h -d 0 .
249G	.

$ hyperfine --runs 1 'g_dup_2.sh 65536' 'g_dup_6.sh 65536'
Benchmark 1: g_dup_2.sh 65536
  Time (abs ≡):        673.321 s               [User: 215.444 s, System: 267.730 s]

Benchmark 2: g_dup_6.sh 65536
  Time (abs ≡):        182.496 s               [User: 216.008 s, System: 246.254 s]

Summary
  'g_dup_6.sh 65536' ran
    3.69 times faster than 'g_dup_2.sh 65536'
```

What! That only took **3 minutes** 😮 Lets pull out all the stops and see the absolute minimum amount of time we can get down to:

```bash
#!/usr/bin/env bash
# g_dup_7.sh

fdfind -tf -e cr2 -e jpg -e jpeg -e mov -e mp4 -e png -x \
    sh -c "dd if='{}' bs=${1:-65536} count=1 2>/dev/null | md5sum | sed s%-%'{}'%g" |\
    sort |\
    uniq -w32 -dD
```

```console
$ hyperfine --runs 1 'g_dup_7.sh 65536'
Benchmark 1: g_dup_7.sh 65536
  Time (abs ≡):        150.410 s               [User: 178.517 s, System: 197.493 s]
```

That is amazing! Only **2.5 minutes** processing time 🤯
