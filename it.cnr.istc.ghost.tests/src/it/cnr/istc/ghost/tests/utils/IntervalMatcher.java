package it.cnr.istc.ghost.tests.utils;

import org.hamcrest.Description;
import org.hamcrest.Factory;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeDiagnosingMatcher;

import it.cnr.istc.ghost.ghost.Interval;
import it.cnr.istc.ghost.ghost.NumAndUnit;

public class IntervalMatcher extends TypeSafeDiagnosingMatcher<Interval> {

	protected Interval expected;
	
	protected IntervalMatcher(Interval expected) {
		this.expected = expected;
	}

    public void describeTo(Description description)
    {
    	description.appendText("equal to: " +toString(expected));
    }
	
    private boolean numEquals(NumAndUnit left, NumAndUnit right) {
		if (left == right)
			return true;
		if (left == null || right == null)
			return false;
		if (left.getValue() == right.getValue())
			return true;
		if (left.getValue() == null || right.getValue() == null)
			return false;
		return left.getValue().longValue() == right.getValue().longValue();
    }
    
	private boolean intvEquals(Interval left, Interval right) {
		if (left == right)
			return true;
		if (left == null || right == null)
			return false;
		return numEquals(left.getLb(),right.getLb()) &&
				numEquals(left.getUb(),right.getUb()) &&
				numEquals(left.getLbub(),right.getLbub());
	}
	
	private String toString(Interval intv) {
		if (intv == null)
			return "null";
		NumAndUnit lb = intv.getLb();
		NumAndUnit ub = intv.getUb();
		NumAndUnit lbub = intv.getLbub();
		if (lb == null && ub == null)
			return "["+lbub.getValue()+","+lbub.getValue()+"]";
		return "["+lb.getValue()+","+ub.getValue()+"]";
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
