/**
 * Copyright (c) 2013 Egor Pushkin. All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.scientificsoft.iremote.server.messages;

import com.scientificsoft.iremote.server.protocol.Guid;
import com.scientificsoft.iremote.server.protocol.MessageImpl;
import com.scientificsoft.iremote.server.protocol.Property;

public class CookieMessage  extends MessageImpl {

    public static final Guid id_ 
    	= new Guid(0x2c3d38a7, 0xf40c, 0x4318, 0xb2, 0xfe, 0x34, 0xc9, 0xc5, 0x69, 0xbd, 0xe);
    	
	public static final int PROP_CODE = 1;
	
	public CookieMessage(Guid cookie) {
	    super(id_);
	    registerProperty(PROP_CODE, new Property(cookie));
	}		
}
