@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"), to deal in the Software without restriction, including
@ without limitation the rights to use, copy, modify, merge, publish,
@ distribute, sublicense, and/or sell copies of the Software, and to
@ permit persons to whom the Software is furnished to do so, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	.arm
	.text
	.align
	.global sinus1
	.global fireRippleSine
	.global sinTable

fireRippleSine:
	.byte  0 ,-3 ,-5 ,-8 ,-10 ,-12 ,-14 ,-16 
	.byte -17 ,-18 ,-19 ,-20 ,-20 ,-20 ,-19 ,-18 
	.byte -17 ,-16 ,-14 ,-12 ,-10 ,-8 ,-5 ,-3 
	.byte  0 , 3 , 5 , 8 , 10 , 12 , 14 , 16 
	.byte  17 , 18 , 19 , 20 , 20 , 20 , 19 , 18 
	.byte  17 , 16 , 14 , 12 , 10 , 8 , 5 , 3 

sinus1:
	.byte  34 , 36 , 38 , 40 , 42 , 44 , 46 , 48 
	.byte  50 , 51 , 53 , 55 , 56 , 57 , 59 , 60 
	.byte  61 , 62 , 62 , 63 , 63 , 64 , 64 , 64 
	.byte  64 , 64 , 63 , 63 , 62 , 62 , 61 , 60 
	.byte  59 , 57 , 56 , 55 , 53 , 51 , 50 , 48 
	.byte  46 , 44 , 42 , 40 , 38 , 36 , 34 , 32 
	.byte  30 , 28 , 26 , 24 , 22 , 20 , 18 , 16 
	.byte  14 , 13 , 11 , 9 , 8 , 7 , 5 , 4 
	.byte  3 , 2 , 2 , 1 , 1 , 0 , 0 , 0 
	.byte  0 , 0 , 1 , 1 , 2 , 2 , 3 , 4 
	.byte  5 , 7 , 8 , 9 , 11 , 13 , 14 , 16 
	.byte  18 , 20 , 22 , 24 , 26 , 28 , 30 , 32 
	.byte  34 , 36 , 38 , 40 , 42 , 44 , 46 , 48 
	.byte  50 , 51 , 53 , 55 , 56 , 57 , 59 , 60 
	.byte  61 , 62 , 62 , 63 , 63 , 64 , 64 , 64 
	.byte  64 , 64 , 63 , 63 , 62 , 62 , 61 , 60 
	.byte  59 , 57 , 56 , 55 , 53 , 51 , 50 , 48 
	.byte  46 , 44 , 42 , 40 , 38 , 36 , 34 , 32 
	.byte  30 , 28 , 26 , 24 , 22 , 20 , 18 , 16 
	.byte  14 , 13 , 11 , 9 , 8 , 7 , 5 , 4 
	.byte  3 , 2 , 2 , 1 , 1 , 0 , 0 , 0 
	.byte  0 , 0 , 1 , 1 , 2 , 2 , 3 , 4 
	.byte  5 , 7 , 8 , 9 , 11 , 13 , 14 , 16 
	.byte  18 , 20 , 22 , 24 , 26 , 28 , 30 , 32 
	.byte  34 , 36 , 38 , 40 , 42 , 44 , 46 , 48 
	.byte  50 , 51 , 53 , 55 , 56 , 57 , 59 , 60 
	.byte  61 , 62 , 62 , 63 , 63 , 64 , 64 , 64 
	.byte  64 , 64 , 63 , 63 , 62 , 62 , 61 , 60 
	.byte  59 , 57 , 56 , 55 , 53 , 51 , 50 , 48 
	.byte  46 , 44 , 42 , 40 , 38 , 36 , 34 , 32 
	.byte  30 , 28 , 26 , 24 , 22 , 20 , 18 , 16 
	.byte  14 , 13 , 11 , 9 , 8 , 7 , 5 , 4 
	.byte  3 , 2 , 2 , 1 , 1 , 0 , 0 , 0 
	.byte  0 , 0 , 1 , 1 , 2 , 2 , 3 , 4 
	.byte  5 , 7 , 8 , 9 , 11 , 13 , 14 , 16 
	.byte  18 , 20 , 22 , 24 , 26 , 28 , 30 , 32 
	.byte  34 , 36 , 38 , 40 , 42 , 44 , 46 , 48 
	.byte  50 , 51 , 53 , 55 , 56 , 57 , 59 , 60 
	.byte  61 , 62 , 62 , 63 , 63 , 64 , 64 , 64 
	.byte  64 , 64 , 63 , 63 , 62 , 62 , 61 , 60 
	.byte  59 , 57 , 56 , 55 , 53 , 51 , 50 , 48 
	.byte  46 , 44 , 42 , 40 , 38 , 36 , 34 , 32 
	.byte  30 , 28 , 26 , 24 , 22 , 20 , 18 , 16 
	.byte  14 , 13 , 11 , 9 , 8 , 7 , 5 , 4 
	.byte  3 , 2 , 2 , 1 , 1 , 0 , 0 , 0 
	.byte  0 , 0 , 1 , 1 , 2 , 2 , 3 , 4 
	.byte  5 , 7 , 8 , 9 , 11 , 13 , 14 , 16 
	.byte  18 , 20 , 22 , 24 , 26 , 28 , 30 , 32
	
