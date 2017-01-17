package controlP5;

/**
 * controlP5 is a processing gui library.
 *
 *  2006-2012 by Andreas Schlegel
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 *
 * @author 		Andreas Schlegel (http://www.sojamo.de)
 * @modified	10/22/2012
 * @version		1.5.2
 *
 */

import java.awt.Component;
import java.awt.Image;
import java.awt.MediaTracker;
import java.awt.Toolkit;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Array;
import java.net.URL;
import java.net.URLEncoder;
import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
/**
 * A input/output helper class. 
 *
 */
class ControlP5IOHandler {

	ControlP5 cp5;

	String _myFilePath;

	String _myUrlPath;

	boolean isLock;

	public ControlP5IOHandler(ControlP5 theControlP5) {
		cp5 = theControlP5;
	}
	

	/**
	 * borrowed from http://www.javapractices.com/Topic96.cjp
	 * 
	 * 
	 * @param aURLFragment String
	 * @return String
	 */
	public static String forURL(String aURLFragment) {
		String result = null;
		try {
			result = URLEncoder.encode(aURLFragment, "UTF-8");
		} catch (UnsupportedEncodingException ex) {
			throw new RuntimeException("UTF-8 not supported", ex);
		}
		return result;
	}

	/**
	 * borrowed from http://www.javapractices.com/Topic96.cjp
	 * 
	 * @param aTagFragment String
	 * @return String
	 */
	public static String forHTMLTag(String aTagFragment) {
		final StringBuffer result = new StringBuffer();

		final StringCharacterIterator iterator = new StringCharacterIterator(aTagFragment);
		char character = iterator.current();
		while (character != CharacterIterator.DONE) {
			if (character == '<') {
				result.append("&lt;");
			} else if (character == '>') {
				result.append("&gt;");
			} else if (character == '\"') {
				result.append("&quot;");
			} else if (character == '\'') {
				result.append("&#039;");
			} else if (character == '\\') {
				result.append("&#092;");
			} else if (character == '&') {
				result.append("&amp;");
			} else {
				// the char is not a special one
				// add it to the result as is
				result.append(character);
			}
			character = iterator.next();
		}
		return result.toString();
	}

