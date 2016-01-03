package com.steffenl.superpaint.core.painting.algorithm {
public class LinearLineAlgorithms {
    // Ref.: http://stackoverflow.com/a/11683720
    public static function line1(x:int, y:int, x2:int, y2:int, setPixel:Function):void {
        var w:int = x2 - x ;
        var h:int = y2 - y ;
        var dx1:int = 0, dy1:int = 0, dx2:int = 0, dy2:int = 0 ;
        if (w<0) dx1 = -1 ; else if (w>0) dx1 = 1 ;
        if (h<0) dy1 = -1 ; else if (h>0) dy1 = 1 ;
        if (w<0) dx2 = -1 ; else if (w>0) dx2 = 1 ;
        var  longest:int = Math.abs(w) ;
        var  shortest:int = Math.abs(h) ;
        if (!(longest>shortest)) {
            longest = Math.abs(h) ;
            shortest = Math.abs(w) ;
            if (h<0) dy2 = -1 ; else if (h>0) dy2 = 1 ;
            dx2 = 0 ;
        }
        var numerator:int = longest >> 1 ;
        for (var i:int=0;i<=longest;i++) {
            setPixel(x,y) ;
            numerator += shortest ;
            if (!(numerator<longest)) {
                numerator -= longest ;
                x += dx1 ;
                y += dy1 ;
            } else {
                x += dx2 ;
                y += dy2 ;
            }
        }
    }

    // Ref.: http://jacksondunstan.com/articles/506
    public static function line2(x:int, y:int, x2:int, y2:int, setPixel:Function):void {
        var shortLen:int = y2-y;
        var longLen:int = x2-x;

        if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31))
        {
            shortLen ^= longLen;
            longLen ^= shortLen;
            shortLen ^= longLen;

            var yLonger:Boolean = true;
        }
        else
        {
            yLonger = false;
        }

        var inc:int = longLen < 0 ? -1 : 1;

        var multDiff:Number = longLen == 0 ? shortLen : shortLen / longLen;

        if (yLonger)
        {
            for (var i:int = 0; i != longLen; i += inc)
            {
                setPixel(x + i*multDiff, y+i);
            }
        }
        else
        {
            for (i = 0; i != longLen; i += inc)
            {
                setPixel(x+i, y+i*multDiff);
            }
        }
    }

    // Ref.: http://www.codekeep.net/snippets/e39b2d9e-0843-4405-8e31-44e212ca1c45.aspx
    // Slightly modified for my own needs and compatibility with ActionScript 3.
    /**
     * Draws a line between two points p1(p1x,p1y) and p2(p2x,p2y).
     * This function is based on the Bresenham's line algorithm and is highly
     * optimized to be able to draw lines very quickly. There is no floating point
     * arithmetic nor multiplications and divisions involved. Only addition,
     * subtraction and bit shifting are used.
     *
     * Note that you have to define your own customized setPixel(x,y) function,
     * which essentially lights a pixel on the screen.
     */
    public static function line3(p1x:int, p1y:int, p2x:int, p2y:int, setPixel:Function):void {
        _line3Internal({ value: p1x }, { value: p1y }, { value: p2x }, { value: p2y }, setPixel);
    }
    
    private static function _line3Internal(p1x:Object, p1y:Object, p2x:Object, p2y:Object, setPixel:Function):void {
        var F:int, x:int, y:int;

        if (p1x.value > p2x.value)  // Swap points if p1 is on the right of p2
        {
            _swap(p1x, p2x);
            _swap(p1y, p2y);
        }

        // Handle trivial cases separately for algorithm speed up.
        // Trivial case 1: m = +/-INF (Vertical line)
        if (p1x.value === p2x.value)
        {
            if (p1y.value > p2y.value)  // Swap y-coordinates if p1 is above p2
            {
                _swap(p1y, p2y);
            }

            x = p1x.value;
            y = p1y.value;
            while (y <= p2y.value)
            {
                setPixel(x, y);
                y++;
            }
            return;
        }
        // Trivial case 2: m = 0 (Horizontal line)
        else if (p1y.value === p2y.value)
        {
            x = p1x.value;
            y = p1y.value;

            while (x <= p2x.value)
            {
                setPixel(x, y);
                x++;
            }
            return;
        }


        var dy:int            = p2y.value - p1y.value;  // y-increment from p1 to p2
        var dx:int            = p2x.value - p1x.value;  // x-increment from p1 to p2
        var dy2:int           = (dy << 1);  // dy << 1 === 2*dy
        var dx2:int           = (dx << 1);
        var dy2_minus_dx2:int = dy2 - dx2;  // precompute constant for speed up
        var dy2_plus_dx2:int  = dy2 + dx2;


        if (dy >= 0)    // m >= 0
        {
            // Case 1: 0 <= m <= 1 (Original case)
            if (dy <= dx)
            {
                F = dy2 - dx;    // initial F

                x = p1x.value;
                y = p1y.value;
                while (x <= p2x.value)
                {
                    setPixel(x, y);
                    if (F <= 0)
                    {
                        F += dy2;
                    }
                    else
                    {
                        y++;
                        F += dy2_minus_dx2;
                    }
                    x++;
                }
            }
            // Case 2: 1 < m < INF (Mirror about y=x line
            // replace all dy by dx and dx by dy)
            else
            {
                F = dx2 - dy;    // initial F

                y = p1y.value;
                x = p1x.value;
                while (y <= p2y.value)
                {
                    setPixel(x, y);
                    if (F <= 0)
                    {
                        F += dx2;
                    }
                    else
                    {
                        x++;
                        F -= dy2_minus_dx2;
                    }
                    y++;
                }
            }
        }
        else    // m < 0
        {
            // Case 3: -1 <= m < 0 (Mirror about x-axis, replace all dy by -dy)
            if (dx >= -dy)
            {
                F = -dy2 - dx;    // initial F

                x = p1x.value;
                y = p1y.value;
                while (x <= p2x.value)
                {
                    setPixel(x, y);
                    if (F <= 0)
                    {
                        F -= dy2;
                    }
                    else
                    {
                        y--;
                        F -= dy2_plus_dx2;
                    }
                    x++;
                }
            }
            // Case 4: -INF < m < -1 (Mirror about x-axis and mirror
            // about y=x line, replace all dx by -dy and dy by dx)
            else
            {
                F = dx2 + dy;    // initial F

                y = p1y.value;
                x = p1x.value;
                while (y >= p2y.value)
                {
                    setPixel(x, y);
                    if (F <= 0)
                    {
                        F += dx2;
                    }
                    else
                    {
                        x++;
                        F += dy2_plus_dx2;
                    }
                    y--;
                }
            }
        }
    }

    private static function _swap(a:Object, b:Object):void
    {
        var c:Object = a.value;
        a.value = b.value;
        b.value = c;
    }
}
}
