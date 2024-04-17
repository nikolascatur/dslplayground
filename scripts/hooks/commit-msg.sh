#!/bin/bash

NO_COLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

echo "Running commit message check..."

COMMIT_FILE=$1
COMMIT_MSG=$(cat ${COMMIT_FILE})

COMMIT_MSG_REGEX="^(revert: )?(feat|fix|BREAKING CHANGE|docs|style|refactor|perf|test|chore) {1,50}";
if [[ ! ${COMMIT_MSG} =~ ${COMMIT_MSG_REGEX} ]]; then
    echo -e "\nPlease change your commit message to the format below 👍: "
    echo -e "${GREEN}[PREFIX]: something else ${NO_COLOR}(ex docs: update file release notes)"
    echo -e "\n${NO_COLOR}List prefix commit message: "
    echo -e "${YELLOW}feat      ${NO_COLOR}→ Add a new feature"
    echo -e "${YELLOW}fix       ${NO_COLOR}→ Fix a bug (equivalent to a ${BOLD}PATCH${NORMAL} in ${BLUE}Semantic Versioning${NO_COLOR})."
    echo -e "${RED}BREAKING CHANGE       ${NO_COLOR}→ the type/scope, introduces a ${RED}breaking API change${NORMAL} (correlating with ${RED}MAJOR${NORMAL} in ${BLUE}Semantic Versioning${NO_COLOR})."
    echo -e "${YELLOW}docs      ${NO_COLOR}→ Documentation changes."
    echo -e "${YELLOW}style     ${NO_COLOR}→ Code style change (semicolon, indentation...)."
    echo -e "${YELLOW}refactor  ${NO_COLOR}→ Refactor code without changing public API."
    echo -e "${YELLOW}perf      ${NO_COLOR}→ Update code performances."
    echo -e "${YELLOW}test      ${NO_COLOR}→ Add test to an existing feature."
    echo -e "${YELLOW}chore     ${NO_COLOR}→ Update something without impacting the user (ex: ${BOLD}detekt-ruleset.yml${NORMAL})."
    exit 1
fi

read -ra COMMIT_MSG_ARR <<< ${COMMIT_MSG}
if [[ ${#COMMIT_MSG_ARR[@]} -le 3 ]]; then
    echo -e "${RED}Please write meaningful commit message 😥"
    exit 1;
fi

ASPELL=$(which aspell)
if [[ $? -ne 0 ]]; then
    echo -e "${YELLOW}Aspell not installed - unable to check spelling 🤔"

    HOMEBREW=$(which brew)
    if [[ $? -eq 0 ]] && [[ $(uname) == "Darwin" ]]; then
        sleep 1s
        echo -e "\n${NO_COLOR}Installing aspell using homebrew..."
        brew install aspell
        wait
    else
        echo -e "\n${NO_COLOR}Please install Aspell in the specific OS";
        echo -e "refer: ${BLUE}https://www.ostechnix.com/gnu-aspell-free-open-source-independent-spell-checker/${NO_COLOR}"
        exit 1
    fi
fi

sleep 2s
ASPELL=$(which aspell)
DICTIONARY_FILENAME="dictionary-commit-message.txt"
DICTIONARY_SOURCE="$PWD/scripts/spelling/$DICTIONARY_FILENAME"
if [[ $? -eq 0 ]]; then
    WORDS=$(${ASPELL} --personal=${DICTIONARY_SOURCE} list <<< ${COMMIT_MSG} | sort -u)

    if [[ -n ${WORDS} ]]; then
        echo -e "Possible spelling errors found in commit message 😱:${RED}"
        echo ${WORDS}
        exit 1
    fi
fi

AUTHOR=$(git config user.name)
AUTHOR=$(tr '[:lower:]' '[:upper:]' <<< ${AUTHOR:0:1})${AUTHOR:1}
read -ra AUTHOR_ARR <<< ${AUTHOR}
if [[ ${#AUTHOR_ARR[@]} -gt 1 ]]; then
    AUTHOR=${AUTHOR_ARR[0]}
fi

echo "[${AUTHOR}] $COMMIT_MSG" > ${COMMIT_FILE}
echo "Done"