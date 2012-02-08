/**
 * @file  JTap.java
 * @brief Unit testing framework for Java based on the Test Anything Protocol.
 *
 * @author Patrick LeBoutillier <patl at cpan.org>
 *
 * @note This file is a copy of the JTap.java file which is part of the
 *       JTap project (http://svn.solucorp.qc.ca/repos/solucorp/JTap/trunk/).
 *       The original implementation has been modified by Andreas Schuh as
 *       part of the BASIS project at SBIA.
 *
 * Copyright (c) Patrick LeBoutillier.<br />
 * Copyright (c) 2011, University of Pennsylvania.<br />
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * @sa http://testanything.org/wiki/index.php/Tap-functions
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup BasisJavaUtilities
 */

import java.io.* ;


public class JTap {
	final private String version = "1.0" ;
	
	private boolean plan_set = false ;
	private boolean no_plan = false ;
	private boolean skip_all = false ;
	private boolean test_died = false ;
	private int expected_tests = 0 ;
	private int executed_tests = 0 ;
	private int failed_tests = 0 ;
	private boolean exit = true ;
	private String todo = null ;
	
	private PrintStream out = null ;
	private PrintStream err = null ;


	public JTap(){
		this(true) ;
	}


	public JTap(boolean really_exit){
		out = System.out ;
		err = System.err ;
		exit = really_exit ;
	}




	synchronized public int plan_no_plan(){
		if (plan_set){
			die("You tried to plan twice!") ;
		}

		plan_set = true ;
		no_plan = true ;

		return 1 ;
	}


	synchronized public int plan_skip_all(String reason){
		if (plan_set){
			die("You tried to plan twice!") ;
		}

		print_plan(0, "Skip " + reason) ;

		skip_all = true ;
		plan_set = true ;

		exit(0) ;

		return 0 ;
	}


	synchronized public int plan_tests(int tests){
		if (plan_set){
			die("You tried to plan twice!") ;
		}

		if (tests == 0){
			die("You said to run 0 tests!  You've got to run something.") ;
		}

		print_plan(tests) ;
		expected_tests = tests ;

		plan_set = true ;

		return tests ;
	}


	private void print_plan(int expected){
		print_plan(expected, null) ;
	}


	synchronized private void print_plan(int expected_tests, String directive){
		out.print("1.." + expected_tests) ;
		if (directive != null){
			out.print(" # " + directive) ;
		}
		out.print("\n") ;
		out.flush() ;
	}




	public boolean pass(String name){
		return ok(true, name) ;
	}


	public boolean fail(String name){
		return ok(false, name) ;
	}


	public boolean ok(boolean result){
		return ok(result, null) ;
	}


	/*
		This is the workhorse method that actually
		prints the tests result.
	*/
	synchronized public boolean ok(boolean result, String name){
		if (! plan_set){
			die("You tried to run a test without a plan!  Gotta have a plan.") ;
		}

		executed_tests++ ;

		if (name != null) {
			if (name.matches("[\\d\\s]+")){
				diag("    You named your test '" + name 
					+ "'.  You shouldn't use numbers for your test names.") ;
				diag("    Very confusing.") ;
			}
		}

		if (! result){
			out.print("not ") ;
			failed_tests++ ;
		}
		out.print("ok " + executed_tests) ;

		if (name != null) {
			out.print(" - ") ;
			out.print(name.replaceAll("#", "\\\\#")) ;
		}

		if (todo != null){
			out.print(" # TODO " + todo) ;
			if (! result){
				failed_tests-- ;
			}
		}

		out.print("\n") ;
		out.flush() ;
		if (! result){
			Throwable t = new Throwable() ; 
			StackTraceElement stack[] = t.getStackTrace() ;
			String file = null ;
			String clas = null ;
			String func = null ;
			int line = 0 ;

			try {
				for (int i = 0 ; i < stack.length ; i++){
					Class c = Class.forName(stack[i].getClassName()) ;
					if (! JTap.class.isAssignableFrom(c)){
						// We are outside a JTap object, so this is probably the callpoint
						file = stack[i].getFileName() ;
						clas = c.getName() ;
						func = stack[i].getMethodName() ;
						line = stack[i].getLineNumber() ;
						break ;
					}
				}
			}
			catch (Exception e){
				e.printStackTrace() ;
			}
	
			if (name != null){		
				diag("  Failed " + (todo == null ? "" : "(TODO) ") + "test '" + name + "'") ;
				diag("  in " + file + ":" + func + "() at line " + line + ".") ;
			}
			else {
				diag("  Failed " + (todo == null ? "" : "(TODO) ") + "test in " + file + ":" + func + "() at line " + line + ".") ;
			}
		}

		return result ;
	}


	private boolean equals(Object result, Object expected){
		boolean r ;

		if ((result == null)&&(expected == null)){
			r = true ;
		}
		else if ((result == null)||(expected == null)){
			r = false ;
		}
		else {
			r = result.equals(expected) ;
		}

		return r ;
	}


	private boolean matches(Object result, String pattern){
		boolean r ;

		if ((result == null)||(pattern == null)){
			r = false ;
		}
		else {
			r = result.toString().matches(pattern) ;
		}

		return r ;
	}


	private void is_diag(Object result, Object expected){
		diag("         got: '" + result + "'") ;
		diag("    expected: '" + expected + "'") ;
	}


	public boolean is(Object result, Object expected){
		return is(result, expected, null) ;
	}


	public boolean is(Object result, Object expected, String name){
		boolean r = ok(equals(result, expected), name) ;
		if (! r){
			is_diag(result, expected) ;
		}
		return r ;
	}


