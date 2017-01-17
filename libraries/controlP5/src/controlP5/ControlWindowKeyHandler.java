
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

import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Handles key events.
 * 
 * @exclude
 */
public class ControlWindowKeyHandler implements ControlP5Constants {

	private ControlWindow _myMasterControlWindow;

	public boolean isShiftDown = false;

	public boolean isKeyDown = false;

	boolean isAltDown = false;

	public boolean isCommandDown = false;

	protected char key = ' ';

	protected int keyCode = -1;

	private Map<KeyCode, List<ControlKey>> keymap = new HashMap<KeyCode, List<ControlKey>>();

	private boolean[] keys = new boolean[525];

	private int numOfActiveKeys = 0;


	public ControlWindowKeyHandler(ControlP5 theControlP5) {
		_myMasterControlWindow = theControlP5.controlWindow;
	}


	public void update(ControlWindow theControlWindow) {
		_myMasterControlWindow = theControlWindow;
	}


	public boolean isAltDown() {
		return isAltDown;
	}


	public void clear() {
		keys = new boolean[525];
		numOfActiveKeys = 0;
	}


	public void keyEvent(final KeyEvent theKeyEvent, final ControlWindow theControlWindow, final boolean isMasterWindow) {
		if (theKeyEvent.getID() == KeyEvent.KEY_PRESSED) {
			
			// allow special keys such as backspace, arrow left, arrow right to pass test when active
			if (keys[theKeyEvent.getKeyCode()] && theKeyEvent.getKeyCode() != 8 && theKeyEvent.getKeyCode() != 37 && theKeyEvent.getKeyCode() != 39) {
				return;
			}
			keys[theKeyEvent.getKeyCode()] = true;
			numOfActiveKeys++;
			switch (theKeyEvent.getKeyCode()) {
			case (KeyEvent.VK_SHIFT):
				if (_myMasterControlWindow.controlP5.isShortcuts()) {
					isShiftDown = true;
				}
				else {
					isShiftDown = false;
				}
				break;
			case (KeyEvent.VK_ALT):
				if (_myMasterControlWindow.controlP5.isShortcuts()) {
					isAltDown = true;
				}
				else {
					isAltDown = false;
				}
				break;
			case (157):
				if (_myMasterControlWindow.controlP5.isShortcuts()) {
					isCommandDown = true;
				}
				else {
					isCommandDown = false;
				}
				break;
			}
			key = theKeyEvent.getKeyChar();
			keyCode = theKeyEvent.getKeyCode();
			isKeyDown = true;
		}

		if (theKeyEvent.getID() == KeyEvent.KEY_RELEASED) {
			keys[theKeyEvent.getKeyCode()] = false;
			numOfActiveKeys--;

			switch (theKeyEvent.getKeyCode()) {
			case (KeyEvent.VK_SHIFT):
				isShiftDown = false;
				break;
			case (KeyEvent.VK_ALT):
				isAltDown = false;
				break;
			case (157):
				isCommandDown = false;
				break;
			}
			isKeyDown = false;
		}

		if (theKeyEvent.getID() == KeyEvent.KEY_PRESSED && _myMasterControlWindow.controlP5.isShortcuts()) {
			int n = 0;
			for (boolean b : keys) {
				n += b ? 1 : 0;
			}
			char[] c = new char[n];
			n = 0;
			for (int i = 0; i < keys.length; i++) {
				if (keys[i]) {
					c[n++] = ((char) i);
				}
			}
			KeyCode code = new KeyCode(c);

			if (keymap.containsKey(code)) {
				for (ControlKey ck : keymap.get(code)) {
					ck.keyEvent();
				}
			}
		}
		//during re/loading period of settings theControlWindow might be null
		if (theControlWindow != null) {
			theControlWindow.keyEvent(theKeyEvent);
		}

	}


	public void reset() {
		isShiftDown = false;
		isKeyDown = false;
		isAltDown = false;
		isCommandDown = false;
	}


	public void mapKeyFor(ControlKey theKey, char... theChar) {
		KeyCode kc = new KeyCode(theChar);
		if (!keymap.containsKey(kc)) {
			keymap.put(kc, new ArrayList<ControlKey>());
		}
		keymap.get(kc).add(theKey);
	}


	public void removeKeyFor(ControlKey theKey, char... theChar) {
		List<ControlKey> l = keymap.get(new KeyCode(theChar));
		if (l != null) {
			l.remove(theKey);
		}
	}


	public void removeKeysFor(char... theChar) {
		keymap.remove(new KeyCode(theChar));
	}


	class KeyCode {

		final char[] chars;


		KeyCode(char... theChars) {
			chars = theChars;
			Arrays.sort(chars);
		}


		public int size() {
			return chars.length;
		}


		public char[] getChars() {
			return chars;
		}


		public char get(int theIndex) {
			if (theIndex >= 0 && theIndex < size()) {
				return chars[theIndex];
			}
			return 0;
		}


		public boolean equals(Object obj) {
			if (!(obj instanceof KeyCode)) {
				return false;
			}

			KeyCode k = (KeyCode) obj;

			if (k.size() != size()) {
				return false;
			}

			for (int i = 0; i < size(); i++) {
				if (get(i) != k.get(i)) {
					return false;
				}
			}
			return true;
		}


		boolean contains(char n) {
			for (char c : chars) {
				if (n == c) {
					return true;
				}
			}
			return false;
		}


		public int hashCode() {
			int hashCode = 0;
			int n = 1;
			for (char c : chars) {
				hashCode += c + Math.pow(c, n++);
			}
			return hashCode;
		}
	}

}
