package it.cnr.istc.ghost.utils

import java.math.BigInteger

class ArithUtils {
	
	private static BigInteger MIN = BigInteger.valueOf(Long.MIN_VALUE);
	private static BigInteger MAX = BigInteger.valueOf(Long.MAX_VALUE);
	
	private static def long cap(BigInteger b) {
		if (b.compareTo(MIN) < 0) return Long.MIN_VALUE
		else if (b.compareTo(MAX) > 0) return Long.MAX_VALUE
		else return b.longValue;
	}
	
	def static long add(long l, long r) {
		cap(BigInteger.valueOf(l).add(BigInteger.valueOf(r)));
	}
	
	def static long sub(long l, long r) {
		cap(BigInteger.valueOf(l).subtract(BigInteger.valueOf(r)));
	}
	
	def static long mul(long l, long r) {
		cap(BigInteger.valueOf(l).multiply(BigInteger.valueOf(r)));
	}
	
	def static long div(long l, long r) {
		cap(BigInteger.valueOf(l).divide(BigInteger.valueOf(r)));
	}
	
	def static long mod(long l, long r) {
		cap(BigInteger.valueOf(l).mod(BigInteger.valueOf(r)));
	}
}