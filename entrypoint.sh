#! /bin/sh
# $Id: iptables_init_and_clean.sh,v 1.7 2017/04/21 11:16:09 nanard Exp $
# Improved Miniupnpd iptables init script.
# Checks for state of filter before doing anything..

EXT=0
IPTABLES=/sbin/iptables
#. $(dirname "$0")/miniupnpd_functions.sh
# -I inserts the rule at the head of the chain,
# -A appends the rule at the end of the chain
ADDCMD=-I
CHAIN=MINIUPNPD
CLEAN=yes
EXTIF=eth0

FDIRTY=$(LC_ALL=C $IPTABLES -t filter -L -n | awk "/$CHAIN / {printf \$1}")
NDIRTY=$(LC_ALL=C $IPTABLES -t nat -L -n | awk "/$CHAIN / {printf \$1}")
MDIRTY=$(LC_ALL=C $IPTABLES -t mangle -L -n | awk "/$CHAIN / {printf \$1}")
NPDIRTY=$(LC_ALL=C $IPTABLES -t nat -L -n | awk "/$CHAIN-POSTROUTING / {printf \$1}")

# MINIUPNPD chain for nat
if [ "$NDIRTY" = "${CHAIN}Chain" ]; then
	echo "Nat table dirty; Cleaning..."
elif [ "$NDIRTY" = "Chain" ]; then
	echo "Dirty NAT chain but no reference..? Fixing..."
	#$IPTABLES -t nat $ADDCMD PREROUTING -d $EXTIP -i $EXTIF -j $CHAIN
	$IPTABLES -t nat $ADDCMD PREROUTING -i $EXTIF -j $CHAIN
else
	echo "NAT table clean..initalizing.."
	$IPTABLES -t nat -N $CHAIN
	#$IPTABLES -t nat $ADDCMD PREROUTING -d $EXTIP -i $EXTIF -j $CHAIN
	$IPTABLES -t nat $ADDCMD PREROUTING -i $EXTIF -j $CHAIN
fi
if [ "$CLEAN" = "yes" ]; then
	$IPTABLES -t nat -F $CHAIN
fi

# MINIUPNPD chain for mangle
if [ "$MDIRTY" = "${CHAIN}Chain" ]; then
	echo "Mangle table dirty; Cleaning..."
elif [ "$MDIRTY" = "Chain" ]; then
	echo "Dirty Mangle chain but no reference..? Fixing..."
	$IPTABLES -t mangle $ADDCMD PREROUTING -i $EXTIF -j $CHAIN
else
	echo "Mangle table clean..initializing..."
	$IPTABLES -t mangle -N $CHAIN
	$IPTABLES -t mangle $ADDCMD PREROUTING -i $EXTIF -j $CHAIN
fi
if [ "$CLEAN" = "yes" ]; then
	$IPTABLES -t mangle -F $CHAIN
fi

# MINIUPNPD chain for filter
if [ "$FDIRTY" = "${CHAIN}Chain" ]; then
	echo "Filter table dirty; Cleaning..."
elif [ "$FDIRTY" = "Chain" ]; then
	echo "Dirty filter chain but no reference..? Fixing..."
	$IPTABLES -t filter $ADDCMD FORWARD -i $EXTIF ! -o $EXTIF -j $CHAIN
else
	echo "Filter table clean..initalizing.."
	$IPTABLES -t filter -N $CHAIN
	$IPTABLES -t filter $ADDCMD FORWARD -i $EXTIF ! -o $EXTIF -j $CHAIN
fi
if [ "$CLEAN" = "yes" ]; then
	$IPTABLES -t filter -F $CHAIN
fi

# MINIUPNPD-POSTROUTING chain (for nat)
if [ "$NPDIRTY" = "${CHAIN}-POSTROUTINGChain" ]; then
	echo "Postrouting Nat table dirty; Cleaning..."
elif [ "$NPDIRTY" = "Chain" ]; then
	echo "Dirty POSTROUTING NAT chain but no reference..? Fixing..."
	$IPTABLES -t nat $ADDCMD POSTROUTING -o $EXTIF -j $CHAIN-POSTROUTING
else
	echo "POSTROUTING NAT table clean..initalizing.."
	$IPTABLES -t nat -N $CHAIN-POSTROUTING
	$IPTABLES -t nat $ADDCMD POSTROUTING -o $EXTIF -j $CHAIN-POSTROUTING
fi
if [ "$CLEAN" = "yes" ]; then
	$IPTABLES -t nat -F $CHAIN-POSTROUTING
fi

miniupnpd "$@"