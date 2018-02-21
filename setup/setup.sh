#! /bin/bash
CURDIR="$(dirname $(readlink -f "$0"))"
find "$CURDIR/.." -maxdepth 1 -not -iname setup -not -iname .. -not -iname . -not -iname .git | while read each ; do
    DEST="$HOME/$(basename "$each")"
    if [ -e "$DEST" ] ; then
       mv -v "$DEST" "$DEST.bak" || echo "$DEST already exists."
    fi

    if [ ! -e "$DEST" ] ; then
        case "$OSTYPE" in
            linux-gnu)
                ln -v -s "$each" "$DEST"
            ;;
            *)
		echo "$DEST -> $each"
                if [ -d "$each" ] ; then
                    MDIR="/d"
		else
                    MDIR=""
                fi
                # Also, screw any version of Windows other than 10.
		powershell.exe -Command New-Item -ItemType SymbolicLink -Path "$(cygpath -w "$DEST")" -Value "$(cygpath -w "$each")"
            ;;
        esac
    fi
done

case "$OSTYPE" in
    linux-gnu)
        sudo npm install -g tern
	sudo apt install python3-pip
    ;;
    *)
        # Windows stuff. Not clear all the environment types that are possible here, so assuming Windows if we don't know.
	# Also, screw darwin.
        # Git Bash: 'msys'
	choco upgrade python nodejs
        npm install -g tern
    ;;
esac

(
    cd "$CURDIR/../script"
    yarn install
)

pip3 install --upgrade neovim
vim '+PlugInstall' '+qall!'
