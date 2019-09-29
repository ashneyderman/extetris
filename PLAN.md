
DexTris

Introduction

This is yet another spin on the popular game of `Tetris`. This variant is a distributed version. It enables tetris lovers to come together to a central place and compete against a live oponent or a tetris bot.

What's in the name
DexTris is a play on distributed elixir tetris.

TODOs

(+) 1. Field
	     A. Tests
	     B. Documentation and specs

(-) 2. GameController
			 A. + Eliminate filled up rows and increment the score.
			 B. Tests.
	     C. Documentation and specs.
       D. + Game over has a problem (coordinate is not correctly checked)
	     E. + Selection of the initial shape coordinate needs work (i.e. the
	        closest cell has to have coordinate -1, so the next tick allows
	     	  to move the shape into the visble zone).
	     F. + Respond to click events.

(+) 3. Configure dializer.

(-) 4. Merge this to live view application.

(-) 5. Create tetris bot controller with levels and everything

(-) 6. Create registration system to keep scores and recognize
       repeat users.

(-) 7. Create leaderboard

(-) 8. Deployment
