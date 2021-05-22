# ABSTRACT: Pop interface for particle effect test games

use Pop;
use Pop::Graphics;

use MUGS::Core;
use MUGS::Client::Game::PFX;
use MUGS::UI::Pop;


#| Pop interface for a particle effect test game
class MUGS::UI::Pop::Game::PFX is MUGS::UI::Pop::Game {
    method game-type() { 'pfx' }

    method main-loop(::?CLASS:D:) {
        Pop.key-released: -> $key, $scancode {
            if $key eq 'ESCAPE' { await $.client.leave; Pop.stop }
        };

        Pop.render: { Pop::Graphics.clear };

        Pop.run;
    }
}


# Register this class as a valid game UI
MUGS::UI::Pop::Game::PFX.register;
