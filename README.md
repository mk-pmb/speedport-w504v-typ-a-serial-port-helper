
<!--#echo json="package.json" key="name" underline="=" -->
speedport-w504v-typ-a-serial-port-helper
========================================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Tools for interacting with the serial console of a Speedport W504V Typ A.
<!--/#echo -->



* Official OpenWRT page for W504V: https://openwrt.org/toh/t-com/spw504v
* Tutorial that actually works:
  https://www.von-thuelen.de/doku.php/wiki/projekte/speedport_w504v/uebersicht
  * His u-boot cannot boot from memory. Neither from image 0/1.
    You really need to flash it to the bootloader area.
    If the boot loader refuses flashing into the boot area,
    you're not in the secret admin mode.


<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
