# ABSTRACT: Pop interface for particle effect test games

use Pop;
use Pop::Graphics;

use MUGS::Core;
use MUGS::Client::Game::PFX;
use MUGS::UI::Pop;


#| Pop interface for a particle effect test game
class MUGS::UI::Pop::Game::PFX is MUGS::UI::Pop::Game {
    method game-type() { 'pfx' }

    method handle-server-message($message) {
        given $message.type {
            when 'game-update' {
                $.client.validate-and-save-update($message);
            }
            when 'game-event'  {
                self.handle-game-event($message);
            }
        }
    }

    method handle-game-event($message) {
    }

    method main-loop(::?CLASS:D:) {
        Pop.key-released: -> $key, $scancode {
            given $key {
                when 'q'|'ESCAPE' { await $.client.leave; Pop.stop }
                when 'SPACE'      { $.client.send-pause-request }
            }
        };

        Pop.render: { self.render-updates };

        Pop.run;
    }

    method render-updates() {
        my $update;
        $.client.update-lock.protect: {
            my $queue := $.client.update-queue;
            $queue.shift while $queue.elems > 1;
            $update = $queue[0];
        }

        # Don't show anything if no data to work with
        return unless $update;

        Pop::Graphics.clear;
        self.render-particles($update<validated>);
    }

    method render-particles($validated) {
        my num $w  = Pop::Graphics.width;
        my num $h  = Pop::Graphics.height;
        my num $cx = $w / 2e0;
        my num $cy = $h / 2e0;
        my num $r  = min $cx, $cy;

        for @($validated<effects>) -> $effect {
            my $p = $effect<particles>;
            for ^($p.elems div 7) -> int $index {
                my int $base = $index * 7;
                my num $x    = $p[$base];
                my num $y    = $p[$base + 1];

                # Scale, flip Y dimension, and recenter to current particle area
                my num $px =  $x * $r + $cx;
                my num $py = -$y * $r + $cy;

                Pop::Graphics.point: ($px, $py), (^256).pick xx 3;
            }
        }
    }
}


# Register this class as a valid game UI
MUGS::UI::Pop::Game::PFX.register;
