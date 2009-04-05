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
	.data
	.align
	.global fireRippleSine
	.global bossSine1
	.global bossSine2
	.global bossSpreadX
	.global bossSpreadY
	
	.section .rodata
	.balign 4

fireRippleSine:
	.byte  0 ,-3 ,-5 ,-8 ,-10 ,-12 ,-14 ,-16 
	.byte -17 ,-18 ,-19 ,-20 ,-20 ,-20 ,-19 ,-18 
	.byte -17 ,-16 ,-14 ,-12 ,-10 ,-8 ,-5 ,-3 
	.byte  0 , 3 , 5 , 8 , 10 , 12 , 14 , 16 
	.byte  17 , 18 , 19 , 20 , 20 , 20 , 19 , 18 
	.byte  17 , 16 , 14 , 12 , 10 , 8 , 5 , 3

	.section .rodata
	.balign 4

bossSine1:
	.byte  0 , 0 , 0 , 0 , 1 , 1 , 1 , 2 
	.byte  2 , 2 , 3 , 3 , 4 , 5 , 5 , 6 
	.byte  7 , 8 , 9 , 10 , 10 , 11 , 13 , 14 
	.byte  15 , 16 , 17 , 18 , 20 , 21 , 22 , 24 
	.byte  25 , 27 , 28 , 30 , 32 , 33 , 35 , 37 
	.byte  38 , 40 , 42 , 44 , 46 , 48 , 50 , 52 
	.byte  54 , 56 , 58 , 60 , 62 , 64 , 66 , 68 
	.byte  70 , 73 , 75 , 77 , 79 , 82 , 84 , 86 
	.byte  89 , 91 , 93 , 96 , 98 , 101 , 103 , 105 
	.byte  108 , 110 , 113 , 115 , 118 , 120 , 123 , 125 
	.byte  127 , 130 , 132 , 135 , 137 , 140 , 142 , 145 
	.byte  147 , 149 , 152 , 154 , 157 , 159 , 161 , 164 
	.byte  166 , 168 , 171 , 173 , 175 , 177 , 180 , 182 
	.byte  184 , 186 , 188 , 190 , 192 , 194 , 196 , 198 
	.byte  200 , 202 , 204 , 206 , 208 , 210 , 212 , 213 
	.byte  215 , 217 , 218 , 220 , 222 , 223 , 225 , 226 
	.byte  228 , 229 , 230 , 232 , 233 , 234 , 235 , 236 
	.byte  237 , 239 , 240 , 240 , 241 , 242 , 243 , 244 
	.byte  245 , 245 , 246 , 247 , 247 , 248 , 248 , 248 
	.byte  249 , 249 , 249 , 250 , 250 , 250 , 250 , 250 
	.byte  250 , 250 , 250 , 250 , 249 , 249 , 249 , 248 
	.byte  248 , 248 , 247 , 247 , 246 , 245 , 245 , 244 
	.byte  243 , 242 , 241 , 240 , 240 , 239 , 237 , 236 
	.byte  235 , 234 , 233 , 232 , 230 , 229 , 228 , 226 
	.byte  225 , 223 , 222 , 220 , 218 , 217 , 215 , 213 
	.byte  212 , 210 , 208 , 206 , 204 , 202 , 200 , 198 
	.byte  196 , 194 , 192 , 190 , 188 , 186 , 184 , 182 
	.byte  180 , 177 , 175 , 173 , 171 , 168 , 166 , 164 
	.byte  161 , 159 , 157 , 154 , 152 , 149 , 147 , 145 
	.byte  142 , 140 , 137 , 135 , 132 , 130 , 127 , 125 
	.byte  123 , 120 , 118 , 115 , 113 , 110 , 108 , 105 
	.byte  103 , 101 , 98 , 96 , 93 , 91 , 89 , 86 
	.byte  84 , 82 , 79 , 77 , 75 , 73 , 70 , 68 
	.byte  66 , 64 , 62 , 60 , 58 , 56 , 54 , 52 
	.byte  50 , 48 , 46 , 44 , 42 , 40 , 38 , 37 
	.byte  35 , 33 , 32 , 30 , 28 , 27 , 25 , 24 
	.byte  22 , 21 , 20 , 18 , 17 , 16 , 15 , 14 
	.byte  13 , 11 , 10 , 10 , 9 , 8 , 7 , 6 
	.byte  5 , 5 , 4 , 3 , 3 , 2 , 2 , 2 
	.byte  1 , 1 , 1 , 0 , 0 , 0 , 0 , 0

	.section .rodata
	.balign 4

