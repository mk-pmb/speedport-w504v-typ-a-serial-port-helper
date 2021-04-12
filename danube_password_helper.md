
danube_password_helper
======================

```text
$ ./danube_password_helper.sh
E: No password. Please set env var PSWD to the first four digits of
  the factory-default device password. (If you guess wrong, you might
  still get a hint.)

$ PSWD=0000 ./danube_password_helper.sh
D: Checking for silence on the serial line…
E: Unexpected noise on the serial line. Please power off your Speedport
  and let it cool down for a bit.

$ PSWD=0000 ./danube_password_helper.sh
D: Checking for silence on the serial line…
D: Ready. Please switch on your Speedport's power supply very soon.
[… lots of messages …]
> pBootParams->password 31 33 33 (20) ¶ < ¶ <
D: Decoded password hint: '1', '3', '3', *

$ PSWD=1337 ./danube_password_helper.sh
D: Checking for silence on the serial line…
D: Ready. Please switch on your Speedport's power supply very soon.
[… lots of messages …]
> Yes, Enter command mode ...¶ < ¶ <
D: Looks like success. Now connect your interactive terminal and press
  Enter there. (And '!' for hidden extra options.)
D: Exiting.
```







