# Usage:
#
#  $ brew update
#    You should execute this first to update everything locally.
#
#  $ brew-cask.sh [update]
#    This will list all of your cask packages and rather there is an upgrade
#    pending with a ✔ checkmark, just like Homebrew does with "brew update".
#    The update command is optional, as it doesn't actually do any tracking, there's
#    not really anything to "update" with cask.  But it keeps with the pattern of
#    of Homebrew's "brew update" pattern for those with memory muscle fingers (like me).
#
#  $ brew-cask.sh upgrade
#    This performs a "brew cask install <cask> --force" of all cask packages that have
#    an update pending.
#
# This code was inspired by http://stackoverflow.com/a/36000907/56693

# get the list of installed casks
casks=( $(brew cask list) )

caskroom=/usr/local/Caskroom

if [[ "$1" == "upgrade" ]]; then
  for cask in ${casks[@]}; do
    current="$(brew cask info $cask | sed -n '1p' | sed -n 's/^.*: \(.*\)$/\1/p')"
    installed=( $(ls $caskroom/$cask))
    if (! [[ " ${installed[@]} " == *" $current "* ]]); then
      echo "Upgrading $cask to v$current."
      (set -x; brew cask install $cask --force;)
    else
      echo "$cask is up-to-date, skipping."
    fi
  done
else
  echo "Inspecting ${#casks[@]} casks. Use 'brew-cask.sh upgrade' to perform any updates."
  for (( i = i ; i < ${#casks[@]} ; i++ )); do
    current="$(brew cask info ${casks[$i]} | sed -n '1p' | sed -n 's/^.*: \(.*\)$/\1/p')"
    installed=( $(ls $caskroom/${casks[$i]}))
    if (! [[ " ${installed[@]} " == *" $current "* ]]); then
      casks[$i]="${casks[$i]}$(tput sgr0)$(tput setaf 2) ✔$(tput sgr0)"
    fi
  done
  echo " ${casks[@]/%/$'\n'}" 
fi