bossSine2:
	.byte  1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 
	.byte  1 , 1 , 2 , 2 , 3 , 4 , 5 , 6 
	.byte  7 , 9 , 10 , 11 , 13 , 14 , 16 , 18 
	.byte  20 , 22 , 24 , 26 , 28 , 31 , 33 , 35 
	.byte  38 , 40 , 43 , 46 , 49 , 52 , 54 , 57 
	.byte  60 , 64 , 67 , 70 , 73 , 76 , 80 , 83 
	.byte  86 , 90 , 93 , 97 , 100 , 104 , 107 , 111 
	.byte  114 , 118 , 121 , 125 , 129 , 132 , 136 , 139 
	.byte  143 , 146 , 150 , 153 , 157 , 160 , 164 , 167 
	.byte  170 , 174 , 177 , 180 , 183 , 186 , 190 , 193 
	.byte  196 , 198 , 201 , 204 , 207 , 210 , 212 , 215 
	.byte  217 , 219 , 222 , 224 , 226 , 228 , 230 , 232 
	.byte  234 , 236 , 237 , 239 , 240 , 241 , 243 , 244 
	.byte  245 , 246 , 247 , 248 , 248 , 249 , 249 , 250 
	.byte  250 , 250 , 250 , 250 , 250 , 250 , 249 , 249 
	.byte  248 , 248 , 247 , 246 , 245 , 244 , 243 , 241 
	.byte  240 , 239 , 237 , 236 , 234 , 232 , 230 , 228 
	.byte  226 , 224 , 222 , 219 , 217 , 215 , 212 , 210 
	.byte  207 , 204 , 201 , 198 , 196 , 193 , 190 , 186 
	.byte  183 , 180 , 177 , 174 , 170 , 167 , 164 , 160 
	.byte  157 , 153 , 150 , 146 , 143 , 139 , 136 , 132 
	.byte  129 , 125 , 121 , 118 , 114 , 111 , 107 , 104 
	.byte  100 , 97 , 93 , 90 , 86 , 83 , 80 , 76 
	.byte  73 , 70 , 67 , 64 , 60 , 57 , 54 , 52 
	.byte  49 , 46 , 43 , 40 , 38 , 35 , 33 , 31 
	.byte  28 , 26 , 24 , 22 , 20 , 18 , 16 , 14 
	.byte  13 , 11 , 10 , 9 , 7 , 6 , 5 , 4 
	.byte  3 , 2 , 2 , 1 , 1 , 0 , 0 , 0 
	.byte  0 , 0 , 0 , 0 , 1 , 1 , 2 , 2 
	.byte  3 , 4 , 5 , 6 , 7 , 9 , 10 , 11 
	.byte  13 , 14 , 16 , 18 , 20 , 22 , 24 , 26 
	.byte  28 , 31 , 33 , 35 , 38 , 40 , 43 , 46 
	.byte  49 , 52 , 54 , 57 , 60 , 64 , 67 , 70 
	.byte  73 , 76 , 80 , 83 , 86 , 90 , 93 , 97 
	.byte  100 , 104 , 107 , 111 , 114 , 118 , 121 , 125 
	.byte  129 , 132 , 136 , 139 , 143 , 146 , 150 , 153 
	.byte  157 , 160 , 164 , 167 , 170 , 174 , 177 , 180 
	.byte  183 , 186 , 190 , 193 , 196 , 198 , 201 , 204 
	.byte  207 , 210 , 212 , 215 , 217 , 219 , 222 , 224 
	.byte  226 , 228 , 230 , 232 , 234 , 236 , 237 , 239 
	.byte  240 , 241 , 243 , 244 , 245 , 246 , 247 , 248 
	.byte  248 , 249 , 249 , 250 , 250 , 250 , 250 , 250 
	.byte  250 , 250 , 249 , 249 , 248 , 248 , 247 , 246 
	.byte  245 , 244 , 243 , 241 , 240 , 239 , 237 , 236 
	.byte  234 , 232 , 230 , 228 , 226 , 224 , 222 , 219 
	.byte  217 , 215 , 212 , 210 , 207 , 204 , 201 , 198 
	.byte  196 , 193 , 190 , 186 , 183 , 180 , 177 , 174 
	.byte  170 , 167 , 164 , 160 , 157 , 153 , 150 , 146 
	.byte  143 , 139 , 136 , 132 , 129 , 125 , 121 , 118 
	.byte  114 , 111 , 107 , 104 , 100 , 97 , 93 , 90 
	.byte  86 , 83 , 80 , 76 , 73 , 70 , 67 , 64 
	.byte  60 , 57 , 54 , 52 , 49 , 46 , 43 , 40 
	.byte  38 , 35 , 33 , 31 , 28 , 26 , 24 , 22 
	.byte  20 , 18 , 16 , 14 , 13 , 11 , 10 , 9 
	.byte  7 , 6 , 5 , 4 , 3 , 2 , 2 , 1 

	.section .rodata
	.balign 4

bossSpreadX:					@ 47 degrees :) (what a silly number - just for test though)
	.byte 0,10,20,30,40,50,60,70,80,80,90,90,90,90,90,80,80,70,60,50,40,30,20
	.byte 0,-10,-20,-30,-40,-50,-60,-70,-80,-80,-90,-90,-90,-90,-90
	.byte -80,-80,-70,-60,-50,-40,-30,-20,-10

	.section .rodata
	.balign 4

bossSpreadY:
	.byte -90,-90,-90,-80,-80,-70,-60,-50,-40,-30,-20,-10,0
	.byte 10,20,30,40,50,60,70,80,80,90,90,90,90,90,80,80,70,60,50,40,30,20,10
	.byte 0,-10,-20,-30,-40,-50,-60,-70,-80,-80,-90,-90

	.pool
	.end
