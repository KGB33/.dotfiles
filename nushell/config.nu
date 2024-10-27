let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# This completer will use carapace by default
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        # carapace completions are incorrect for nu
        nu => $fish_completer
        # fish completes commits and branch names in a nicer way
        git => $fish_completer
        _ => $carapace_completer
    } | do $in $spans
}

$env.config = {
    show_banner: false,
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }
}

def upgrade [] {
    upgrade nixos
    upgrade home
}

def "upgrade nixos" [] {
    enter /etc/nixos
    nh os switch --update /etc/nixos
    dexit
}

def "upgrade home" [] {
    enter ~/.config/home-manager/
    nh home switch --update ~/.config/home-manager/
    dexit
}

def "obs" [] {
    nvim (fd . --extension md ~/Notes/ | fzf)
}
