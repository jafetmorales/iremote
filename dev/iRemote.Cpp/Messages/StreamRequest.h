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

#ifndef STREAMREQUEST_H__REMOTEPC__INCLUDED_
#define STREAMREQUEST_H__REMOTEPC__INCLUDED_

namespace RemotePC
{
    class StreamRequest
        : public mc::MessageImpl
    {
    public:

        typedef enum tagProperties_
        {
            PROP_ID = 1,
            PROP_PORT,
            PROP_COOKIE
        }
        Properties_;

        static const mc::Guid messageId_;

        StreamRequest();

        StreamRequest( const mc::Guid& id, const std::string& port, const mc::Guid& cookie );

        // IMessage section
        virtual mc::IMessage::Size_ GetDataSize();

        // MessageImpl section
        virtual mc::result WriteBody(std::ostream& stream);

        virtual mc::result ReadBody(std::istream& stream);

    };

}

#endif // STREAMREQUEST_H__REMOTEPC__INCLUDED_
