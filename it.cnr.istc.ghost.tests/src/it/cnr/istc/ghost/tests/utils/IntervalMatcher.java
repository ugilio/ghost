package it.cnr.istc.ghost.tests.utils;

import org.hamcrest.Description;
import org.hamcrest.Factory;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeDiagnosingMatcher;

import it.cnr.istc.ghost.ghost.Interval;

public class IntervalMatcher extends TypeSafeDiagnosingMatcher<Interval> {

	protected Interval expected;
	
	protected IntervalMatcher(Interval expected) {
		this.expected = expected;
	}

    public void describeTo(Description description)
    {
    	description.appendText("equal to: " +toString(expected));
    }
	
	private boolean intvEquals(Interval left, Interval right) {
		if (left == right)
			return true;
		if (left == null || right == null)
			return false;
		return left.getLb() == right.getLb() &&
				left.getUb() == right.getUb() &&
				left.getLbub() == right.getLbub();
	}
	
	private String toString(Interval intv) {
		if (intv == null)
			return "null";
		long lb = intv.getLb();
		long ub = intv.getUb();
		long lbub = intv.getLbub();
		if (lb == ub && lb == 0L)
			return "["+lbub+"]";
		return "["+lb+","+ub+"]";
	}
	
	@Override
	protected boolean matchesSafely(Interval item, Description mismatchDescription) {
		if (intvEquals(item, expected))
			return true;
		
		mismatchDescription.appendText(String.format("they are different.%nGot: ")).
		appendText(toString(item)).
		appendText(String.format("%nExpected: ")).appendText(toString(expected));
		return false;
	}
	
    @Factory
    public static Matcher<Interval> equalTo(Interval target)
    {
        return new IntervalMatcher(target);
    }
}
