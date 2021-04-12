#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function pwhelper_cli () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  local TASK="$1"; shift
  pwhelper_"${TASK:-autologin}" "$@" || return $?
}


function pwhelper_autologin () {
  [ -n "$SER" ] || local SER='/dev/ttyUSB0'
  [ -c "$SER" ] || return 3$(echo "E: Not a character device: '$SER'" \
    " – you can select the path with env var SER=/dev/…" >&2)
  local LOG_FN='serial.log'
  [ -n "$PSWD" ] || return 3$(echo "E: No password. Please set env var PSWD" \
    "to the first four digits of the factory-default device password." \
    "(If you guess wrong, you might still get a hint.)" >&2)

  echo '$\xEF\xBB\xBF# -*- tab-width: 8 -*-' >"$LOG_FN" || return $?
  usb-serialport-socat --prepare-only || return $?
  exec > >(
    # timecat --timefmt '+%+%,' |
    unbuffered tee --append "$LOG_FN"
    )

  exec 5<"$SER" || return $?
  exec 6>>"$SER" || return $?
  local BUF= LN= RV=
  local READ_TMO_RV=142

  echo "D: Checking for silence on the serial line…"
  IFS= read -n 1 -t 2.0 -u 5 BUF
  [ "$?" == "$READ_TMO_RV" ] || return 3$(
    echo "E: Unexpected noise on the serial line. Please power off your" \
      "Speedport and let it cool down for a bit." >&2)

  echo "D: Ready. Please switch on your Speedport's power supply very soon."

  local N_BYTES=0 TMO_ROW=0
  local EXPECT_NOW= EXPECT_NEXT=
  while true; do
    IFS= read -n 1 -t 1.0 -u 5 BUF
    RV=$?
    case "$RV" in
      0 ) ;;
      "$READ_TMO_RV" )
        [ "$N_BYTES" == 0 ] && continue
        (( TMO_ROW += 1 ))
        echo "> $LN < read timeout, seq=$TMO_ROW"
        # [ "$TMO_ROW" -le 15 ] || return 0
        continue;;  # Timeout
      * ) echo "E: read rv=$RV"; return 4;;
    esac

    TMO_ROW=0
    (( N_BYTES += 1 ))

    case "$BUF" in
      '' | $'\n' ) BUF=$'¶';;
      $'\r' ) BUF='«';;
      $'\t' ) BUF='»';;
      '"' | "'" | '$' | '#' | '*' | \
      '[' | ']' | '(' | ')' | '<' | '>' | \
      ',' | ';' | '~' | \
      ' ' ) ;;
      * )
        printf -v BUF '%q' "$BUF"
        case "$BUF" in
          * ) [ "${#BUF}" == 1 ] || BUF="‹$BUF›";;
        esac;;
    esac
    LN+="$BUF"

    case "$LN" in
      '¶' ) LN=; continue;;
      'Starting XModem download...'* | \
      __ignore_enter__ ) ;;
      *[Ee]nter* | \
      *'«' | \
      *'¶' ) echo "> $LN < $BUF <";;
    esac

    case "$EXPECT_NOW:$LN" in
      xmodem-ready:C ) return 0;;
    esac
    case "$LN" in
      'Yes, Enter command mode ...¶' )
        echo "D: Looks like success. Now connect your interactive terminal" \
          "and press Enter there. (And '!' for hidden extra options.)"
        BUF="$DANUBE_CMD"
        if [ -n "$BUF" ]; then
          slow_type 0.5s "$BUF"
        else
          echo "D: Exiting."
          return 0
        fi
        ;;
      'Press Space Bar 3 times to enter command mode' )
        echo 'sending 3 spaces:'
        echo -n '   ' >&6
        ;;
      'Please Enter Password:' )
        ( echo 'gonna send password:'
          slow_type 0.5s "$PSWD"
        ) & ;;
      'pBootParams->password '*' ¶' )
        pwhelper_decode_boot_hint "$LN"
        return $?;;
      'Starting XModem download...' )
        EXPECT_NOW='post-echo'
        EXPECT_NEXT='xmodem-ready';;
    esac

    case "$LN" in
      '¶' | '«' ) LN=;;
      *'¶' | *'«' )
        [ "$EXPECT_NOW" == post-echo ] && echo "> $LN <"
        LN=
        EXPECT_NOW="$EXPECT_NEXT"
        EXPECT_NEXT=
        ;;
    esac
  done
}


function slow_type () {
  local INTV="$1" BUF="$2"
  while [ -n "$BUF" ]; do
    sleep "$INTV" || return $?
    echo "$FUNCNAME: [${BUF:0:1}]"
    echo -n "${BUF:0:1}" >&6
    BUF="${BUF:1}"
  done
}


function pwhelper_decode_boot_hint () {
  local HINT="$1"
  HINT="${HINT// /$'\n'}"
  local NUMS=()
  readarray -t NUMS < <(<<<"$HINT" grep -xPie '^\(?[0-9a-f]{2}\)?')
  HINT=
  local NUM= CH=
  for NUM in "${NUMS[@]}"; do
    CH="${NUM//[()]/}"
    printf -v CH "'\\x$CH'"
    case "$NUM" in
      '(20)' ) CH='*';;
      '('* ) CH="($CH?)";;
    esac
    HINT+=", $CH"
  done
  HINT="${HINT#, }"
  echo "D: Decoded password hint: ${HINT:-(none found)}"
}











pwhelper_cli "$@"; exit $?
