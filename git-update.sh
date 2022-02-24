#!/bin/sh

test -f ~/.my_gh_token.txt || {
	echo -n "Please enter your GitHub access token: "
        read ANSWER
	echo "$ANSWER" > ~/.my_gh_token.txt
}

test -f .git/config && sed -i "s/\/\/github/\/\/joschro@github/" .git/config
test -n "$(git config --global user.email)" || git config --global user.email "jo@joschro.de"
test -n "$(git config --global user.name)" || git config --global user.name "Joachim Schröder"

function setup_gh {
	test -e /etc/os-release && os_release='/etc/os-release' || os_release='/usr/lib/os-release'
. "${os_release}"

	echo "Running on ${PRETTY_NAME:-Linux}"
	osPlatform="${ID}"; test -n "${ID_LIKE}" && osPlatform="$(echo "${ID_LIKE}" | sed "s/ .*//")"
	echo "OS platform: ${osPlatform}"

	# install GitHub CLI (from: https://cli.github.com/manual/installation)
	case "${osPlatform}" in
		"RHEL")		{
                	          rpm -q gh || {
                        	    sudo yum config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
	                            sudo yum install gh -y
        	                  }
                		}
                		;;
		"fedora")	{
				  rpm -q gh || {
				    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
				    sudo dnf install gh -y
				  }
				}
				;;
		"debian")	{
				  dpkg -l gh >/dev/null || {
				    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg
				    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
				    sudo apt update
				    sudo apt install gh
				  }
				}
				;;
		"*")		echo "${osPlatform} not known as an OS:"
				;;
	esac

	gh auth status || {
		gh config set git_protocol https -h github.com
		gh auth setup-git
		echo "Make sure to have your GitHub access token entered in ~/.my_gh_token.txt"
		gh auth login --with-token < ~/.my_gh_token.txt
	}
}

git pull
git add -A
git commit -a
git push https://$(cat ~/.my_gh_token.txt)@github.com/joschro/$(basename $PWD).git

