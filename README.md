# RTUnVehicle

Forked from [crabtruckington's](https://github.com/crabtruckington/RTUnVehicle) original script.

Do you want all the features of RogueTech without having every enemy lance comprised entirely of ridiculously overpowered vehicles?
Tired of facing 10 VTOLs and 20 vehicles every battle?
Interested in having Battlemechs be a part of your Battlemech experience?
 Well boy howdy, do I have a script for you!

This script will modify the Lance files in RogueTech to remove vehicles from nearly every Lance type, except lances that are only comprised of vehicles, and specialty lances made for missions where it is intended you fight vehicles.

As of version 1.2, this script now has the optional ability to completely remove VTOLs from the spawn pool.

## Usage

1) Download Ruby from [https://www.ruby-lang.org/en/downloads/](https://www.ruby-lang.org/en/downloads/). 4.0.5 is the current recommended version, anything 3.2 and above should work.
2) Download this ruby script, `RTUnvehicle.rb`, and the companion file `DefaultMechs.rb` and place them in their own directory, I recommend something like `C:\rtUnVehicle`
3) Go to your BattleTech installation folder, and copy `\Mods\RogueTech Core\Lances` into the same directory as `RTUnvehicle.rb`
4) Open a cmd prompt, navigate to the directory you placed the `Lances` folder and `rtUnvehicle.rb`, and type `ruby RTUnvehicle.rb` to run the script
5) Follow the instructions provided to copy the new Lance files into the RT directory.
6) Enjoy the game about mechs not having 90% of the spawns be vehicles!

## Development Instructions

1. Install [rbenv](https://github.com/rbenv/rbenv)
2. Install ruby version of your choice

    ```bash
    rbenv install 4.0.5
    rbenv global 4.0.5 # global not always needed
    # Verify correct ruby
    which ruby
    ruby --version
    ```

3. Install dependencies

From project directory

    ```bash
    bundle install
    ```

## Roadmap

[ ] Add options to remove or tone down the amount of battle armor seen.
[ ] Easier install/uninstall experience.

## Disclaimer

This script has nothing to do with official RogueTech mod. Do not bring any problems to the RogueTech team, they will not help you. There is no support, official or otherwise. You use this script and modify the files at your own risk.

All of the above applies to HareBrainedSchemes and the official BattleTech game, branding, whatever, in perpetuity across the universe. I make no claims to ownership of any content, provided or otherwise. All respective trademark or copyright holders rights are retained, and any reference to trademark or copyright here is done under the assumption of Fair Use.

This script is provided "As Is".

## Thank Yous

You Know Who, thank you for the inspiration to create this after being extremely rude and dismissive about this for the past few years, and denying its possible because its too much work.