sinTable:
	.byte  17 , 18 , 18 , 19 , 20 , 21 , 21 , 22
	.byte  23 , 24 , 24 , 25 , 26 , 26 , 27 , 27
	.byte  28 , 28 , 29 , 29 , 30 , 30 , 30 , 31
	.byte  31 , 31 , 32 , 32 , 32 , 32 , 32 , 32
	.byte  32 , 32 , 32 , 32 , 32 , 31 , 31 , 31
	.byte  30 , 30 , 30 , 29 , 29 , 28 , 28 , 27
	.byte  27 , 26 , 26 , 25 , 24 , 24 , 23 , 22
	.byte  21 , 21 , 20 , 19 , 18 , 18 , 17 , 16
	.byte  15 , 14 , 14 , 13 , 12 , 11 , 11 , 10
	.byte  9 , 8 , 8 , 7 , 6 , 6 , 5 , 5
	.byte  4 , 4 , 3 , 3 , 2 , 2 , 2 , 1
	.byte  1 , 1 , 0 , 0 , 0 , 0 , 0 , 0
	.byte  0 , 0 , 0 , 0 , 0 , 1 , 1 , 1
	.byte  2 , 2 , 2 , 3 , 3 , 4 , 4 , 5
	.byte  5 , 6 , 6 , 7 , 8 , 8 , 9 , 10
	.byte  11 , 11 , 12 , 13 , 14 , 14 , 15 , 16
	.byte  17 , 18 , 18 , 19 , 20 , 21 , 21 , 22
	.byte  23 , 24 , 24 , 25 , 26 , 26 , 27 , 27
	.byte  28 , 28 , 29 , 29 , 30 , 30 , 30 , 31
	.byte  31 , 31 , 32 , 32 , 32 , 32 , 32 , 32
	.byte  32 , 32 , 32 , 32 , 32 , 31 , 31 , 31
	.byte  30 , 30 , 30 , 29 , 29 , 28 , 28 , 27
	.byte  27 , 26 , 26 , 25 , 24 , 24 , 23 , 22
	.byte  21 , 21 , 20 , 19 , 18 , 18 , 17 , 16
	.byte  15 , 14 , 14 , 13 , 12 , 11 , 11 , 10
	.byte  9 , 8 , 8 , 7 , 6 , 6 , 5 , 5
	.byte  4 , 4 , 3 , 3 , 2 , 2 , 2 , 1
	.byte  1 , 1 , 0 , 0 , 0 , 0 , 0 , 0
	.byte  0 , 0 , 0 , 0 , 0 , 1 , 1 , 1
	.byte  2 , 2 , 2 , 3 , 3 , 4 , 4 , 5
	.byte  5 , 6 , 6 , 7 , 8 , 8 , 9 , 10
	.byte  11 , 11 , 12 , 13 , 14 , 14 , 15 , 16

	
	.pool
	.end
