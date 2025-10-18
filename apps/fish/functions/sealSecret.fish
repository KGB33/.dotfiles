if test (count $argv) -eq 0
    echo "Usage: sealSecret secretName secretValue namespace"
    return 1
end

kubectl create secret generic $argv[1] --dry-run=client --from-literal=$argv[1]=$argv[2] -o yaml -n $argv[3] | \
kubeseal -o yaml