	/**
	 * http://processing.org/discourse/yabb_beta/YaBB.cgi?board=Programs;action=
	 * display;num=1159828167;start=0#0
	 * 
	 * @param string String
	 * @return String
	 */
	String URLEncode(String string) {
		String output = new String();
		try {
			byte[] input = string.getBytes("UTF-8");
			for (int i = 0; i < input.length; i++) {
				if (input[i] < 0) {
					// output += ('%' + hex(input[i])); // see hex method in
					// processing
				} else if (input[i] == 32) {
					output += '+';
				} else {
					output += (char) (input[i]);
				}
			}
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return output;
	}

	public static String replace(String theSourceString, String theSearchForString, String theReplaceString) {
		if (theSourceString.length() < 1) {
			return "";
		}
		int p = 0;

		while (p < theSourceString.length() && (p = theSourceString.indexOf(theSearchForString, p)) >= 0) {
			theSourceString = theSourceString.substring(0, p) + theReplaceString
					+ theSourceString.substring(p + theSearchForString.length(), theSourceString.length());
			p += theReplaceString.length();
		}
		return theSourceString;
	}

	/**
	 * convert a hex number into an int
	 * 
	 * @param theHex
	 * @return
	 */
	public static int parseHex(String theHex) {
		int myLen = theHex.length();
		int a, r, b, g;
		switch (myLen) {
		case (8):
			break;
		case (6):
			theHex = "ff" + theHex;
			break;
		default:
			theHex = "ff000000";
			break;
		}
		a = (new Integer(Integer.parseInt(theHex.substring(0, 2), 16))).intValue();
		r = (new Integer(Integer.parseInt(theHex.substring(2, 4), 16))).intValue();
		g = (new Integer(Integer.parseInt(theHex.substring(4, 6), 16))).intValue();
		b = (new Integer(Integer.parseInt(theHex.substring(6, 8), 16))).intValue();
		return (a << 24 | r << 16 | g << 8 | b);
	}

	public static String intToString(int theInt) {
		int a = ((theInt >> 24) & 0xff);
		int r = ((theInt >> 16) & 0xff);
		int g = ((theInt >> 8) & 0xff);
		int b = ((theInt >> 0) & 0xff);
		String sa = ((Integer.toHexString(a)).length() == 1) ? "0" + Integer.toHexString(a) : Integer.toHexString(a);
		String sr = ((Integer.toHexString(r)).length() == 1) ? "0" + Integer.toHexString(r) : Integer.toHexString(r);
		String sg = ((Integer.toHexString(g)).length() == 1) ? "0" + Integer.toHexString(g) : Integer.toHexString(g);
		String sb = ((Integer.toHexString(b)).length() == 1) ? "0" + Integer.toHexString(b) : Integer.toHexString(b);
		return sa + sr + sg + sb;
	}

	/**
	 * @deprecated
	 */
	@Deprecated
	protected boolean save(ControlP5 theControlP5, String theFilePath) {
		ControlP5.logger().info("Saving ControlP5 settings in XML format has been removed, have a look at controlP5's properties instead.");
		return false;
	}

	/**
	 * * Convenience method for producing a simple textual representation of an
	 * array.
	 * 
	 * <P>
	 * The format of the returned <code>String</code> is the same as
	 * <code>AbstractCollection.toString</code>:
	 * <ul>
	 * <li>non-empty array: [blah, blah]
	 * <li>empty array: []
	 * <li>null array: null
	 * </ul>
	 * 
	 * 
	 * <code>aArray</code> is a possibly-null array whose elements are primitives
	 * or objects; arrays of arrays are also valid, in which case
	 * <code>aArray</code> is rendered in a nested, recursive fashion.
	 * 
	 * @author Jerome Lacoste
	 * @author www.javapractices.com
	 */
	public static String arrayToString(Object aArray) {
		if (aArray == null) {
			return fNULL;
		}

		checkObjectIsArray(aArray);

		StringBuilder result = new StringBuilder(fSTART_CHAR);
		int length = Array.getLength(aArray);
		for (int idx = 0; idx < length; ++idx) {
			Object item = Array.get(aArray, idx);
			if (isNonNullArray(item)) {
				// recursive call!
				result.append(arrayToString(item));
			} else {
				result.append(item);
			}
			if (!isLastItem(idx, length)) {
				result.append(fSEPARATOR);
			}
		}
		result.append(fEND_CHAR);
		return result.toString();
	}

	// PRIVATE //
	private static final String fSTART_CHAR = "[";
	private static final String fEND_CHAR = "]";
	private static final String fSEPARATOR = ", ";
	private static final String fNULL = "null";

	private static void checkObjectIsArray(Object aArray) {
		if (!aArray.getClass().isArray()) {
			throw new IllegalArgumentException("Object is not an array.");
		}
	}

	private static boolean isNonNullArray(Object aItem) {
		return aItem != null && aItem.getClass().isArray();
	}

	private static boolean isLastItem(int aIdx, int aLength) {
		return (aIdx == aLength - 1);
	}

	protected static String formatGetClass(Class<?> c) {
		if (c == null)
			return null;
		final String pattern = "class ";
		return c.toString().startsWith(pattern) ? c.toString().substring(pattern.length()) : c.toString();
	}

	
	@Deprecated
	public Image loadImage2(URL theURL) {
		return loadImage(cp5.papplet, theURL);
	}

	/**
	 * load an image with MediaTracker to prevent nullpointers e.g. in
	 * BitFontRenderer
	 * 
	 * @param theURL
	 * @return
	 */
	@Deprecated
	public Image loadImage(Component theComponent, URL theURL) {
		if (theComponent == null) {
			theComponent = cp5.papplet;
		}
		Image img = null;

		// TODO Toolkit causes problems inside a browser see forum.processing at
		// http://forum.processing.org/#Topic/25080000000607069
		img = Toolkit.getDefaultToolkit().createImage(theURL);

		MediaTracker mt = new MediaTracker(theComponent);
		mt.addImage(img, 0);
		try {
			mt.waitForAll();
		} catch (InterruptedException e) {
			ControlP5.logger().severe("loading image failed." + e.toString());
		} catch (Exception e) {
			ControlP5.logger().severe("loading image failed." + e.toString());
		}
		return img;
	}

}
