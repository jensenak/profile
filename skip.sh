skip() {
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    RESET="$(tput sgr0)"

    #shellcheck disable=SC2206
    stages=(${(f)"$(find . -name 'conformance_test.go' -maxdepth 2 -exec grep 'RunTestStage' {} \; | cut -d\" -f2)"})
    case "$1" in
    "")
        i=1
        #shellcheck disable=SC2128
        for stage in $stages
        do
            if env | grep "SKIP_$stage" >/dev/null
            then
                echo "$i) $stage ${RED}disabled${RESET}"
            else
                echo "$i) $stage ${GREEN}enabled${RESET}"
            fi
            i=$((i+1))
        done
        ;;
    clear)
        if [ -n "$2" ]
        then
            echo "Unsetting ${stages[$2]}"
            unset "SKIP_${stages[$2]}"
        else
            echo "Clearing all"
            #shellcheck disable=SC2128
            for stage in $stages
            do
                unset "SKIP_$stage"
            done
        fi
        ;;
    *)
        echo "Setting ${stages[$1]}"
        export "SKIP_${stages[$1]}=true"
        ;;
    esac
}