	public boolean is(long result, long expected){
		return is(new Long(result), new Long(expected)) ;
	}


	public boolean is(long result, long expected, String name){
		return is(new Long(result), new Long(expected), name) ;
	}


	public boolean is(double result, double expected){
		return is(new Double(result), new Double(expected)) ;
	}


	public boolean is(double result, double expected, String name){
		return is(new Double(result), new Double(expected), name) ;
	}


	public boolean isnt(Object result, Object expected){
		return isnt(result, expected, null) ;
	}


	public boolean isnt(Object result, Object expected, String name){
		boolean r = ok(! equals(result, expected), name) ;
		if (! r){
			is_diag(result, expected) ;
		}
		return r ;
	}


	public boolean isnt(long result, long expected){
		return isnt(new Long(result), new Long(expected)) ;
	}


	public boolean isnt(long result, long expected, String name){
		return isnt(new Long(result), new Long(expected), name) ;
	}


	public boolean isnt(double result, double expected){
		return isnt(new Double(result), new Double(expected)) ;
	}


	public boolean isnt(double result, double expected, String name){
		return isnt(new Double(result), new Double(expected), name) ;
	}


	public boolean like(Object result, String pattern){
		return like(result, pattern, null) ;
	}


	public boolean like(Object result, String pattern, String name){
		boolean r = ok(matches(result, pattern), name) ;
		if (! r){
			diag("    " + result + " doesn't match '" + pattern + "'") ;
		}
		return r ;
	}


	public boolean unlike(Object result, String pattern){
		return unlike(result, pattern, null) ;
	}


	public boolean unlike(Object result, String pattern, String name){
		boolean r = ok(! matches(result, pattern), name) ;
		if (! r){
			diag("    " + result + " matches '" + pattern + "'") ;
		}
		return r ;
	}


	public boolean isa_ok(Object o, Class c){
		return isa_ok(o, c, null) ;
	}


	public boolean isa_ok(Object o, Class c, String name){
		boolean r = false ;
		if ((o == null)||(c == null)){
			r = false ;	
		}
		else {
			r = ok(c.isInstance(o), name) ;
		}
		if (! r){
			diag("    Object isn't a '" + c.getName() + "' it's a '" + o.getClass().getName() + "'") ;
		}

		return r ;
	}




	synchronized public void skip(String reason){
		skip(reason, 1) ;
	}


	synchronized public void skip(String reason, int n){
		for (int i = 0 ; i < n ; i++){
			executed_tests++ ;
			out.print("ok " + executed_tests + " # skip " + reason + "\n") ;
			out.flush() ;
		}
		throw new JTapSkipException(reason) ;
	}


	synchronized public void todo_start(String reason){
		if (reason.equals("")){
			reason = null ;
		}
		todo = reason ;
	}


	synchronized public void todo_end(){
		todo = null ;
	}


	synchronized public boolean diag(String msg){
		if (msg != null){
			String lines[] = msg.split("\n") ;
			StringBuffer buf = new StringBuffer() ; 
			for (int i = 0 ; i < lines.length ; i++){
				buf.append("# " + lines[i] + "\n") ;
			}
			out.print(buf) ;
			out.flush() ;
		}
		return false ;
	}



	
	synchronized private void die(String reason){
		err.println(reason) ;
        test_died = true ;
		exit(255) ;
	}


	synchronized public void BAIL_OUT(String reason){
		out.println("Bail out! " + reason) ;
		out.flush() ;
		exit(255) ;
	}


	private int cleanup(){
		int rc = 0 ;

		if (! plan_set){
			diag("Looks like your test died before it could output anything.") ;
			return rc ;
		}

		if (test_died){
			diag("Looks like your test died just after " + executed_tests + ".") ;
			return rc ;
		}

		if ((! skip_all)&&(no_plan)){
			print_plan(executed_tests) ;
		}

		if ((! no_plan)&&(expected_tests < executed_tests)) {
			diag("Looks like you planned " + expected_tests + " test" + (expected_tests > 1 ? "s" : "") + " but ran "
				+ (executed_tests - expected_tests) + " extra.") ;
			rc = -1 ;
		}

		if ((! no_plan)&&(expected_tests > executed_tests)) {
			diag("Looks like you planned " + expected_tests + " test" + (expected_tests > 1 ? "s" : "") + " but only ran "
				+ executed_tests + ".") ;
		}

		if (failed_tests > 0){
			diag("Looks like you failed " + failed_tests + " test" + (failed_tests > 1 ? "s" : "") + " of " + executed_tests + ".") ;
		}

		return rc ;
	}


	synchronized public int exit_status(){
		if ((no_plan)||(! plan_set)){
			return failed_tests ;
		}

		if (expected_tests < executed_tests){
			return executed_tests - expected_tests ;
		}

		return failed_tests + (expected_tests - executed_tests) ;
	}


	synchronized public void exit(){
		exit(exit_status()) ;
	}


	synchronized private void exit(int rc){
		int alt_rc = cleanup() ;
		if (alt_rc != 0){
			rc = alt_rc ;
		}
		if (exit){
			System.exit(rc) ;
		}
		else {
			throw new JTapExitException(rc) ;
		}
	}
}




class JTapException extends RuntimeException {
	JTapException(String msg){
		super(msg) ;
	}
}




class JTapExitException extends JTapException {
	JTapExitException(int rc){
		super("exit " + rc) ;
	}
}




class JTapSkipException extends JTapException {
	JTapSkipException(String reason){
		super("skip " + reason) ;
	}
}



