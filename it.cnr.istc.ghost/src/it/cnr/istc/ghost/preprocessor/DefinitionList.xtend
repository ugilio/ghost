package it.cnr.istc.ghost.preprocessor

import java.util.ArrayList
import java.util.List
import org.eclipse.xtext.util.Strings
import org.eclipse.xtext.util.Triple
import org.eclipse.xtext.util.Tuples

class DefinitionList<T> {
	
	private List<Triple<Integer, String, T>> data;

	new() {
		data = new ArrayList(256);
	}
	
	protected def add(String aKey, T value, int offset) {
		val key = aKey?.trim;
		if (Strings.isEmpty(key))
			throw new DefinitionListException("Key cannot be empty");
		if (offset < 0)
			throw new DefinitionListException("Negative offset: " + offset);
		val element = Tuples.create(offset, key, value);
		// Typical case when parsing top to bottom: always add at the end 
		if (data.size == 0 || data.last.first <= offset) {
			data.add(element);
			return;
		}
		var pos = indexOf(offset, key);
		if (pos >= 0) {
			data.set(pos, element);
			return;
		}
		pos = -pos - 1;
		data.add(pos, element);
	}

	protected def T internalGetValue(String key, int offset) {
		if (data.size > 0) {
			var pos = indexOf(offset, key);
			if (pos < 0)
				pos = -pos - 1 - 1;
			while (pos >= 0) {
				if (key.equals(data.get(pos).second)) {
					val value = data.get(pos).third;
					if (value === null)
						// explicitly undefined 
						throw new KeyNotFoundException(String.format("Undefined key: '%s'", key),key);
					return value;
				}
				pos--;
			}
		}
		throw new KeyNotFoundException(String.format("Undefined key: '%s'", key),key);
	}

	protected def int indexOf(int offset, String key) {
		var l = 0;
		var r = data.size;
		while (l < r) {
			var m = (l + r) / 2;
			val mOfs = data.get(m).first;
			if (mOfs < offset)
				l = m + 1
			else if (mOfs > offset)
				r = m
			else {
				while (m > 0 && data.get(m - 1).first == offset)
					m--;
				while (m < data.size && data.get(m).first == offset) {
					if (key.equals(data.get(m).second))
						return m;
					m++;
				}
				// else insert here
				return -m - 1;
			}
		}
		// insert here
		return -l - 1;
	}
	
	static class KeyNotFoundException extends Exception {
		public String key; 
		new(String message,String key,Throwable cause) {
			super(message,cause);
			this.key = key;
		}
		new(String message,String key) {
			super(message);
			this.key = key;
		}
	}
	static class DefinitionListException extends Exception {
		new(String message,Throwable cause) {
			super(message);
		}
		new(String message) {
			super(message);
		}
	}
}
