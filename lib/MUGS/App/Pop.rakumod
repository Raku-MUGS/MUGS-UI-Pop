# ABSTRACT: Core logic to set up and run a Pop game

# XXXX: use Pop essential app modules here

use MUGS::Core;
use MUGS::App::LocalUI;
use MUGS::UI::Pop;


# Use subcommand MAIN args
%PROCESS::SUB-MAIN-OPTS = :named-anywhere;


#| Pop app
class MUGS::App::Pop is MUGS::App::LocalUI {
    has MUGS::UI::Pop::Game $.current-game;
    # XXXX: Add additional app-wide state attributes here

    method ui-type() { 'Pop' }

    #| Initialize the overall MUGS client app
    method initialize() {
        callsame;
        # XXXX: Extend to initialize toolkit and Pop-specific globals
    }

    #| Shut down the overall MUGS client app (as cleanly as possible)
    method shutdown() {
        # XXXX: Extend to stop Pop
        callsame;
    }

    #| Connect to server and authenticate as a valid user
    method ensure-authenticated-session(Str $server, Str $universe) {
        my $decoded = self.decode-and-connect($server, $universe);
        my ($username, $password) = self.initial-userpass($decoded);

        # XXXX: Should allow player to correct errors and retry or exit
        await $.session.authenticate(:$username, :$password);
    }

    #| Create and initialize a new game UI for a given game type and client
    method launch-game-ui(Str:D :$game-type, MUGS::Client::Game:D :$client, *%ui-opts) {
        $!current-game = callsame;
    }

    #| Start actively playing current game UI
    method play-current-game() {
        # XXXX: Enter Pop main loop here, or (by default) hand to game UI
        $!current-game.main-loop;
    }
}


#| Common options that work for all subcommands
my $common-args = :(Str :$server, Str :$universe, Bool :$debug);

#| Add description of common arguments/options to standard USAGE
sub GENERATE-USAGE(&main, |capture) is export {
    &*GENERATE-USAGE(&main, |capture).subst(' <options>', '', :g)
    ~ q:to/OPTIONS/.trim-trailing;


        Common options for all commands:
          --server=<Str>    Specify an external server (defaults to internal)
          --universe=<Str>  Specify a local universe (internal server only)
          --debug           Enable debug output
        OPTIONS
}


#| Play a requested Pop game
multi MAIN($game-type, |options where $common-args) is export {
    play-via-local-ui(MUGS::App::Pop, :$game-type, |options)
}
