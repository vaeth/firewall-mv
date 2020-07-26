#!/usr/bin/env cat
# This script is part of Martin V\"ath's firewall scripts.
# (C) Martin V\"ath <martin at mvath.de>
# SPDX-License-Identifier: BSD-3-Clause

FwmvPush() {
	command -v Push 2>/dev/null || if PushA_=`push.sh 2>/dev/null`
	then	eval "$PushA_"
	else	echo "push.sh from https://github.com/vaeth/push (v2.0 or newer) required" >&2
		exit 1
	fi
FwmvPush() {
	Push "$@"
}
	Push "$@"
}

FwmvReplace() {
	eval fwmv_T=\$$1
	fwmv_A=
	while {
		fwmv_B=${fwmv_T%%"$2"*}
		[ x"$fwmv_B" != x"$fwmv_T" ]
	}
	do	fwmv_A=$fwmv_A$fwmv_B$3
		fwmv_T=${fwmv_T#*"$2"}
	done
	eval $1=\$fwmv_A\$fwmv_T
	unset fwmv_A fwmv_B fwmv_T
}

FwmvQuote() {
	for fwmv_Q
	do	eval fwmv_R=\$$fwmv_Q
		FwmvReplace fwmv_R '\' '\\\\'
		FwmvReplace fwmv_R '"' '\"'
		case $fwmv_R in
		*' '*)
			fwmv_R='"'$fwmv_R'"';;
		esac
		eval $fwmv_Q=\$fwmv_R
	done
	unset fwmv_Q fwmv_R
}

fwmv_table4=
fwmv_table6=

FwmvTable() {
	fwmv_n=$1
	shift
	eval fwmv_s=\${fwmv_table$fwmv_n}
	fwmv_t=filter
	case $1 in
	-t)
		fwmv_t=$2
		shift 2;;
	-t*)
		fwmv_t=${1#?}
		shift;;
	esac
	fwmv_v=fwmv_table${fwmv_n}__$fwmv_t
	fwmv_c=
	case " $fwmv_s " in
	*' '$fwmv_v' '*)
		eval fwmv_c=\$$fwmv_v;;
	*)
		fwmv_s=$fwmv_s${fwmv_s:+\ }$fwmv_v
		eval fwmv_table$fwmv_n=\$fwmv_s
		fwmv_c='*'$fwmv_t;;
	esac
	fwmv_q=FwmvQuote
	case ${1:-} in
	-[FXZ])
		set -- a
		shift;;
	-[PN])
		fwmv_q=:
		set -- a ":$2" "${3:--}"
		shift;;
	-[PN]*)
		fwmv_q=:
		set -- a ":${1#?}" "${2:--}"
		shift;;
	esac
	fwmv_x=
	for fwmv_i
	do	fwmv_r=$fwmv_i
		$fwmv_q fwmv_r
		fwmv_x=$fwmv_x${fwmv_x:+\ }$fwmv_r
	done
	[ -z "$fwmv_x" ] || fwmv_c=$fwmv_c'
'$fwmv_x
	eval $fwmv_v=\$fwmv_c
	unset fwmv_c fwmv_i fwmv_n fwmv_q fwmv_r fwmv_s fwmv_t fwmv_v fwmv_x
}

FwmvSet() {
	fwmv_n=$1
	shift
	eval "fwmv_s=\${fwmv_table$fwmv_n}
fwmv_table$fwmv_n="
	fwmv_x=
	[ -z "$fwmv_s" ] && return
	for fwmv_i in $fwmv_s
	do	eval "fwmv_x=\$fwmv_x\$$fwmv_i
unset $fwmv_i"
		fwmv_x=$fwmv_x'
COMMIT
'
	done
	if [ -n "$fwmv_x" ]
	then	[ x"$fwmv_n" = x'4' ] && fwmv_n=
		case $* in
		*cho*|*rint*|*rnt*)
			FwmvPush -c fwmv_s printf '%s' "$fwmv_x"
			printf "%s\n" "$fwmv_s | ip${fwmv_n}tables-restore";;
		esac
		case ${*:-Exec} in
		*x*)
			printf '%s' "$fwmv_x" | ip${fwmv_n}tables-restore;;
		esac
	fi
	eval "unset fwmv_i fwmv_n fwmv_s fwmv_x
return $?"
}
